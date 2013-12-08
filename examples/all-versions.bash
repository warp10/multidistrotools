#!/bin/bash

DIR=$(mktemp -d /tmp/mdt.XXXXXX)
# because we will generate some temporary files
cd $DIR

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
mdt compare-versions sid dapper | mdt versions_exclude_same | grep -v -E "^language-(pack|support)-" > allversionslist

# Generate an HTML report from rubyversionslist
mdt versions2html < allversionslist > versionslist.html

echo $DIR/versionslist.html


