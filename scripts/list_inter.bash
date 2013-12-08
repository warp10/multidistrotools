#!/bin/bash

usage() {
	cat >/dev/stdout <<EOF
Show the lines in common in the two files.
If one of the files is '-', stdin is used instead.
EOF
}

if [ "$1" == '--help' -o $# -ne 2 ]; then
	usage
	exit 1
fi

cat $1 $2 | sort | awk '{ if ($0 == l) { print $0 }; l = $0 }' | uniq

