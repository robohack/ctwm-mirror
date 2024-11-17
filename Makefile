#
#	A BSD Makefile for ctwm
#
# Tested on NetBSD, FreeBSD, and macos with pkgsrc bmake (and bootstrap-mk-files)
#
# It is assumed libjpeg is available (in EXTLIBS).
#
# Needs asciidoc and xmlto for manual page generation.
#
# BUILD_DIR=build-$(uname -s)-$(uname -m)
# mkdir -p ${BUILD_DIR}
# MAKEOBJDIRPREFIX=$(pwd -P)/${BUILD_DIR} make PREFIX=/usr/pkg LDSTATIC=-static obj
# MAKEOBJDIRPREFIX=$(pwd -P)/${BUILD_DIR} make PREFIX=/usr/pkg LDSTATIC=-static all
#
# Notes:
#
# Don't use "make depend" on FreeBSD, and either do the "obj" step separately,
# or, better yet, put "WITH_AUTO_OBJ=yes" on the command line (or in the
# environment).
#
# You can use "make obj dependall" on NetBSD and with pkgsrc bmake.
#
# PREFIX defaults to ${X11ROOTDIR}, which should be defined if your system has
# <bsd.x11.mk>, and in this case the default plan is to install there as well.
#
# X11ROOTDIR defaults to ${PREFIX} in case <bsd.x11.mk> is not found.
#
# So, one of one of PREFIX or X11ROOTDIR must be defined if there is no
# <bsd.x11.mk>.
#
# EXTLIBS defaults to ${PREFIX}, if that is defined, else "/usr/pkg"
#

.include <bsd.own.mk>

PROG=	ctwm

SRCS+=	add_window.c
SRCS+=	animate.c
SRCS+=	captive.c
SRCS+=	clargs.c
SRCS+=	clicktofocus.c
SRCS+=	colormaps.c
SRCS+=	ctopts.c
SRCS+=	ctwm_main.c
SRCS+=	ctwm_shutdown.c
SRCS+=	ctwm_takeover.c
SRCS+=	ctwm_wrap.c
SRCS+=	cursor.c
SRCS+=	drawing.c
SRCS+=	event_core.c
SRCS+=	event_handlers.c
SRCS+=	event_names.c
SRCS+=	event_utils.c
SRCS+=	ewmh.c
SRCS+=	ewmh_atoms.c
SRCS+=	functions.c
SRCS+=	functions_captive.c
SRCS+=	functions_icmgr_wsmgr.c
SRCS+=	functions_identify.c
SRCS+=	functions_misc.c
SRCS+=	functions_warp.c
SRCS+=	functions_win.c
SRCS+=	functions_win_moveresize.c
SRCS+=	functions_workspaces.c
SRCS+=	gc.c
SRCS+=	iconmgr.c
SRCS+=	icons.c
SRCS+=	icons_builtin.c
SRCS+=	image.c
SRCS+=	image_bitmap.c
SRCS+=	image_bitmap_builtin.c
SRCS+=	image_jpeg.c
SRCS+=	image_xpm.c
SRCS+=	image_xwd.c
SRCS+=	list.c
SRCS+=	mask_screen.c
SRCS+=	menus.c
SRCS+=	mwmhints.c
SRCS+=	occupation.c
SRCS+=	otp.c
SRCS+=	parse.c
SRCS+=	parse_be.c
SRCS+=	parse_m4.c
SRCS+=	parse_yacc.c
SRCS+=	r_area.c
SRCS+=	r_area_list.c
SRCS+=	r_layout.c
SRCS+=	session.c
SRCS+=	signals.c
SRCS+=	util.c
SRCS+=	vscreen.c
SRCS+=	win_decorations.c
SRCS+=	win_decorations_init.c
SRCS+=	win_iconify.c
SRCS+=	win_ops.c
SRCS+=	win_regions.c
SRCS+=	win_resize.c
SRCS+=	win_ring.c
SRCS+=	win_utils.c
SRCS+=	windowbox.c
SRCS+=	workspace_config.c
SRCS+=	workspace_manager.c
SRCS+=	workspace_utils.c
SRCS+=	xparsegeometry.c
SRCS+=	xrandr.c

# special sources
SRCS+=	gram.y
SRCS+=	lex.l

SUBDIR+=	ext

LDADD+=	-Lext -lext
DPADD+=	${.OBJDIR}/ext/libext.a

# Most of the non-NetBSD <bsd.subdir.mk>s are terribly unreliable!
#
# XXX grrr.... just for FreeBSD
${PROG}: ext .WAIT
#
# XXX grrr.... for pkgsrc bootstrap-mk-files
.if defined(OS) && (${unix:U"not-bmake?"} == "We run Unix")
${PROG}: all-ext .WAIT
.endif

