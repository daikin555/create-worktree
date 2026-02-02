# create-worktree

Git worktree をワンコマンドで作成し、環境ファイルのコピーやポートのランダム化、セットアップコマンドの実行まで自動化するシェルスクリプトです。

## 特徴

- `feature/<name>` ブランチと `.worktrees/<name>/` ディレクトリを一括作成
- 環境ファイル (`.env`, `.envrc` など) を自動コピー
- ポート番号をランダム化し、複数 worktree 間のポート競合を防止
- `.worktree.conf` による柔軟なプロジェクト別設定
- 設定ファイルなしでもデフォルト動作 (`.env` と `.envrc` のみコピー)

## 使い方

```bash
bash scripts/create_worktree.sh <feature-name>
```

```bash
# 例: user-auth 機能の開発
bash scripts/create_worktree.sh user-auth

# 結果:
#   ブランチ: feature/user-auth
#   ディレクトリ: .worktrees/user-auth/
```

## 設定

リポジトリルートに `.worktree.conf` を配置すると、動作をカスタマイズできます。

```bash
# コピーする環境ファイル
ENV_FILES=(
  ".env"
  ".envrc"
  "services/api/.env"
)

# .env 内でランダム化するポート変数名
PORT_VARS=(
  "PORT"
  "API_PORT"
)

# worktree 作成後に実行するコマンド（空文字でスキップ）
SETUP_COMMAND="make setup"
```

テンプレートは `.worktree.conf.example` を参照してください。

### 設定なしの場合

`.worktree.conf` がなくても動作します。その場合はルートの `.env` と `.envrc` のみコピーされ、ポートのランダム化やセットアップコマンドは実行されません。

## Claude Code スキルとしての利用

このスクリプトは [Claude Code](https://claude.com/claude-code) のスキルとして利用できます。`.claude/skills/create-worktree/` にシンボリックリンクまたはコピーして配置してください。

詳細は [SKILL.md](SKILL.md) を参照してください。

## worktree の削除

```bash
git worktree remove .worktrees/<feature-name>
```

## ライセンス

MIT
