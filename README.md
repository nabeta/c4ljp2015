# 電子ジャーナル利用集計スクリプト

このリポジトリでは、[Code4Lib JAPAN Conference 2015](http://wiki.code4lib.jp/wiki/C4ljp2015)での発表「[電子ジャーナルリスト徹底活用法 - 楽しい電子ジャーナル管理のために](http://wiki.code4lib.jp/wiki/C4ljp2015/presentation#.E9.9B.BB.E5.AD.90.E3.82.B8.E3.83.A3.E3.83.BC.E3.83.8A.E3.83.AB.E3.83.AA.E3.82.B9.E3.83.88.E5.BE.B9.E5.BA.95.E6.B4.BB.E7.94.A8.E6.B3.95_-_.E6.A5.BD.E3.81.97.E3.81.84.E9.9B.BB.E5.AD.90.E3.82.B8.E3.83.A3.E3.83.BC.E3.83.8A.E3.83.AB.E7.AE.A1.E7.90.86.E3.81.AE.E3.81.9F.E3.82.81.E3.81.AB.EF.BC.88.E7.94.B0.E8.BE.BA_.E6.B5.A9.E4.BB.8B.EF.BC.89)」で紹介したスクリプトを公開しています。

## 用意するもの

- Ruby
- SQLite3
- Elasticsearch
- ジャーナルリストのTSVファイル
- TSVファイルを編集できるソフトウェア（LibreOfficeなど）

## 使い方

### ジャーナルリストのインポート

```sh
$ ruby erms.rb -l local.tsv
``` 

以下のオプションがあります。

- -l ローカルのファイル（ISSNと購読価格を含んでいること）
- -k KBARTのファイル
- -d DOAJのファイル
- -e ESIのファイル
- -c COUNTERのファイル
- -s Scopusのファイル
- -j JCRのファイル

### SQLによる集計

```sh
$ sqlite3 erms.db
sqlite> .mode tabs
sqlite> .headers on
sqlite> .output result.csv
sqlite> SELECT * FROM journals;
```

result.csv というファイルに集計結果が保存されます。

### Elasticsearchによる検索

以下のElasticsearchのプラグインをインストールします。

- [elasticsearch-head](http://mobz.github.io/elasticsearch-head/)
- [CSV River Plugin for ElasticSearch](https://github.com/AgileWorksOrg/elasticsearch-river-csv)

Elasticsearchを起動した状態で、以下のコマンドを実行します。

```sh
$ curl -XPOST localhost:9200/erms/ -d @schema.json
$ curl -XPOST localhost:9200/_river/erms/_meta -d @csv_river.json
```
「SQLによる集計」で作成した result.csv を elasticsearch フォルダに移動すると、自動的にElasticsearchへのインポートが始まります。

Elasticsearchの管理画面は http://localhost:9200/_plugin/head/ で動作しています。
検索フォームは"Structured Query"タブにあります。

## 連絡先

このスクリプトは、田辺浩介([@nabeta](https://github.com/nabeta))が作成しています。

