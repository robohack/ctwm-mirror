#!/bin/sh
#
# Rewrite version.c.in (well, technically, stdin) with git revision info.
# We assume if we're getting called, git is available.


# xxx current branch is also "git rev-parse --abbrev-ref HEAD"
REVID=`git branch --show-current`-`git rev-parse --short HEAD`
if [ $? -ne 0 ]; then
	# Failed somehow
	REVID="???"
fi

# Shouldn't need sanitized like we do in bzr JIC.

# Pass stdin through and sub
sed -e "s/%%VCSTYPE%%/\"git\"/" -e "s/%%REVISION%%/\"${REVID}\"/"