# more modern mk-files install a ${PROG}.debug file in libdata or whatever
#
STRIPFLAG =	# empty, for bootstrap-mk-files and older bmakes
STRIP =		# empty, for bootstrap-mk-files and older bmakes

EXTLIBS?=	${PREFIX:U/usr/pkg}

.if defined(CPPFLAGS)
CPPFLAGS+=	-I${EXTLIBS}/include
.else
CFLAGS+=	-I${EXTLIBS}/include
.endif
LDFLAGS+=	-L${EXTLIBS}/lib
. if empty(LDSTATIC)
LDFLAGS+=	-Wl,-rpath,${EXTLIBS}/lib
. endif

.if defined(PREFIX)
# note: must define both in case <bsd.x11.mk> does not exist
BINDIR=		${PREFIX}/bin
X11BINDIR=	${PREFIX}/bin
MANDIR=		${PREFIX}/${PKGMANDIR:Ushare/man}
X11MANDIR=	${PREFIX}/${PKGMANDIR:Ushare/man}
.endif

# Build documentation files
DOC_FILES=README.html CHANGES.html
docs: ${DOC_FILES}
docs_clean doc_clean:
	rm -f ${DOC_FILES}

.SUFFIXES: ${.SUFFIXES} .html .adoc
.adoc.html:
	asciidoctor -o ${@} ${<}

# asciidoc files
#UMAN=doc/manual
#adocs:
#	(cd ${UMAN} && make all_set_version)
#adocs_pregen:
#	(cd ${UMAN} && make all)
#adoc_clean:
#	(cd ${UMAN} && make clean)

# Generated source files
#
GENSRCS+=	ctwm_atoms.c
GENSRCS+=	deftwmrc.c
GENSRCS+=	version.c

SRCS+=		${GENSRCS}

GENHDRS+=	ctwm_config.h
GENHDRS+=	gram.tab.h
GENHDRS+=	ctwm_atoms.h
GENHDRS+=	ewmh_atoms.h
GENHDRS+=	event_names_table.h
GENHDRS+=	functions_defs.h functions_deferral.h functions_parse_table.h functions_dispatch_execution.h

DPSRCS+= 	${GENHDRS}

# xxx mimic pkgsrc to support systems without <bsd.x11.mk> (which currently
# include non-NetBSD pkgsrc platforms using bootstrap-mk-files!)
#
PKG_SYSCONFSUBDIR?=	X11/ctwm
PKG_SYSCONFBASEDIR?=	/etc
PKG_SYSCONFDIR?=	${PKG_SYSCONFBASEDIR}/${PKG_SYSCONFSUBDIR}

X11ETCDIR?=	${PKG_SYSCONFBASEDIR}/X11
CTWMCONFIGDIR=	${X11ETCDIR}/ctwm

# xxx CONFIGFILES is not (yet) supported by pkgsrc bootstrap-mk-files
# (note CONFIGFILES still uses ${FILESDIR_${F}:U${FILESDIR}} for dest)
#
FILES+=			system.ctwmrc
FILESDIR_system.ctwmrc=	${CTWMCONFIGDIR}

CTWM_FLAGS+=	-I${.CURDIR} -I${.CURDIR}/ext

CTWM_FLAGS+=	-DPIXMAP_DIRECTORY=\"${XPMDIR}\"

CTWM_FLAGS+=	-DSYSTEM_INIT_FILE=\"${CTWMCONFIGDIR}/system.ctwmrc\"

CTWM_FLAGS+=	-DCAPTIVE	# captive.c et al
CTWM_FLAGS+=	-DSESSION	# session.c
CTWM_FLAGS+=	-DWINBOX

CTWM_FLAGS+=	-DEWMH
CTWM_FLAGS+=	-DJPEG		# needs libjpeg, of course
CTWM_FLAGS+=	-DUSE_SYS_REGEX
CTWM_FLAGS+=	-DXPM
CTWM_FLAGS+=	-DXRANDR	# xrandr.c

CTWM_FLAGS+=	-DUSEM4
CTWM_FLAGS+=	-DM4CMD=\"${M4:Um4}\"

# This .if is annoying, but some older systems (and modern FreeBSD) don't
# support CPPFLAGS.
#
.if defined(CPPFLAGS)
. if empty(CPPFLAGS:M*-I.*)
CPPFLAGS+=	-I.
. endif
CPPFLAGS+=	${CTWM_FLAGS}
.else
. if empty(CFLAGS:M*-I.*)
CFLAGS+=	-I.
. endif
CFLAGS+=	${CTWM_FLAGS}
.endif

YHEADER=1

# for non-NetBSD bmakes
HOST_SH?=	${SHELL}

