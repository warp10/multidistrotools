#!/bin/bash

export PATH=~/multidistrotools:$PATH
export MDT_SCRIPTSDIR=~/multidistrotools/scripts

DIR=$(mktemp -d /tmp/mdt.XXXXXX)
DESTDIR=/home/lucas/public_html/versions/

if [ ! -d $DESTDIR ]; then
	echo "$DESTDIR doesn't exist, edit the script or create."
	exit 1
fi

# because we will generate some temporary files
cd $DIR

# Get popcon results
mdt popcon > popcon_packages
mdt bin2src < popcon_packages > popcon_sources

# Create trees
mdt dist-create sid http://ftp.debian.org/debian unstable main contrib
mdt dist-create trusty http://archive.ubuntu.com/ubuntu trusty main restricted universe

# Update trees
mdt dist-apt-get sid update
mdt dist-apt-get trusty update

# Lists versions in Debian and Ubuntu
mdt compare-versions sid trusty > du-versions

# Get the bug list
wget http://qa.debian.org/data/ddpo/results/bugs.txt

### REPORTS
mdt filter ~/my_merges < du-versions > my-versions
mdt sort_with popcon_sources < my-versions > my-versions-sorted
mdt versions2html --debian-links --ubuntu-links --titleA Debian --titleB Ubuntu --description "Lucas' Merges" --debian-bugs "bugs.txt" --ubuntu-bugs-extended --ubuntu-build-status < my-versions-sorted > $DESTDIR/merged-packages.html

# clean up
rm -rf $DIR
