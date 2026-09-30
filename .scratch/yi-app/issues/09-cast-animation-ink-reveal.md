# 09: 起卦动画水墨化重做与全应用纸感背景

Status: done

Parent: ../spec.md

**What to build:** 将起卦动画从「Timer 逐爻淡入」重做为一版水墨感显现动画（墨线生长、先墨后朱、视觉顿点），并把 AI 生成的宣纸纹理提升为全应用共享背景，水墨底韵仅叠于起卦页。设计与决策依据见 [ADR-0004](../../docs/adr/0004-ink-cast-animation.md)。

**Blocked by:** None (can start immediately)

## Acceptance criteria

- [x] 素材管线：`xuan-paper-texture.png` 压缩至约 2048px JPG（体积从 4MB 降至数百 KB），`ink-wash-blob.png` 保留白底 PNG，二者移入 `app/assets/images/`，pubspec 登记 `assets/images/` 目录；根目录原图不改动。
- [x] 共享纸感背景组件：首页、起卦页、结果页统一使用；结果页大段文字在纸纹上可读（手动验证）。
- [x] 起卦页：水墨底韵以 multiply 混合、约 10% 透明度叠于卦象后方。
- [x] 动画时序：AnimationController 驱动（替换 Timer）；六爻自下而上，每爻墨线从左到右生长约 250ms + 停顿约 150ms；每爻落定瞬间线条轻微回弹（视觉顿点）；变爻落定后 200ms 墨→朱渐变；末爻落定后停留约 300ms 进入结果页；全程约 3.1s。
- [x] 不加声音、不加触感。
- [x] 跳过：保留"跳过"按钮，点击画面任意处均可跳过；跳过与播完进入同一结果页，卦例不变；动画仅展示，不参与生成（spec 用户故事 6/7/20 保持）。
- [x] 测试不依赖真实等待：时钟/进度可注入，新增用例覆盖生长时序、变爻变色、跳过同结果；`flutter test` 与 `flutter analyze` 全绿。
- [x] 手动验证三秒时长、release 构建中素材正确打包、重复点击不重复起卦。

## Context

2026-09-28 会话共识：方向定水墨感（不引入铜钱道具），时长保持约三秒，AI 素材只做氛围（纸纹 + 水墨底韵），爻线代码绘制不贴图，反馈采用视觉顿点（macOS 桌面端 HapticFeedback 无效），纸纹全应用通用。共识全程见 ADR-0004。spec 的动画描述（约三秒、可跳过）与视觉语言（米白纸感、墨色、朱红）均保持有效，无需修改。

## 实施记录（2026-09-28）

### 工作方式

按用户要求改动全部在 git worktree `/Users/yichendu/Aaron/yi-cast-animation`（分支 `feat/09-cast-animation-ink-reveal`，基于 main 78a0569）完成，未触碰主工作区；实施期间主工作区有另一会话正在做 issue 02（未提交）。

### 素材管线

- `xuan-paper-texture.png`（4.0MB）→ 2048px JPG（184KB）；`ink-wash-blob.png`（731KB）→ 512px PNG（176KB，自带透明通道，无需 multiply）。
- 位于 `app/assets/images/`，pubspec 登记目录；根目录原图未动。

### 代码（TDD）

- 新模块 `lib/src/ui/ink_reveal_timeline.dart`：纯 Dart 时间轴，前导 300ms + 六爻 × 400ms（生长 250 + 停顿 150）+ 末爻后 300ms = 3000ms；变爻落定后 200ms 墨→朱。13 个测试的期望值独立取自 ADR-0004 时刻表。
- `cast_animation_page.dart` 重做：AnimationController（替代 Timer）+ `_HexagramPainter`（墨线左→右生长裁剪、墨→朱插值、落定 130ms 下沉回弹视觉顿点）；保留跳过按钮，GestureDetector 全屏可点（带 `_finished` 防重入）。
- 新组件 `paper_background.dart`：宣纸纹理全应用共享，水墨底韵 10% 透明度仅起卦页；接入首页/起卦页/结果页。
- 接缝确认（2026-09-28 会话）：测 A 时间轴纯模块、B 跳过/全屏点击同结果；不测 painter 细节与背景组件（手动验收）。

### 验证

- `flutter test` 41/41 通过（基线 27 + 时间轴 13 + 空白点击跳过 1）；`flutter analyze` 无问题。
- `flutter build macos --release` 成功（41.8MB），两张素材确认打入 .app 包。
- 提交 `deb93c0`。

### 合入（2026-09-28 傍晚）

issue 02 提交（bb1ea1f）后 rebase：`app_flow_test` 取新世界版本并迁入两个动画用例（播完同结果、空白点击跳过），home/result 取 main 新版重接 PaperBackground。rebase 后 58/58 测试通过，`--no-ff` 合入 main（7a1c1e4），主工作区复验 58/58 + analyze 无问题。worktree 与临时分支已清理。

### 遗留（2026-09-30 已闭环）

- 纸纹可读性、三秒节奏与顿点手感：用户已手动跑应用验收通过（2026-09-30）。
- 根目录两张原图（xuan-paper-texture.png / ink-wash-blob.png）：已删除。
