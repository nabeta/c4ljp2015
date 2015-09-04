#!/usr/bin/ruby
require 'csv'
require 'optparse'
require 'library_stdnums'
require 'sqlite3'

opts = ARGV.getopts('l:')

db = SQLite3::Database.new("erms.db")
sql = <<EOS
CREATE TABLE IF NOT EXISTS journals (
  issn varchar(8),
  price integer,
  title varchar(255)
);
EOS
db.execute(sql)

csv = CSV.table(open(opts['l']), col_sep: "\t")
csv.each do |line|
  # ISSNが正しければ処理を続け、不正ならエラーで終了する
  if StdNum::ISSN.valid?(line[:issn])
    # ハイフンを削除する
    issn = StdNum::ISSN.normalize(line[:issn])
    sql = 'INSERT INTO journals (issn, price) VALUES (?, ?)'
    db.execute(sql, issn, line[:price].to_i)
    puts "#{line[:issn]}\t#{line[:price]}"
  else
    puts "Invalid ISSN: #{line[:issn]}"
  end
end

db.close

