#!/bin/bash
# 
# src2bin.bash
# - Lucas Nussbaum <lucas@lucas-nussbaum.net>

usage() {
cat > /dev/stdout <<EOF
This script gives the source package for the binary package given as
argument. If no package name is provided, a list of packages read on
standard input is used.

Examples:
  mdt src2bin gnome
  mdt src2bin < pkg_list
EOF
}

getbinpkg() {
#	echo "Getting binary package for $1" > /dev/stderr
	# all packages with binary.name == source.name don't have a Source header
	# all packages with binary.name != source.name have a Source header
	apt-cache showsrc $1 |grep -E "^Binary:" |cut -c 9- |tr -d ',' |tr ' ' "\n"
}

if [ $# -eq 0 ]; then
	while read n; do
		getbinpkg $n
	done | sort | uniq
else
	if [ "$1" == '--help' ]; then
		usage
	else
		getbinpkg $1
	fi
fi
