#!/bin/bash
# 
# dist-apt-cache.bash
# - Lucas Nussbaum <lucas@lucas-nussbaum.net>
usage() {
	cat > /dev/stdout <<EOF
This script runs grep-dctrl inside an APT tree that you have created
before using mdt dist-create, but only on Sources files.

Syntax:
  mdt dist-grep-dctrl-sources <id> <grep-dctrl parameters>

Examples:
  mdt dist-grep-dctrl-sources dapper -F Section -s Package -n universe
  (lists all packages in the universe section)
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
grep-dctrl $* $HOME/.multidistrotools/$ID/var/lib/apt/lists/*_Sources
