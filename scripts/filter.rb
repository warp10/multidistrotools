#!/usr/bin/ruby
# 
# filterlist.rb
# - Lucas Nussbaum <lucas@lucas-nussbaum.net>

def usage
  puts <<EOF
This script takes a list (list1) on STDIN, and a list (list2) as $1. It
outputs the list of lines of list1 matching a word of list2 on STDOUT.

Example:
cat listwithallpkgs | filterlist.rb mypackages > filteredlistwithallpkgs
EOF
exit(0)
end

if ARGV.length == 0 or ARGV[0] == '--help'
  usage
end

h = Hash::new(false)
IO::read(ARGV[0]).each_line do |l|
  h[l.chomp] = true
end

STDIN.each_line do |l|
  p, r = l.split(' ', 2)
  puts l if h[p]
end
