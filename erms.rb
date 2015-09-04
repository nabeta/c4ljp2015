#!/usr/bin/ruby
require 'csv'
require 'optparse'
require 'library_stdnums'
require 'sqlite3'

opts = ARGV.getopts('l:', 'k:', 'd:', 'e:', 'c:')

db = SQLite3::Database.new("erms.db")
sql = <<EOS
CREATE TABLE IF NOT EXISTS journals (
  issn varchar(8),
  price integer,
  title varchar(255),
  print_issn varchar(8),
  open_access integer,
  subject varchar(255),
  download integer
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

# KBARTのファイルを読み込む
if opts['k']
  kbart = CSV.table(File.open(opts['k']), col_sep: "\t")
  kbart.each do |line|
    issn = StdNum::ISSN.normalize(line[:online_identifier])
    print_issn = StdNum::ISSN.normalize(line[:print_identifier])
    result = db.execute(
      'SELECT issn FROM journals WHERE issn = ?',
      issn
    )
    unless result.empty?
      db.execute(
        'UPDATE journals SET title = ?, print_issn = ? WHERE issn = ?',
        line[:publication_title],
        print_issn,
        issn
      )
      puts "#{issn}\tfound KBART record"
    end
  end
end

# DOAJのジャーナルリストを読み込む
if opts['d']
  doaj = CSV.table(File.open(opts['d']))
  doaj.each do |line|
    issn = StdNum::ISSN.normalize(line[:journal_eissn_online_version])
    result = db.execute(
      'SELECT issn FROM journals WHERE issn = ?',
      issn
    )
    unless result.empty?
      db.execute(
        'UPDATE journals SET open_access = ? WHERE issn = ?',
        1,
        issn
      )
      puts "#{issn}\topen access"
    end
  end
end

# ESIのジャーナルリストを読み込む
# 追加されるもの: 分野情報
if opts['e']
  esi = CSV.table(open(opts['e']), col_sep: "\t")
  esi.each do |line|
    issn = StdNum::ISSN.normalize(line[:eissn])
    result = db.execute(
      'SELECT issn FROM journals WHERE issn = ?',
      issn
    )
    unless result.empty?
      db.execute(
        'UPDATE journals SET subject = ? WHERE issn = ?',
        line[:category_name],
        issn
      )
      puts "#{issn}\tfound subject"
    end
  end
end

# COUNTERの集計ファイルを読み込む
# 追加されるもの: ダウンロード数　
if opts['c']
  counter = File.open(opts['c'])
  7.times do
    counter.gets
  end

  CSV.parse(counter.read, headers: true) do |csv|
    count = csv.to_a
    count.shift(7)
    n = 0
    issn = StdNum::ISSN.normalize(csv['Online ISSN'])
    result = db.execute(
      'SELECT issn FROM journals WHERE issn = ?',
      issn
    )
    unless result.empty?
      db.execute(
        'UPDATE journals SET download = ? WHERE issn = ?',
        count[0][1],
        issn
      )
      puts "#{issn}\tfound COUNTER stat"
    end
  end
end

db.close
