#!/bin/bash

echo "MDT_VERBOSE: $MDT_VERBOSE" # set if -v or --verbose passed to mdt
echo "ARGUMENTS: $*"
echo "Reading from stdin..."
while read l; do
  echo "Read \"$l\"!"
done
