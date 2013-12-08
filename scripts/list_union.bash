#!/bin/bash

usage() {
	cat >/dev/stdout <<EOF
Merges the two files given as arguments. If one of the files is
'-', stdin is used instead.
EOF
}

if [ "$1" == '--help' -o $# -ne 2 ]; then
	usage
	exit 1
fi

cat $1 $2 | sort | uniq