# xxx this is stupid, but avoids patching a bunch of files with:
#
#	s/gram.tab.h/gram.h/
#
gram.tab.h: Makefile
	ln -fs gram.h $@

CLEANFILES+=	gram.tab.h

# xxx this is also stupid, but avoids patching a bunch of files to remove it
#
ctwm_config.h:
	rm -f $@
	touch $@

CLEANFILES+=	ctwm_config.h

.ORDER: ctwm_atoms.c ctwm_atoms.h
ctwm_atoms.c ctwm_atoms.h: tools/mk_atoms.sh ctwm_atoms.in
	${_MKTARGET_CREATE}
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC} ${.OBJDIR}/ctwm_atoms CTWM
	[ -f ctwm_atoms.h ]

CLEANFILES+=	ctwm_atoms.c ctwm_atoms.h

.ORDER: ewmh_atoms.c ewmh_atoms.h
ewmh_atoms.c ewmh_atoms.h: tools/mk_atoms.sh ewmh_atoms.in
	${_MKTARGET_CREATE}
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC} ${.OBJDIR}/ewmh_atoms EWMH
	[ -f ewmh_atoms.h ]

CLEANFILES+=	ewmh_atoms.c ewmh_atoms.h

deftwmrc.c: tools/mk_deftwmrc.sh system.ctwmrc
	${_MKTARGET_CREATE}
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC} > $@

CLEANFILES+=	${.OBJDIR}/deftwmrc.c

event_names_table.h: tools/mk_event_names.sh event_names.list
	${_MKTARGET_CREATE}
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC} > $@

CLEANFILES+=	event_names_table.h

FUNCTION_BITS+=	functions_defs.h
FUNCTION_BITS+=	functions_deferral.h
FUNCTION_BITS+=	functions_parse_table.h
FUNCTION_BITS+=	functions_dispatch_execution.h
.ORDER: ${FUNCTION_BITS}
${FUNCTION_BITS}: tools/mk_function_bits.sh functions_defs.list
	${_MKTARGET_CREATE}
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC} ${.OBJDIR}
	[ -f functions_dispatch_execution.h ]

CLEANFILES+=	${FUNCTION_BITS}

version.c: tools/mk_version_in.sh version.c.in
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC} |		\
	${SCRIPT_ENV} ${HOST_SH} ${.CURDIR}/tools/rewrite_version_git.sh > $@

version.c: tools/rewrite_version_git.sh

CLEANFILES+=	version.c

LDADD+= -ljpeg
DPADD+=	${LIBJPEG}

LDADD+=	-lXpm -lXmu -lXt -lSM -lICE -lXrandr -lXrender -lXext -lX11 -lxcb -lXau -lXdmcp
DPADD+=	${LIBXPM} ${LIBXMU} ${LIBXT} ${LIBSM} ${LIBICE} ${LIBXRANDR} ${LIBXRENDER} ${LIBXEXT} ${LIBX11} ${LIBXCB} ${LIBXAU} ${LIBXDMCP}

FILESDIR= ${XPMDIR}

#xxx# FILES!= cd ${.CURDIR}/xpm && echo *.xpm

