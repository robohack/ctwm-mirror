#
#	A BSD Makefile for ctwm
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

SRCS+=	ext/repl_str.c
.if make(obj)
SUBDIR+=	ext
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
UMAN=doc/manual
adocs:
	(cd ${UMAN} && make all_set_version)
adocs_pregen:
	(cd ${UMAN} && make all)
adoc_clean:
	(cd ${UMAN} && make clean)


# Generated files
#
SRCS+=	ctwm_atoms.c
SRCS+=	deftwmrc.c
SRCS+=	version.c

X11ROOTDIR?=	/usr/X11

PREFIX?=	${X11ROOTDIR}

.if ${PREFIX} == ${X11ROOTDIR}
PKGDIR?=	/usr/pkg
CPPFLAGS+=	-I${PKGDIR}/include
LDFLAGS+=	-L${PKGDIR}/lib
XPMDIR?=	${X11ROOTDIR}/include/X11/pixmaps/ctwm
#
# xxx ToDo:  detect various optional libraries and add -D & -L, srcs, etc.
#
.else
XPMDIR=		${PREFIX}/share/ctwm/images
.endif

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

.if empty(CPPFLAGS:M*-I.*)
CPPFLAGS+=	-I.
.endif
CPPFLAGS+=	-I${.CURDIR} -I${.CURDIR}/ext

CPPFLAGS+=	-DPIXMAP_DIRECTORY=\"${XPMDIR}\"

CPPFLAGS+=	-DSYSTEM_INIT_FILE=\"${CTWMCONFIGDIR}/system.ctwmrc\"

CPPFLAGS+=	-DCAPTIVE	# captive.c et al
CPPFLAGS+=	-DSESSION	# session.c
CPPFLAGS+=	-DWINBOX

CPPFLAGS+=	-DEWMH
CPPFLAGS+=	-DJPEG
CPPFLAGS+=	-DUSE_SYS_REGEX
CPPFLAGS+=	-DXPM
#CPPFLAGS+=	-DXRANDR	# xxx next release?

CPPFLAGS+=	-DUSEM4
CPPFLAGS+=	-DM4CMD=\"${M4:Um4}\"

YHEADER=1

# xxx this is stupid, but avoids patching a bunch of files with:
#
#	s/gram.tab.h/gram.h/
#
gram.tab.h: Makefile
	ln -fs gram.h $@
ydeps+=	add_window.o
ydeps+=	ctwm_main.o
ydeps+=	drawing.o
ydeps+=	event_handlers.o
ydeps+=	gc.o
ydeps+=	iconmgr.o
ydeps+=	mask_screen.o
ydeps+=	menus.o
ydeps+=	parse_be.o
ydeps+=	parse_yacc.o
ydeps+=	util.o
ydeps+=	win_decorations.o
ydeps+=	workspace_manager.o
ydeps+= .depend
${ydeps}: gram.tab.h

CLEANFILES+=	gram.tab.h

# xxx this is also stupid, but avoids patching a bunch of files to remove it
#
ctwm_config.h: Makefile
	rm -f ctwm_config.h
	touch ctwm_config.h

.depend: ctwm_config.h

${SRCS:R:S/$/.o/g}: ctwm_config.h

CLEANFILES+=	ctwm_config.h

ctwm_atoms.c: ctwm_atoms.in # tools/mk_atoms.sh
	${SHELL} ${.CURDIR}/tools/mk_atoms.sh ${.CURDIR}/ctwm_atoms.in ctwm_atoms CTWM

ctwm_atoms.h: ctwm_atoms.c

.depend: 	ctwm_atoms.c .WAIT ctwm_atoms.h

CLEANFILES+=	ctwm_atoms.c ctwm_atoms.h

add_window.o: ctwm_atoms.h
animate.o: ctwm_atoms.h
captive.o: ctwm_atoms.h
ctwm_main.o: ctwm_atoms.h
event_handlers.o: ctwm_atoms.h
ewmh.o: ctwm_atoms.h
functions_win.o: ctwm_atoms.h
mwmhints.o: ctwm_atoms.h
occupation.o: ctwm_atoms.h
otp.o: ctwm_atoms.h
parse.o: ctwm_atoms.h
parse_be.o: ctwm_atoms.h
session.o: ctwm_atoms.h
vscreen.o: ctwm_atoms.h
win_utils.o: ctwm_atoms.h
workspace_manager.o: ctwm_atoms.h
workspace_utils.o: ctwm_atoms.h

