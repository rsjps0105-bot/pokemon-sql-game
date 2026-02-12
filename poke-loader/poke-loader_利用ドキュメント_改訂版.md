# poke-loader 利用ドキュメント（改訂版）
ポケモンSQLゲーム：**DB初期化 / 再現 / 共有** 手順（Windows + PowerShell想定）

---

## このドキュメントのゴール
このリポジトリをクローンした人が、迷わずに

- **Node.js 環境を作る**
- **MySQL を用意する**
- **DB（スキーマ＋初期データ）を復元する**
- **動作確認する**

ところまで進められるようにする。

---

## 0. 用語（最初だけ）
- **スキーマ**：テーブルの形（CREATE TABLE / 外部キー / インデックス）
- **初期データ（seed）**：最初に入れておきたいデータ（pokemon / move / location / encounter / learn など）
- **dump**：スキーマ＋データが全部入った「完全復元ファイル」

---

## 1. 前提：必要なもの（インストール）
### 1-1. Node.js（LTS推奨）
- Node.js を入れると `node` と `npm` が使えるようになります。

#### ✅ 確認コマンド（PowerShell）
```powershell
node -v
npm -v
```

### 1-2. MySQL 8系
- MySQL Server が起動していること
- `mysql` と `mysqldump` がコマンドで実行できること

#### ✅ 確認コマンド（PowerShell）
```powershell
mysql --version
mysqldump --version
```

> もし `mysqldump` が見つからない場合は、MySQL の `bin`（例: `C:\Program Files\MySQL\MySQL Server 8.4\bin`）に PATH を通します。

---

## 2. フォルダ構成（どこで何をするか）
このプロジェクトでは、基本的に以下の2箇所を使います。

```
pokemon-sql-game/                 ← プロジェクトルート（ここに .env を置く）
└─ poke-loader/                   ← DB投入・dump作成の作業場所
   ├─ import_pokemon_151.mjs
   ├─ package.json
   ├─ database/
   │  ├─ schema.sql               ← スキーマ（テーブル構造だけ）
   │  └─ data.sql                 ← 初期データ（INSERTだけ）
   └─ (その他ファイル)
```

### ✅ 重要：コマンドを打つ場所ルール
- **Node.js（npm install / node 実行）** → `pokemon-sql-game/poke-loader` で実行
- **MySQL（CREATE DATABASE / SOURCE / mysql < ...）** → どこでもいいが、**迷ったら `poke-loader` で実行**

---

## 3. 環境変数（.env）の作り方
### 3-1. `.env` を作る場所
**プロジェクトルート**（`pokemon-sql-game/`）に作ります。

例：`pokemon-sql-game/.env`

### 3-2. `.env` の例
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=あなたのパスワード
DB_NAME=poke_sql_game
DB_CHARSET=utf8mb4
```

> `.env` は **Gitにコミットしない**（パスワードが入るので）。  
> 代わりに `.env.example` を置くのが定番です。

---

## 4. セットアップ方法（どれか1つ選ぶ）
このプロジェクトでは **2通り**あります。

- **方法A（おすすめ：開発向き）**  
  スキーマ適用 → import スクリプト実行（必要なデータを作る）
- **方法B（おすすめ：配布/提出向き）**  
  schema.sql + data.sql で復元（速い・再現性が高い）

> ※「challenge系テーブルを含めない」方針なら、配布用は **方法B** が安全です。

---

# 方法A：スキーマ + import スクリプト（開発向き）

## A-1. Node依存関係を入れる（poke-loaderで実行）
**実行場所：** `pokemon-sql-game/poke-loader`

```powershell
cd .\poke-loader
npm install
```

## A-2. DBを作る（MySQL）
**実行場所：** どこでもOK（迷ったら poke-loader）

MySQLへログイン：
```powershell
mysql -u root -p
```

DB作成：
```sql
CREATE DATABASE IF NOT EXISTS poke_sql_game
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
```

## A-3. スキーマを適用する
> ここは「schema.sql」を使うのが一番わかりやすいです。

**実行場所：** `pokemon-sql-game/poke-loader`

```powershell
mysql -u root -p poke_sql_game < .\database\schema.sql
```

## A-4. 初期データを投入する（import）
**実行場所：** `pokemon-sql-game/poke-loader`

```powershell
node .\import_pokemon_151.mjs
```

> このスクリプトがDBへ接続するので、ルートの `.env` が必要です。

---

# 方法B：schema.sql + data.sql（配布/提出向き・おすすめ）

## B-1. DBを作る（MySQL）
MySQLへログイン：
```powershell
mysql -u root -p
```

DB作成：
```sql
CREATE DATABASE IF NOT EXISTS poke_sql_game
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
```

## B-2. schema → data の順で適用する（重要）
**実行場所：** `pokemon-sql-game/poke-loader`

```powershell
mysql -u root -p poke_sql_game < .\database\schema.sql
mysql -u root -p poke_sql_game < .\database\data.sql
```

> ✅ 順番は必ず **schema → data**  
> 外部キーがあるので、逆にすると失敗します。

---

## 5. 動作確認（必ずやる）
### 5-1. DBの中身を確認
MySQLへログイン：
```powershell
mysql -u root -p poke_sql_game
```

確認SQL：
```sql
SELECT id, name_ja FROM pokemon WHERE id IN (1, 4, 25);
SELECT id, name FROM location ORDER BY id;
SELECT name, type FROM move ORDER BY id;
```

期待結果（例）：
- フシギダネ / ヒトカゲ / ピカチュウ
- 1ばんどうろ / トキワの森 / ニビシティ周辺
- たいあたり / でんきショック / つるのムチ …

---

## 6. dumpを作る（共有用のバックアップ）
PowerShell の `>` で保存すると日本語が壊れることがあるので、**--result-file 推奨**。

### 6-1. 例：必要テーブルだけをdumpする（challenge系を除外する）
**実行場所：** `pokemon-sql-game/poke-loader`

```powershell
# スキーマ（構造）
mysqldump -u root -p --no-data --default-character-set=utf8mb4 poke_sql_game `
  pokemon move location encounter learn `
  --result-file=.\database\schema.sql

# データ（INSERT）
mysqldump -u root -p --no-create-info --default-character-set=utf8mb4 poke_sql_game `
  pokemon move location encounter learn `
  --result-file=.\database\data.sql
```

---

## 7. よくあるハマりポイント
### 7-1. `mysqldump` が見つからない
```powershell
where mysqldump
```
出なければ PATH 未設定の可能性が高いです。

### 7-2. 文字化けする
- PowerShellの `>` を避けて `--result-file` を使う
- `--default-character-set=utf8mb4` を付ける

### 7-3. 外部キーエラーが出る
- schema.sql → data.sql の順番を守る
- 既存の中途半端なテーブルがある場合はDBを作り直す（開発用のみ）

---

## 8. まとめ（おすすめ運用）
- **普段の開発**：方法A（importで作りながら更新）
- **配布・提出・再現**：方法B（schema.sql + data.sql）
- **challenge系を入れたくない配布**：dump時に `pokemon move location encounter learn` のように **必要テーブルだけ指定**

---
