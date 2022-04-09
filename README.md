# dbmate_migration
dbmate+SchemaSpyを組み合わせたマイグレーション管理

## 概要
CircleCIでdbmate, tbls, PerconaToolkit, SchemaSpyを実行して、MySQLデータベースのマイグレーションとスキーマのlint、スキーマ定義書の自動生成を行います。
生成した定義書はS3+CloudFrontで配信します。

## 利用データベース
MySQL 5.7
## 利用ツール
  - [dbmate(https://github.com/amacneil/dbmate)](https://github.com/amacneil/dbmate)
  - [tbls(https://github.com/k1LoW/tbls)](https://github.com/k1LoW/tbls)
  - [Percona Toolkit(https://www.percona.com/software/database-tools/percona-toolkit)](https://www.percona.com/software/database-tools/percona-toolkit)
  - [SchemaSpy(https://schemaspy.org/)](https://schemaspy.org/)

## 使い方
### 初期状態データベース
まず`db/baseline.sql`にデータベースの初期状態となるスキーマダンプファイルを格納します。既存のデータベースがなく新規に利用する場合は空のSQLファイルにします。このサンプルでは[Sakila Sample Database](https://dev.mysql.com/doc/sakila/en/)を初期状態として利用しています。

### dbmateマイグレーション
dbmateでマイグレーションファイルを作成し、`db/migrations/`以下に格納します。マイグレーションファイルが全く存在しないとdbmateがエラーになるため、回避策としてダミーのマイグレーションファイル`20220304100126_dummy.sql`があります。このファイルはSQLコメントしかないので、実行しても何も変わりません。

### テストの実行
