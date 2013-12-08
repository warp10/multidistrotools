#!/usr/bin/python

import sys

if len(sys.argv) != 3:
  print 'usage: mdt removals <removals file> <A|B> < versions'
  sys.exit(1)

sourceremovals = []

rfl = open('removals.txt').readlines()

for i in range(0, len(rfl)):
  if rfl[i].startswith('====') and i + 1 != len(rfl) and rfl[i+2].startswith('Removed the following') and rfl[i+2].find('unstable') != -1:
    start = i+4
    while 1:
      splitup = rfl[start].split('|')
      if len(splitup) == 3:
        if splitup[2].find('source') != -1:
          sourceremovals.append(splitup[0].strip())
        start += 1
      else:
        break

if sys.argv[2] == 'B':
  index = 2
else:
  index = 1

packages = sys.stdin.readlines()

for package in packages:
  split = package.split(' ')
  if split[0] in sourceremovals and split[1] == 'NOTFOUND':
    split[index] = 'REMOVED'
  sys.stdout.write(' '.join(split))

