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
まず`db/baseline.sql`にデータベースの初期状態となるスキーマダンプファイルを格納します。既存のデータベースがなく新規で利用する場合は空のSQLファイルにします。このサンプルでは[Sakila Sample Database](https://dev.mysql.com/doc/sakila/en/)を初期状態として利用しています。

### dbmateマイグレーション
dbmateでマイグレーションファイルを作成し、`db/migrations/`以下に格納します。マイグレーションファイルが全く存在しないとdbmateがエラーになるため、回避策としてダミーのマイグレーションファイル`20220304100126_dummy.sql`があります。このファイルはSQLコメントしかないので、実行しても何もおきません。
dbmateのマイグレーションファイルは名前の頭にyyyymmddhhmmssがつきます。dbmateはこの部分を見て、時間順にマイグレーションを実行していきます。

### テストの実行
リポジトリにpushすると、まず`db/baseline.sql`をロードして、MySQLの初期設定が実行されます。MySQL起動が完了すると、dbmateで順次マイグレーションが実行されます。マイグレーション実行後にtbls, pt-duplicate-key-checkerが実行されます。デモなのでtbls.ymlでほとんどスルーしています。
tblsのあとpt-duplicate-key-checkerで重複したインデックスをチェックします。なお、pt-duplicate-key-checkerは重複したインデックスがあっても戻り値は0なので、テストは停止しません。

### SchemaSpyの実行
テスト実行後にSchemaSpyが実行されます。SchemaSpyの設定情報は`schemaspy.properties`ファイルに記述されています。SchemaSpyの画像出力形式にはsvgとpngがありますが、画像の特性上ベクター形式のsvgのほうがきれいです。CircleCI Serverを使っている場合は、svg形式が表示できないこともあるようです。この場合はpng形式を利用するとよいでしょう。
他にもパラメータがあるので、[SchemaSpy Command-Line Arguments](https://schemaspy.readthedocs.io/en/latest/configuration/commandline.html)を参考にしてください。
なお公式に配布されているSchemaSpyのDockerイメージに同梱されているMySQL JDBCドライバーはバージョンが古いので、MySQL8.0では接続が

### Artifactsの保存
生成されたスキーマドキュメントはArtifactsにアップロードされます。Artifactsから`index.html`を選択すると、ドキュメントを参照できます。実行したマイグレーションが適切かどうか確認します。

### S3への保存
mainブランチにマージしたときは、ArtifactsとあわせてS3に保存されます。このS3バケットをバックエンドとしたCloudFront経由でスキーマドキュメントが表示できます。このCloudFrontで配信されるドキュメントを現状の最新ドキュメントとみなします。S3アップロード後CloudFrontのキャッシュ無効化APIを実行し、古いファイルが表示されないようにしています。

## tfディレクトリ
tfディレクトリ内にOIDC認証用のIAM Role, Policyを作成するTerraformのテンプレートがあります。デモではS3とCloudFrontも利用していますが、都合によりテンプレートは入っていません。