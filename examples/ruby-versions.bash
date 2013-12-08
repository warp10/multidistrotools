#!/bin/bash

DIR=$(mktemp -d /tmp/mdt.XXXXXX)
# because we will generate some temporary files
cd $DIR

# get all packages recursively depending on libruby1.8
mdt depends --reverse libruby1.8 > binpkg

# get the sources packages for those binary packages
mdt bin2src < binpkg > srcpkg

# Update our package lists (Packages and Sources files)
if [ ! -d $HOME/.multidistrotools/sid ]; then
	mdt dist-create sid http://ftp.debian.org/debian unstable main contrib non-free
fi
if [ ! -d $HOME/.multidistrotools/dapper ]; then
	mdt dist-create dapper http://archive.ubuntu.com/ubuntu dapper main restricted universe multiverse
fi

mdt dist-apt-get sid update
mdt dist-apt-get dapper update

# Lists versions in Debian and Ubuntu
mdt compare-versions sid dapper > versionslist

# Filter this versions list with the list of ruby-related sources packages
mdt filter srcpkg < versionslist > rubyversionslist

# Generate an HTML report from rubyversionslist
mdt versions2html < rubyversionslist > rubyversionslist.html

echo $DIR/rubyversionslist.html


