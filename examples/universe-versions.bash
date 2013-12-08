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

mdt dist-grep-dctrl-sources dapper -F Section -s Package -n universe > universepkg1
mdt dist-grep-dctrl-sources dapper -F Section -s Package -n multiverse > multiversepkg

mdt popcon | mdt bin2src > popconlist

mdt list_union universepkg1 multiversepkg > universepkg

# Lists versions in Debian and Ubuntu
mdt compare-versions sid dapper > versionslist

# Filter this versions list with the list of ruby-related sources packages
mdt filter universepkg < versionslist > univversionslist
mdt sort_with popconlist < univversionslist > univversionslist2

mdt versions_exclude_same < univversionslist2 > univversionslistuniq
# Generate an HTML report from rubyversionslist
mdt versions2html < univversionslistuniq > universe-versionslist.html

echo $DIR/universe-versionslist.html


