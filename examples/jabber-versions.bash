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

# get all packages matching "jabber" and "xmpp"
mdt dist-apt-cache dapper search jabber | awk '{print $1}' > jabberpkg
mdt dist-apt-cache dapper search xmpp | awk '{print $1}' > xmpppkg

mdt list_union jabberpkg xmpppkg | mdt unify > jabberbinpkg

# get the sources packages for those binary packages
mdt bin2src < jabberbinpkg > jabbersrcpkg

# Lists versions in Debian and Ubuntu
mdt compare-versions sid dapper > versionslist

# Filter this versions list with the list of ruby-related sources packages
mdt filter jabbersrcpkg < versionslist > jabberversionslist

# Generate an HTML report from rubyversionslist
mdt versions2html < jabberversionslist > jabberversionslist.html

echo $DIR/jabberversionslist.html


