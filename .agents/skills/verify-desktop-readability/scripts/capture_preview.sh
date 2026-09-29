#!/bin/bash
# 启动预览应用、前置窗口、截图、退出。
# 用法: capture_preview.sh <app路径> <bundle名> <输出.png>
# 示例: capture_preview.sh build/macos/Build/Products/Debug/yi_app.app yi_app /tmp/shot.png
set -euo pipefail

APP_PATH="$1"
APP_NAME="$2"
OUT="$3"

pkill -f "Contents/MacOS/${APP_NAME}" 2>/dev/null || true
sleep 1
open "$APP_PATH"
sleep 5
pgrep -f "Contents/MacOS/${APP_NAME}" > /dev/null || { echo "应用未启动: $APP_PATH" >&2; exit 1; }
osascript -e "tell application \"${APP_NAME}\" to activate"
sleep 4
screencapture -x "$OUT"
pkill -f "Contents/MacOS/${APP_NAME}" 2>/dev/null || true
echo "已保存: $OUT"
