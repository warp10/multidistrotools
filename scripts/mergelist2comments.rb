#!/usr/bin/ruby
# This script reads a YAML output kindly provided by sistpoty on stdin, and
# outputs a list of packages suitable for versions2html.

require 'yaml'
require 'pp'

lines = YAML::load(STDIN.read)
Package = Struct::new('Package', :debian, :ubuntu, :bugid, :state, :assignee)
pkgs = Hash::new
def bugstate(n)
  if n == 0
    return 'Unassigned'
  elsif n == 1
    return 'Assigned'
  elsif n == 2
    return 'Fixed'
  else
    return 'Unknown'
  end
end
		
lines.each do |l|
  pkgs[l['sourcepackage']] = Package::new(l['unstableversion'], l['dapperversion'], l['bugid'], bugstate(l['bugstate']), l['assignee'])
end

pkgs.each_pair do |n, p|
  if p.state == 'Unassigned'
    if p.assignee != nil
      state = "Unassigned (last: #{p.assignee} <a href=\"http://launchpad.net/bugs/#{p.bugid}\">#{p.bugid}</a>)"
    else
      state = "Unassigned"
    end
  elsif p.state == 'Assigned'
    state = "Accepted (#{p.assignee} <a href=\"http://launchpad.net/bugs/#{p.bugid}\">#{p.bugid}</a>)"
  elsif p.state == 'Fixed'
    state = "Fixed (#{p.assignee} <a href=\"http://launchpad.net/bugs/#{p.bugid}\">#{p.bugid}</a>)"
  else p.state == 'Unknown'
    state = 'Unknown (bug?)'
  end
  puts "#{n} >=#{p.debian} ANY #{state}"
end
