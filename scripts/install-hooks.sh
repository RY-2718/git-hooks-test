#!/bin/bash

# Git hooks インストールスクリプト
# scripts/hooks/ 以下のファイルを .git/hooks/ にシンボリックリンクで配置

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_SOURCE_DIR="$SCRIPT_DIR/hooks"
GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

echo "Git hooks をインストールしています..."

# .git/hooks ディレクトリが存在するかチェック
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    echo "エラー: .git/hooks ディレクトリが見つかりません。"
    echo "このスクリプトは Git リポジトリのルートディレクトリで実行してください。"
    exit 1
fi

# hooks ソースディレクトリが存在するかチェック
if [ ! -d "$HOOKS_SOURCE_DIR" ]; then
    echo "エラー: $HOOKS_SOURCE_DIR ディレクトリが見つかりません。"
    exit 1
fi

# scripts/hooks/ 内のすべてのファイルを処理
for hook_file in "$HOOKS_SOURCE_DIR"/*; do
    if [ -f "$hook_file" ]; then
        hook_name=$(basename "$hook_file")
        target_path="$GIT_HOOKS_DIR/$hook_name"

        echo "インストール中: $hook_name"

        # 既存のファイルやリンクがある場合は削除
        if [ -e "$target_path" ]; then
            echo "  既存のファイルを削除: $target_path"
            rm -f "$target_path"
        fi

        # シンボリックリンクを作成
        echo "  シンボリックリンクを作成: $hook_file -> $target_path"
        ln -sf "$hook_file" "$target_path"

        # 実行権限を付与
        echo "  実行権限を付与: $target_path"
        chmod +x "$target_path"

        echo "  ✓ $hook_name のインストール完了"
    fi
done

echo ""
echo "Git hooks のインストールが完了しました！"
echo "インストールされた hooks:"
ls -la "$GIT_HOOKS_DIR" | grep -E "(pre-|post-)" | grep -v "\.sample" || echo "  インストールされた hooks はありません"
