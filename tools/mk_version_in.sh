#!/bin/sh
# This spits to stdout; we expect to be redirected.

src=$1

# This outputs the contents of version.c.in with the version numbers from
# VERSION sub'd in.

# Assume VERSION is in the dir above us
vfile="$(dirname ${0})/../VERSION"

# Split the version bits out
vstr=`sed -E -e 's/([0-9]+)\.([0-9]+)\.([0-9]+)(.*)/\1 \2 \3 \4/' ${vfile}`
set -- junk $vstr
shift

maj=$1
min=$2
pat=$3
add=$4


# And sub
sed \
	-e "s/@ctwm_version_major@/$maj/" \
	-e "s/@ctwm_version_minor@/$min/" \
	-e "s/@ctwm_version_patch@/$pat/" \
	-e "s/@ctwm_version_addl@/$add/" \
	${src}
