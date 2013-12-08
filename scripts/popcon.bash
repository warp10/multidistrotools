#!/bin/bash
# 
# popcon.bash
# - Lucas Nussbaum <lucas@lucas-nussbaum.net>

usage() {
cat > /dev/stdout <<EOF
This script gives the packages from http://popcon.debian.org/by_inst

Examples:
  mdt popcon > list
EOF
}

if [ "$1" == '--help' ]; then
	usage
	exit
fi

wget -q -O /dev/stdout http://popcon.debian.org/by_inst | grep -v "^#" | awk '{print $2}'
