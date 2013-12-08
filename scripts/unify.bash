#!/bin/bash
# sorts and remove duplicate lines
if [ $# -eq 1 -a "$1" == '--help' ]; then
	cat > /dev/stdout <<EOF
Sorts lines and remove duplicate lines
EOF
	exit 0
fi

sort|uniq