FILES+=	3D_Expand15.xpm
FILES+=	3D_Iconify15.xpm
FILES+=	3D_Lightning15.xpm
FILES+=	3D_Menu15.xpm
FILES+=	3D_Resize15.xpm
FILES+=	3D_Zoom15.xpm
FILES+=	3dcircle.xpm
FILES+=	3ddimple.xpm
FILES+=	3ddot.xpm
FILES+=	3dfeet.xpm
FILES+=	3dleopard.xpm
FILES+=	3dpie.xpm
FILES+=	3dpyramid.xpm
FILES+=	3dslant.xpm
FILES+=	IslandD.xpm
FILES+=	IslandW.xpm
FILES+=	LRom.xpm
FILES+=	LRom1.xpm
FILES+=	arthur.xpm
FILES+=	audio_editor.xpm
FILES+=	background1.xpm
FILES+=	background2.xpm
FILES+=	background3.xpm
FILES+=	background4.xpm
FILES+=	background5.xpm
FILES+=	background6.xpm
FILES+=	background7.xpm
FILES+=	background8.xpm
FILES+=	background9.xpm
FILES+=	ball1.xpm
FILES+=	ball10.xpm
FILES+=	ball11.xpm
FILES+=	ball12.xpm
FILES+=	ball2.xpm
FILES+=	ball3.xpm
FILES+=	ball4.xpm
FILES+=	ball5.xpm
FILES+=	ball6.xpm
FILES+=	ball7.xpm
FILES+=	ball8.xpm
FILES+=	ball9.xpm
FILES+=	cdrom1.xpm
FILES+=	claude.xpm
FILES+=	clipboard.xpm
FILES+=	datebook.xpm
FILES+=	emacs.xpm
FILES+=	ghostview.xpm
FILES+=	hpterm.xpm
FILES+=	mail0.xpm
FILES+=	mail1.xpm
FILES+=	nothing.xpm
FILES+=	nt1.xpm
FILES+=	nt2.xpm
FILES+=	pixmap.xpm
FILES+=	postit.xpm
FILES+=	skull.xpm
FILES+=	spider.xpm
FILES+=	supman1.xbm
FILES+=	supman2.xbm
FILES+=	supman3.xbm
FILES+=	supman4.xbm
FILES+=	supman5.xbm
FILES+=	supman6.xbm
FILES+=	supman7.xbm
FILES+=	supman8.xbm
FILES+=	supman9.xbm
FILES+=	term.xpm
FILES+=	unknown.xpm
FILES+=	unknown1.xpm
FILES+=	unread.xpm
FILES+=	welcome.xpm
FILES+=	welcome.xwd
FILES+=	xarchie.xpm
FILES+=	xcalc.xpm
FILES+=	xcalc2.xpm
FILES+=	xedit.xpm
FILES+=	xftp.xpm
FILES+=	xgopher.xpm
FILES+=	xgrab.xpm
FILES+=	xhpcalc.xpm
FILES+=	xirc.xpm
FILES+=	xmail.xpm
FILES+=	xman.xpm
FILES+=	xmosaic.xpm
FILES+=	xnomail.xpm
FILES+=	xrn-compose.xpm
FILES+=	xrn.goodnews.xpm
FILES+=	xrn.nonews.xpm
FILES+=	xrn.xpm
FILES+=	xterm.xpm

.PATH:	${.CURDIR}/xpm

.if defined(OS) && (${unix:U"not-bmake?"} == "We run Unix")
# xxx else nothing makes it a target!
dependall all:	ctwm.1 ctwm.1.html
.endif

ctwm.1: ctwm.1.docbook
	xmlto --skip-validation man ctwm.1.docbook || true

CTWM_VERSION!=	cat ${.CURDIR}/VERSION

ctwm.1.docbook: doc/manual/ctwm.1.adoc VERSION
	sed -e 's|@ETCDIR@|${CTWMCONFIGDIR}|'		\
	    -e 's|@ctwm_version_str@|${CTWM_VERSION}|'	\
		< ${.CURDIR}/doc/manual/ctwm.1.adoc |	\
		asciidoc -d manpage -b docbook -o $@ -

ctwm.1.html: doc/manual/ctwm.1.adoc VERSION
	sed -e 's|@ETCDIR@|${CTWMCONFIGDIR}|'		\
	    -e 's|@ctwm_version_str@|${CTWM_VERSION}|'	\
		< ${.CURDIR}/doc/manual/ctwm.1.adoc |	\
		asciidoc -a toc -a numbered -b html4 -o $@ -

CLEANFILES+= ctwm.1.docbook ctwm.1

.-include <bsd.x11.mk>

PREFIX?=	${X11ROOTDIR}
X11ROOTDIR?=	${PREFIX}

.if ${PREFIX} == ${X11ROOTDIR}
XPMDIR?=	${X11ROOTDIR}/include/X11/pixmaps/ctwm
.else
XPMDIR=		${PREFIX}/share/ctwm/images
.endif

.if !defined(X11ROOTDIR)

. if exists(/opt/X11)
X11ROOTDIR=	/opt/X11
. elif exists(/usr/X11)
X11ROOTDIR=	/usr/X11
. elif exists(/usr/X11R7)
X11ROOTDIR=	/usr/X11R7
. endif

X11INCDIR?=	${X11ROOTDIR}/include

CPPFLAGS+=	-I${X11INCDIR}

X11USRLIBDIR?=	${X11ROOTDIR}/lib

LDFLAGS+=	-L${X11USRLIBDIR}
. if empty(LDSTATIC)
LDFLAGS+=	-Wl,-rpath,${X11USRLIBDIR}
. endif

X11BINDIR?=	${X11ROOTDIR}/bin
X11MANDIR?=	${X11ROOTDIR}/man

.endif	# !defined(X11ROOTDIR)

.include <bsd.prog.mk>
.include <bsd.files.mk>
.include <bsd.subdir.mk>

#
# Local Variables:
# eval: (make-local-variable 'compile-command)
# compile-command: (concat "BUILD_DIR=build-$(uname -s)-$(uname -m); mkdir -p ${BUILD_DIR}; MAKEOBJDIRPREFIX=$(pwd -P)/${BUILD_DIR} PREFIX=/usr/pkg " (default-value 'compile-command) " LDSTATIC=-static obj dependall")
# End:
#
