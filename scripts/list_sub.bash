#!/bin/bash

usage() {
	cat >/dev/stdout <<EOF
Substract the second file from the first file given as arguments.
If one of the files is '-', stdin is used instead.
EOF
}

if [ "$1" == '--help' -o $# -ne 2 ]; then
	usage
	exit 1
fi

diff --suppress-common-lines $1 $2 | grep -E '^<' | cut -c 3-
