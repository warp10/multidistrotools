#!/bin/bash
#
# compare-versions.bash - Lucas Nussbaum <lucas@lucas-nussbaum.net>
#
# This script generate a list of all packages with their version numbers using
# two input Sources fils
# Debian and Ubuntu.
# 
# TODO/BUGS
# - improve error handling

usage() {
	echo "mdt compare-versions sid dapper"
}
	
set -e

if [ $# -ne 2 ]; then
	usage
	exit 1
elif [ "$1" == '--help' ]; then
	usage
	exit 1
fi
if [ ! -d $HOME/.multidistrotools/$1 ]; then
	echo "APT tree named $1 doesn't exist in $HOME/.multidistrotools."
	exit 1
fi
DIST1=$1
if [ ! -d $HOME/.multidistrotools/$2 ]; then
	echo "APT tree named $2 doesn't exist in $HOME/.multidistrotools."
	exit 1
fi
DIST2=$2

MCVDIR=$(mktemp -d /tmp/MCV.XXXXXX)

for D in $DIST1 $DIST2; do
	cat ~/.multidistrotools/${D}/var/lib/apt/lists/*_Sources | awk '/^Package:/ { p = $2 } /^Version:/ { print p, $2 }' | sort > $MCVDIR/${D}_packages
done

# Workaround: debian used to provide a patch to uniq which added a -W option,
# which provided field-based uniqueness.
uniqW1(){
awk 'BEGIN { s = "" } { if ($1 != s) { print $0 ; s = $1} }'
}

# get all the packages
awk '{print $1, "NOTFOUND"}' $MCVDIR/{${DIST1},${DIST2}}_packages | sort | uniq > $MCVDIR/all_packages
# add missing packages to the pkg lists
for D in $DIST1 $DIST2; do
	cat $MCVDIR/{${D},all}_packages | sort --stable -k 1,1 | uniqW1 > $MCVDIR/${D}_packages_complete
done
join $MCVDIR/{${DIST1},${DIST2}}_packages_complete
rm -rf $MCVDIR
