# docker-python

Pythonプロジェクト用のDocker環境のサンプルです。`uv`を使用した依存関係管理、マルチステージビルド、テスト実行環境を含んでいます。

## 機能

- `uv`を使用した高速な依存関係管理
- マルチステージDockerビルド（ビルド、テスト、プロダクション）
- FastAPIを使用したサンプルアプリケーション
- pytestを使用したユニットテスト
- docker-composeによる環境管理

## 使い方

### 1. uv.lockファイルの生成

```bash
docker compose run --rm dev uv lock
```

### 2. テストの実行

```bash
docker compose run --rm test
```

### 3. アプリケーションの起動

```bash
docker compose up app -d
```

アプリケーションは http://localhost:8000 でアクセスできます。

### 4. 開発環境での作業

```bash
docker compose run --rm dev bash
```

## Dockerコマンド

### ビルド

```bash
# プロダクションイメージ
docker build --target production -t python-app:latest .

# テストの実行
docker build --target test -t python-app:test .
```

### 実行

```bash
# プロダクション
docker run -p 8000:8000 python-app:latest

# uv.lockの更新
docker run -v $(pwd):/app python-app:dev uv lock
```