ewmh_atoms.c: ewmh_atoms.in # tools/mk_atoms.sh
	${SHELL} ${.CURDIR}/tools/mk_atoms.sh ${.CURDIR}/ewmh_atoms.in ewmh_atoms EWMH

ewmh_atoms.h: ewmh_atoms.c

.depend:	ewmh_atoms.c .WAIT ewmh_atoms.h

CLEANFILES+=	ewmh_atoms.c ewmh_atoms.h

add_window.o: ewmh_atoms.h
ewmh.o: ewmh_atoms.h
win_utils.o: ewmh_atoms.h
workspace_utils.o: ewmh_atoms.h

deftwmrc.c: system.ctwmrc # tools/mk_deftwmrc.sh
	${SHELL} ${.CURDIR}/tools/mk_deftwmrc.sh ${.CURDIR}/system.ctwmrc > deftwmrc.c

.depend:	deftwmrc.c

CLEANFILES+=	deftwmrc.c

event_names_table.h: event_names.list # tools/mk_event_names.sh
	${SHELL} ${.CURDIR}/tools/mk_event_names.sh ${.CURDIR}/event_names.list > $@

event_names.o: event_names_table.h

.depend:	event_names_table.h

CLEANFILES+=	event_names_table.h

functions_defs.h: functions_defs.list # tools/mk_function_bits.sh
	${SHELL} ${.CURDIR}/tools/mk_function_bits.sh ${.CURDIR}/functions_defs.list ${.OBJDIR}

functions_deferral.h functions_parse_table.h functions_dispatch_execution.h: functions_defs.h

.depend:	functions_defs.h .WAIT functions_deferral.h functions_parse_table.h functions_dispatch_execution.h

CLEANFILES+=	functions_defs.h functions_deferral.h functions_parse_table.h functions_dispatch_execution.h

event_handlers.o: functions_defs.h
ewmh.o: functions_defs.h
functions.o: functions_defs.h
functions.o: functions_deferral.h
functions_misc.o: functions_defs.h
functions_win.o: functions_defs.h
functions_win_moveresize.o: functions_defs.h
gram.o: functions_defs.h
iconmgr.o: functions_defs.h
lex.o: functions_defs.h
menus.o: functions_defs.h
parse_be.o: functions_defs.h
parse_yacc.o: functions_defs.h
win_decorations_init.o: functions_defs.h
win_resize.o: functions_defs.h

functions.o: functions_deferral.h

functions.o: functions_dispatch_execution.h

functions.o: functions_internal.h
functions_captive.o: functions_internal.h
functions_icmgr_wsmgr.o: functions_internal.h
functions_identify.o: functions_internal.h
functions_misc.o: functions_internal.h
functions_warp.o: functions_internal.h
functions_win.o: functions_internal.h
functions_win_moveresize.o: functions_internal.h
functions_workspaces.o: functions_internal.h

parse_be.o: functions_parse_table.h

# assume this is building a release with a pre-generated version.c.in
#
version.c: version.c.in VERSION # tools/mk_version_in.sh
	${SHELL} ${.CURDIR}/tools/mk_version_in.sh ${.CURDIR}/version.c.in |	\
		sed -e 's/%%VCSTYPE%%/NULL/'					\
		    -e 's/%%REVISION%%/NULL/' > $@

.depends:	version.c

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

ctwm.1: ctwm.1.docbook
	xmlto --skip-validation man ctwm.1.docbook

CTWM_VERSION!=	cat ${.CURDIR}/VERSION

ctwm.1.docbook: doc/manual/ctwm.1.adoc VERSION # tools/mk_version_in.sh
	sed -e 's|@ETCDIR@|${CTWMCONFIGDIR}|'		\
	    -e 's|@ctwm_version_str@|${CTWM_VERSION}|'	\
		< ${.CURDIR}/doc/manual/ctwm.1.adoc |	\
		asciidoc -d manpage -b docbook -o $@ -

CLEANFILES+= ctwm.1.docbook ctwm.1

.include <bsd.files.mk>
.-include <bsd.x11.mk>
.include <bsd.prog.mk>
.include <bsd.subdir.mk>
