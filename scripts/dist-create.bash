#!/bin/bash
# 
# dist-create.bash
# - Lucas Nussbaum <lucas@lucas-nussbaum.net>
#
# Changelog:
# * 20060318 Otavio Salvador <otavio@ossystems.com.br>:
#   - Changed code to be easier to read
#   - Skip debian-installer section from deb-src sources.list line

usage() {
	cat > /dev/stdout <<EOF
This script create an APT tree for the given distribution under
~/.multidistrotools. You can think of it as a chroot, even if it is not
the case (it is a much lighter aproach). Later, this tree can be
used with mdt dist-apt-get and mdt-dist-apt-cache.

Syntax:
  mdt dist-create <id> <mirror, dist and sections for sources.list>

Examples:
* Create a Debian Sid tree named 'sid' with main and contrib sections:
  mdt dist-create sid http://ftp.debian.org/debian unstable main contrib
* Create an Ubuntu Dapper tree named 'dapper' (multiverse is not included):
  mdt dist-create dapper http://archive.ubuntu.com/ubuntu dapper main restricted universe
EOF
}
if [ $# -lt 3 ]; then
	usage
	exit 1
fi
if [ "$1" == '--help' ]; then
	usage
	exit 1
fi

ID=$1
SUITE_HOME=$HOME/.multidistrotools/$ID
shift
SETTINGS=$*
CHROOT_DIRS="etc/apt var/lib/apt/lists/partial var/lib/dpkg var/cache/apt/archives/partial"

for d in $CHROOT_DIRS; do
    mkdir -p $SUITE_HOME/$d
done
touch $SUITE_HOME/var/lib/dpkg/status

echo "deb $SETTINGS" > $SUITE_HOME/etc/apt/sources.list
echo "deb-src $SETTINGS" | sed 's,[a-z]*/debian-installer,,g;s,  , ,g' >> $SUITE_HOME/etc/apt/sources.list
echo "You can now edit manually the sources.list file to tweak settings."
echo $SUITE_HOME/etc/apt/sources.list
echo "Then run mdt dist-apt-get $ID update"
