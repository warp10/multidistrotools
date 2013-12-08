#!/bin/bash

awk '{ if ($2 != $3) print $1 " " $2 " " $3 }'
