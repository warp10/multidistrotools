#!/usr/bin/ruby
# 
# sort_with.rb
# - Lucas Nussbaum <lucas@lucas-nussbaum.net>

def usage
  puts <<EOF
This script takes a list (list1) on STDIN, and a list (list2) as $1. It
outputs the list of lines of list1 sorted by the order of lines of list2
on STDOUT.
EOF
exit(0)
end

if ARGV.length == 0 or ARGV[0] == '--help'
  usage
  exit
end

h = Hash::new(-1)
IO::read(ARGV[0]).split("\n").reverse.each_with_index do |l, i|
  h[l.chomp] = i
end

STDIN.readlines.map { |l| l.chomp }.sort { |a, b| h[b.split[0]] <=> h[a.split[0]] }.each do |l|
  puts l
end
