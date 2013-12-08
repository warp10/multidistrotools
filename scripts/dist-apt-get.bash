#!/bin/bash
# 
# dist-apt-get.bash
# - Lucas Nussbaum <lucas@lucas-nussbaum.net>
usage() {
	cat > /dev/stdout <<EOF
This script runs apt-get inside an APT tree that you have created
before using mdt dist-create.

Syntax:
  mdt dist-apt-get <id> <apt-get parameters>

Examples:
  mdt dist-apt-get sid update
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
apt-get -o Dir=$HOME/.multidistrotools/$ID/ -o Dir::State::status=$HOME/.multidistrotools/$ID/var/lib/dpkg/status $*
