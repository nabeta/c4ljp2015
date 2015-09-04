#!/usr/bin/ruby
require 'csv'
require 'optparse'
require 'library_stdnums'

opts = ARGV.getopts('l:')

csv = CSV.table(open(opts['l']), col_sep: "\t")
csv.each do |line|
  # ISSNが正しければ処理を続け、不正ならエラーで終了する
  if StdNum::ISSN.valid?(line[:issn])
    # ハイフンを削除する
    issn = StdNum::ISSN.normalize(line[:issn])
    puts "#{line[:issn]}\t#{line[:price]}"
  else
    puts "Invalid ISSN: #{line[:issn]}"
  end
end
