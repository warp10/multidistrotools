#!/bin/bash
# 
# dist-apt-cache.bash
# - Lucas Nussbaum <lucas@lucas-nussbaum.net>
usage() {
	cat > /dev/stdout <<EOF
This script runs apt-cache inside an APT tree that you have created
before using mdt dist-create.

Syntax:
  mdt dist-apt-cache <id> <apt-cache parameters>

Examples:
  mdt dist-apt-cache search foo
EOF
}
if [ $# -lt 2 ]; then
	usage
	exit 1
fi
if [ "$1" == '--help' ]; then
	usage
	exit 1
fi

ID=$1
if [ ! -d $HOME/.multidistrotools/$ID ]; then
	echo "APT tree named $ID doesn't exist in $HOME/.multidistrotools."
	exit 1
fi
shift
apt-cache -o Dir=$HOME/.multidistrotools/$ID/ -o Dir::State::status=$HOME/.multidistrotools/$ID/var/lib/dpkg/status $*
