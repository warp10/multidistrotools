#!/bin/bash

LC_ALL=C elinks -dump https://wiki.ubuntu.com/MOTUNotes |grep -A 1000 LEAVETHISMARKHERE |grep -B 1000 LEAVETHISMARKHERE | cut -c 2- | grep -v -E "^#"
