# 01: 安装并独立打开首个卦例阅读流程

Status: done

Parent: ../spec.md

**What to build:** 建立可构建的 macOS 应用，输入问题后走完短动画与一个明确标注为开发样例的结果页，验证桌面交付路径。

**Blocked by:** None (can start immediately)

## Acceptance criteria

- [x] 重新检查并配置 Flutter 与完整 Xcode；记录无法自主完成的环境步骤，不绕过许可要求。
- [x] 建立 Flutter macOS 工程、测试入口和简洁中式基础界面。
- [x] 校核一个样例的原文来源，提供原创白话解释和行动参考；开发样例不伪装成真实随机起卦。
- [x] 空问题不能提交；动画可跳过且保持同一结果。
- [x] 生成可复制安装的 .app，从 Finder 脱离开发终端独立打开；记录实际验证。

## Context

遵循首版规格、领域术语及已接受的规则与技术决策。此任务在独立会话实施前须阅读父规格；不得把未批准的新功能加入首版。

## 实施记录（2026-09-28）

### 环境（无法自主完成的步骤已按要求交由用户执行，未绕过许可）

1. 初查：PATH 无 Flutter/Dart，无 Xcode.app，`xcode-select` 指向 Command Line Tools。
2. Flutter SDK：自动下载安装 Flutter 3.47.5 stable（arm64，注意官方同时发布 x64 包，Apple Silicon 须选 `flutter_macos_arm64_*`），位于 `~/development/flutter`。
3. 须用户执行：安装 Xcode.app（App Store，Xcode 27.0）；`sudo xcodebuild -license accept` 接受许可；打开 Xcode.app 完成"附加组件"安装（xcodebuild 必需的 CoreSimulator 等系统组件，GUI 首启完成）。
4. 完成后 `xcodebuild -checkFirstLaunchStatus` 通过。

### 工程与代码（TDD）

- 工程：`app/`（Flutter create，仅启用 macOS 平台）。
- 领域层：`lib/src/domain/`：三钱法（`CoinSource` 可注入，测试不依赖真实随机数）、六十四卦映射、取辞规则（ADR-0001 全部分支，含三变简化标注、用九/用六）。
- 样例：`lib/src/reading/sample_reading.dart`——乾为天初九变 → 天风姤，固定数据、明确标注「开发样例 · 非真实起卦结果」。
- 原文校核：乾卦卦辞「乾：元亨利贞。」、初九「潜龙勿用。」（识典古籍《周易传义大全》卷一）、姤卦卦辞「姤：女壮，勿用取女。」（通行本第 44 卦，乾上巽下）多来源一致。白话解释与行动参考为应用原创，界面与原文分开展示。
- 界面：米白纸感底、墨色卦爻、朱红点缀；空问题阻止提交并提示；约三秒动画可跳过，跳过与播完进入同一结果。

### 验证结果

- `flutter test`：27/27 通过（钱币八组合计数 1/3/3/1、固定用例、取辞各分支、空问题、跳过/播完同一结果、样例标注与出处）。
- `flutter analyze`：无问题。
- `flutter build macos --release`：成功，产物 `app/build/macos/Build/Products/Release/yi_app.app`（41.3MB）。
- 独立启动：复制到 `dist/yi_app.app` 后 `open`（等效 Finder 双击），进程自 dist 路径运行、出现在系统前台应用列表，脱离开发终端。
- 应用无任何网络依赖，主流程离线可用。
- 交付物：`/Users/yichendu/Aaron/yi/dist/yi_app.app`（可拷贝安装）；安装说明：拷贝到任意目录后双击即可（本机构建无 Gatekeeper 隔离属性）。

### 遗留说明

- 结果页由固定开发样例驱动；真实随机起卦（`CastingEngine` + `CoinSource` 已实现并测试）待内容库就位后接入界面。
- 六十四卦原文/白话内容库、卦例持久化为后续任务。
