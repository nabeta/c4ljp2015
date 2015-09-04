#!/usr/bin/ruby
require 'csv'
require 'optparse'

opts = ARGV.getopts('l:')

csv = CSV.table(open(opts['l']), col_sep: "\t")
csv.each do |line|
  puts "#{line[:issn]}\t#{line[:price]}"
end

