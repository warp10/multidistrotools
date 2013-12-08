#!/bin/bash

export PATH=/home/warp10/multidistrotools:$PATH
export MDT_SCRIPTSDIR=/home/warp10/multidistrotools/scripts

DESTDIR=/home/warp10/public_html/
DIR=$(mktemp -d /tmp/mdt.XXXXXX)
cd $DIR

# get all packages recursively depending on libruby1.8
mdt depends --reverse libruby1.8 > binpkg ##FIXME: should generate wiildos packages

# get the sources packages for those binary packages
mdt bin2src < binpkg > srcpkg

# Update our package lists (Packages and Sources files)
if [ ! -d $HOME/.multidistrotools/sid ]; then
	mdt dist-create sid http://ftp.debian.org/debian unstable main contrib non-free
fi
if [ ! -d $HOME/.multidistrotools/trusty ]; then
	mdt dist-create trusty http://archive.ubuntu.com/ubuntu trusty main restricted universe multiverse
fi

mdt dist-apt-get sid update
mdt dist-apt-get trusty update

# Lists versions in Debian and Ubuntu
mdt compare-versions sid trusty > versionslist

# Filter this versions list with the list of ruby-related sources packages
mdt filter srcpkg < versionslist > wiildoslist

# Generate an HTML report from wiildoslist
mdt versions2html < wiildoslist > wiildoslist.html

echo $DIR/wiildoslist.html


