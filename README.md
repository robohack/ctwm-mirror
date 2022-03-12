# CTWM: Claude's Tab Window Manager for the X Window System

## NOTE:  This is a variant of the original [CTWM][CTWM].

This variant is maintained as a fork of the original.

This CTWM uses BSD Make for building, and it includes a few minor bug
fixes and other enhancements.  See the Git history.  Further fixes or
enhancements are welcome.

This fork is maintained in [robohack's GitHub][GHRC] by Greg A. Woods.

Motto:  Write Portable C without complicating the build!

See, e.g.: https://nullprogram.com/blog/2017/03/30/


## Intro

Ctwm is an extension to twm, and was originally enhanced by Claude
Lecommandeur.  It supports multiple virtual screens, and a lot of other
goodies.

You can use and manage up to 32 virtual screens called workspaces.  You
swap from one workspace to another by clicking on a button in an
optionnal panel of buttons (the workspace manager) or by invoking a
function either by keystroke or from a context menu.

You can customize each workspace by choosing different colors, names and
pixmaps for the buttons and background root windows.

Major features include:

* Optional 3D window titles and border (ala Motif).
* Shaped, colored icons.
* Multiple icons for clients based on the icon name.
* Windows can belong to several workspaces.
* A map of your workspaces to move quickly windows between
   different workspaces.
* Animations: icons, root backgrounds and buttons can be animated.
* Pinnable and sticky menus.
* etc...

The sources files were once the twm ones only workmgr.[ch] added (written
from scratch by Claude Lecommandeur) and minor modifications to some twm
files.  Since then much more extensive changes and reorganization have
been done, so the codebase is now significantly different from plain twm.

If you find bugs in ctwm, or just want to tell us how much you like it,
please send a report to the mailing list.

There is a manual page, which always needs more work (any volunteers?).
Many useful information bits are only in the CHANGES.md file, so please
read it.


## Configuration

ctwm is built using a very simple BSD Makefile.

In the common case, the included Makefile will do the necessary
invocations, and you won't need to worry about it; just run a normal
`make ; make install` invocation.


## Building

In the simple case, the defaults should work.  Most modern or semi-modern
systems should fall into this.

    $ make

You can put the build objects in another directory easily enough:

    $ mkdir build; MAKEOBJDIRPREFIX=$(pwd -P)/build make obj
    $ mkdir build; MAKEOBJDIRPREFIX=$(pwd -P)/build make


### Required Libraries

ctwm requires various X11 libraries to be present.  That list will
generally include libX11, libXext, libXmu, libXt, libSM, and libICE.

Depending on your host environment, you may require extra libraries,
such as libXpm, libjpeg, and libXrandr.  These can very easily be
installed with [pkgsrc][pkgsrc]


## Installation

Installation as root is easy:

    # make install


### Packaging

BSD Makes generally support ${DESTDIR} installs -- to create a binary
distribution archive just do the following:

    $ mkdir build; MAKEOBJDIRPREFIX=$(pwd -P)/build make obj
    $ MAKEOBJDIRPREFIX=$(pwd -P)/build make
    $ mkdir dist; MAKEOBJDIRPREFIX=$(pwd -P)/build make DESTDIR=$(pwd -P) install


## Dev and Support


### Mailing list

There is a mailing list for discussions: <ctwm@ctwm.org>.  Subscribe by
sending a mail with the subject "subscribe ctwm" to
<minimalist@ctwm.org>.


### Repository

This CTWM is maintained in [robohack's GitHub][GHRC] by Greg A. Woods.


## Further information

Additional information can be found from the project webpage, at
<https://www.ctwm.org/>.


[GHRC]: https://github.com/robohack/ctwm-mirror/
[CTWM]: https://github.com/fullermd/ctwm-mirror/
[pkgsrc]: https://pkgsrc.org/
