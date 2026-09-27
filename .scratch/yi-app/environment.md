# 开发环境检查

检查日期：2026-09-27。此文件记录事实与候选方案，不代表技术选型已获确认。

## 本机

- macOS 26.2，arm64。
- 当前 PATH 中未找到 flutter 或 dart 命令；尚不能断定其他目录没有安装。
- xcode-select -p 返回 /Library/Developer/CommandLineTools。
- xcodebuild -version 无法运行，提示当前开发目录为 Command Line Tools，需要完整 Xcode。
- 项目已存在 Git 状态及暂存文件；本次不改动已有暂存区。

## 技术候选

仍建议评估 Flutter + Dart，以覆盖首版 macOS 桌面与后续 Windows、iOS、Android 目标。首版应生成桌面应用，不生成浏览器应用。

Flutter 官方 macOS 环境说明要求安装 Flutter、配置完整 Xcode，并通过 flutter doctor -v 和 flutter devices 验证。涉及原生插件时按插件需求配置依赖。

来源：https://docs.flutter.dev/platform-integration/macos/setup

## 后续初始化

选型确认后补齐工具链，创建 macOS 工程，先验证测试、构建以及独立打开 .app 的路径，再实施起卦和内容功能。公开分发与商店上架不属于当前自用首版范围。
