#!/bin/bash

export MDT_PATH=/home/warp10/multidistrotools
export PATH=$MDT_PATH:$PATH
export MDT_SCRIPTSDIR=$MDT_PATH/scripts

DESTDIR=$MDT_PATH
if [ ! -d $DESTDIR ]; then
    echo "$DESTDIR doesn't exist, edit the script or create."
    exit 1
fi

DIR=$(mktemp -d /tmp/mdt.XXXXXX)
cd $DIR

# Update our package lists (Packages and Sources files)
if [ ! -d $HOME/.multidistrotools/sid ]; then
	mdt dist-create sid http://ftp.debian.org/debian unstable main contrib non-free
fi
if [ ! -d $HOME/.multidistrotools/trusty ]; then
	mdt dist-create trusty http://archive.ubuntu.com/ubuntu trusty main restricted universe multiverse
fi

mdt dist-apt-get sid update
mdt dist-apt-get trusty update

# Get popcon results
mdt popcon > popcon_packages
mdt bin2src < popcon_packages > popcon_sources

# Lists versions in Debian and Ubuntu
mdt compare-versions sid trusty > du-versions

# Get the bug list
wget http://qa.debian.org/data/ddpo/results/bugs.txt

# Generate a report about universe/multiverse package
mdt dist-grep-dctrl-sources trusty -F Section -s Package -n universe > universepkg
mdt dist-grep-dctrl-sources trusty -F Section -s Package -n multiverse > multiversepkg
mdt list_union universepkg multiversepkg > versepkg
mdt filter versepkg < du-versions > verse-versions
mdt sort_with popcon_sources < verse-versions > verse-versions-sorted

if [ -f $MDT_PATH/wiildos_pkglist ]; then
    mdt filter $MDT_PATH/wiildos_pkglist < versepkg > my-versepkg
    mdt filter my-versepkg < du-versions > my-verse-versions
    mdt sort_with popcon_sources < my-verse-versions > my-verse-versions-sorted
    mdt versions2html --debian-links --ubuntu-links --titleA Debian --titleB Ubuntu --description "Status of WiildOS packages in Debian and Ubuntu" --debian-bugs "bugs.txt" < my-verse-versions-sorted > $MDT_PATH/wiildoslist.html

    echo file://$MDT_PATH/wiildoslist.html
fi

rm -rf $DIR
