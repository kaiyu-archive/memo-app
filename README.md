# memo-app

本アプリでは、メモの作成や削除が行えます。

## 機能
- 一覧表示
- 新規作成
- 変更
- 削除

## 準備

以下のコマンドで必要なファイルをインストールしてください。

```bash
bundle install --path vendor/bundle
```

以下のコマンドでpostgresqlをインストールして、DBを作成してください。

```bash
brew update
brew install postgresql
brew services restart postgresql

createdb memo_app

# DB を削除したい場合
# dropdb memo_app
```

## 起動

以下のコマンドでWebアプリを起動してください。

```bash
bundle exec ruby app.rb
```

そのあと、[http://127.0.0.1:4567]() にアクセスしてください。
