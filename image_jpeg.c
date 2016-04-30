/*
 * JPEG image handling functions
 */

#include "ctwm.h"

/*
 * Need this for the fixed-size uint_*'s used below.  stdint.h would be
 * the more appropriate include, but there exist systems that don't have
 * it, but do have inttypes.h (FreeBSD 4, Solaris 7-9 I've heard of,
 * probably more).
 */
#include <inttypes.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "screen.h"
#include "types.h"
#include "util.h"
#include "image_jpeg.h"

/* Bits needed for libjpeg and interaction */
#include <setjmp.h>
#include <jpeglib.h>
#include <jerror.h>

#include <X11/Xlib.h>

static int reportfilenotfound = 1;

static Image *LoadJpegImage(char *name);

struct jpeg_error {
	struct jpeg_error_mgr pub;
	sigjmp_buf setjmp_buffer;
};

typedef struct jpeg_error *jerr_ptr;


static uint16_t *buffer_16bpp;
static uint32_t *buffer_32bpp;

static void convert_for_16(int w, int x, int y, int r, int g, int b)
{
	buffer_16bpp [y * w + x] = ((r >> 3) << 11) + ((g >> 2) << 5) + (b >> 3);
}

static void convert_for_32(int w, int x, int y, int r, int g, int b)
{
	buffer_32bpp [y * w + x] = ((r << 16) + (g << 8) + b) & 0xFFFFFFFF;
}

static void jpeg_error_exit(j_common_ptr cinfo)
{
	jerr_ptr errmgr = (jerr_ptr) cinfo->err;
	cinfo->err->output_message(cinfo);
	siglongjmp(errmgr->setjmp_buffer, 1);
	return;
}

Image *
GetJpegImage(char *name)
{
	Image *image, *r, *s;
	char  path [128];
	char  pref [128], *perc;
	int   i;

	if(! strchr(name, '%')) {
		return (LoadJpegImage(name));
	}
	s = image = None;
	strcpy(pref, name);
	perc  = strchr(pref, '%');
	*perc = '\0';
	reportfilenotfound = 0;
	for(i = 1;; i++) {
		sprintf(path, "%s%d%s", pref, i, perc + 1);
		r = LoadJpegImage(path);
		if(r == None) {
			break;
		}
		r->next   = None;
		if(image == None) {
			s = image = r;
		}
		else {
			s->next = r;
			s = r;
		}
	}
	reportfilenotfound = 1;
	if(s != None) {
		s->next = image;
	}
	if(image == None) {
		fprintf(stderr, "Cannot open any %s jpeg file\n", name);
	}
	return (image);
}

static Image *LoadJpegImage(char *name)
{
	char   *fullname;
	XImage *ximage;
	FILE   *infile;
	Image  *image;
	Pixmap pixret;
	void (*store_data)(int w, int x, int y, int r, int g, int b);
	struct jpeg_decompress_struct cinfo;
	struct jpeg_error jerr;
	JSAMPARRAY buffer;
	int width, height;
	int row_stride;
	int g, i, a;
	int bpix;
	GC  gc;

	fullname = ExpandPixmapPath(name);
	if(! fullname) {
		return (None);
	}

	image = (Image *) malloc(sizeof(Image));
	if(image == None) {
		free(fullname);
		return (None);
	}

	if((infile = fopen(fullname, "rb")) == NULL) {
		if(!reportfilenotfound) {
			fprintf(stderr, "unable to locate %s\n", fullname);
		}
		fflush(stdout);
		free(image);
		free(fullname);
		return None;
	}
	free(fullname);
	cinfo.err = jpeg_std_error(&jerr.pub);
	jerr.pub.error_exit = jpeg_error_exit;

	if(sigsetjmp(jerr.setjmp_buffer, 1)) {
		jpeg_destroy_decompress(&cinfo);
		free(image);
		fclose(infile);
		return None;
	}
	jpeg_create_decompress(&cinfo);
	jpeg_stdio_src(&cinfo, infile);
	jpeg_read_header(&cinfo, FALSE);
	cinfo.do_fancy_upsampling = FALSE;
	cinfo.do_block_smoothing = FALSE;
	jpeg_start_decompress(&cinfo);
	width  = cinfo.output_width;
	height = cinfo.output_height;

	if(Scr->d_depth == 16) {
		store_data = &convert_for_16;
		buffer_16bpp = (unsigned short int *) malloc((width) * (height) * 2);
		ximage = XCreateImage(dpy, CopyFromParent, Scr->d_depth, ZPixmap, 0,
		                      (char *) buffer_16bpp, width, height, 16, width * 2);
	}
	else if(Scr->d_depth == 24 || Scr->d_depth == 32) {
		store_data = &convert_for_32;
		buffer_32bpp = malloc(width * height * 4);
		ximage = XCreateImage(dpy, CopyFromParent, Scr->d_depth, ZPixmap, 0,
		                      (char *) buffer_32bpp, width, height, 32, width * 4);
	}
	else {
		fprintf(stderr, "Image %s unsupported depth : %d\n", name, Scr->d_depth);
		free(image);
		fclose(infile);
		return None;
	}
	if(ximage == None) {
		fprintf(stderr, "cannot create image for %s\n", name);
		free(image);
		fclose(infile);
		return None;
	}
	g = 0;
	row_stride = cinfo.output_width * cinfo.output_components;
	buffer = (*cinfo.mem->alloc_sarray)
	         ((j_common_ptr) & cinfo, JPOOL_IMAGE, row_stride, 1);

	bpix = cinfo.output_components;
	while(cinfo.output_scanline < cinfo.output_height) {
		jpeg_read_scanlines(&cinfo, buffer, 1);
		a = 0;
		for(i = 0; i < bpix * cinfo.output_width; i += bpix) {
			(*store_data)(width, a, g, buffer[0][i],  buffer[0][i + 1], buffer[0][i + 2]);
			a++;
		}
		g++;
	}
	jpeg_finish_decompress(&cinfo);
	jpeg_destroy_decompress(&cinfo);
	fclose(infile);

	gc = DefaultGC(dpy, Scr->screen);
	if((width > (Scr->rootw / 2)) || (height > (Scr->rooth / 2))) {
		int x, y;

		pixret = XCreatePixmap(dpy, Scr->Root, Scr->rootw, Scr->rooth, Scr->d_depth);
		x = (Scr->rootw  -  width) / 2;
		y = (Scr->rooth  - height) / 2;
		XFillRectangle(dpy, pixret, gc, 0, 0, Scr->rootw, Scr->rooth);
		XPutImage(dpy, pixret, gc, ximage, 0, 0, x, y, width, height);
		image->width  = Scr->rootw;
		image->height = Scr->rooth;
	}
	else {
		pixret = XCreatePixmap(dpy, Scr->Root, width, height, Scr->d_depth);
		XPutImage(dpy, pixret, gc, ximage, 0, 0, 0, 0, width, height);
		image->width  = width;
		image->height = height;
	}
	if(ximage) {
		XDestroyImage(ximage);
	}
	image->pixmap = pixret;
	image->mask   = None;
	image->next   = None;

	return image;
}
