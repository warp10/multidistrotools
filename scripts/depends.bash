#!/bin/bash

usage() {
	cat >/dev/stdout <<EOF
Show the lines with are not in both files given as arguments.
If one of the files is '-', stdin is used instead.
EOF
}

if [ "$1" == '--help' -o $# -eq 0 ]; then
	usage
	exit 1
fi

REVERSE=
if [ "$1" == '--reverse' -o $1 == '-r' ]; then
	REVERSE=-r
	shift
fi

(for i in $*; do
	echo $i
done
if [ "$REVERSE" == '-r' ]; then
	LC_ALL=C apt-rdepends $REVERSE $* |grep "Reverse Depends" | awk '{print $3}'
else
	LC_ALL=C apt-rdepends $REVERSE $* |grep "Depends" | awk '{print $2}'
fi) 2>/dev/null | sort | uniq
