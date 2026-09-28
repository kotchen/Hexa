#!/bin/bash
# yi_app 构建脚手架：SDK 探测 + 测试 + release 构建 + 覆盖 dist/。
# 用法: build_app.sh {test|build|clean}
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$REPO_ROOT/app"
DIST_DIR="$REPO_ROOT/dist"
BUILT_APP="$APP_DIR/build/macos/Build/Products/Release/yi_app.app"

find_flutter() {
  if command -v flutter >/dev/null 2>&1; then
    command -v flutter
    return
  fi
  local candidate="$HOME/development/flutter/bin/flutter"
  if [ -x "$candidate" ]; then
    echo "$candidate"
    return
  fi
  echo "错误：未找到 Flutter SDK（PATH 与 ~/development/flutter 均未命中）" >&2
  exit 1
}

FLUTTER="$(find_flutter)"

cmd_test() {
  (cd "$APP_DIR" && "$FLUTTER" test)
}

cmd_build() {
  (cd "$APP_DIR" && "$FLUTTER" build macos --release)
  if [ ! -d "$BUILT_APP" ]; then
    echo "错误：构建产物不存在：$BUILT_APP" >&2
    exit 1
  fi
  rm -rf "$DIST_DIR/yi_app.app"
  mkdir -p "$DIST_DIR"
  cp -R "$BUILT_APP" "$DIST_DIR/yi_app.app"
  echo "已覆盖拷贝到 $DIST_DIR/yi_app.app"
}

cmd_clean() {
  (cd "$APP_DIR" && "$FLUTTER" clean)
  rm -rf "$DIST_DIR/yi_app.app"
  echo "已清理 flutter 构建目录与 dist/yi_app.app"
}

case "${1:-}" in
  test)  cmd_test ;;
  build) cmd_build ;;
  clean) cmd_clean ;;
  *)
    echo "用法: build_app.sh {test|build|clean}" >&2
    exit 2
    ;;
esac
