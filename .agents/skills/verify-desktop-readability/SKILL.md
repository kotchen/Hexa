---
name: verify-desktop-readability
description: Verify readability of Flutter macOS app content in a real desktop window by launching a temporary injected-state preview, capturing screenshots, and reviewing them. Use when a task's acceptance criteria require 人工查看/截图核对可读性 (e.g. result-page text rendering checks), or whenever long/short text layout must be eyeballed in the actual app window instead of widget tests.
---

Verify that representative long/short texts render readably in the real macOS desktop window, then clean up so the shipped app is untouched.

## Procedure

1. Copy `assets/dev_preview.dart` to `app/lib/dev_preview.dart` and adjust the sample cases (input lines per case, chosen via `--dart-define=PREVIEW=<key>`). Never commit this file.
2. Determine each sample's hexagram from its six line values (7/8/9/6) by checking against the verified pattern table in `app/test/classic_library_test.dart` (1=yang/7, 0=yin/8) — do NOT hand-compute trigram stacks; hand-mapping has produced wrong-guā samples before.
3. Build the preview: `flutter build macos --debug -t lib/dev_preview.dart --dart-define=PREVIEW=<key>` (Flutter not on PATH in this project: `export PATH="$HOME/development/flutter/bin:$PATH"` first).
4. Capture one screenshot per case with `scripts/capture_preview.sh <app-path> <bundle-name> <output.png>`. The script launches the app, brings it frontmost, captures, and kills it.
5. Downscale for review: `sips -Z 1200 <shot>.png --out <shot>-small.png`, read the image, check: long text wraps cleanly, short entries render fully, multi-entry primary/subordinate badges and boundary sentences are visible, nothing overflows. Keep the full-size PNG as the record (project convention: `.scratch/yi-app/taskNN-<case>.png`).
6. Delete `app/lib/dev_preview.dart`, then re-run `flutter test`, `flutter analyze`, and `flutter build macos --release` to confirm the tree is green and the release build uses the normal entry point.

## Pitfalls encoded in the template and script

- `ResultPage`'s `ListView` does not inherit a `PrimaryScrollController` on macOS by default — the template passes `automaticallyInheritForPlatforms: TargetPlatform.values.toSet()` and `scrollDirection: Axis.vertical`, and re-jumps to `maxScrollExtent` on a timer, because `Songti SC` font loading reflows text after first layout and a single jump lands short.
- `open -a <path>` fails ("Unable to find application"); use `open <path>`. A black screenshot means the app died or was not frontmost — verify with `pgrep` and re-activate via `osascript` before capturing (both handled by the script).
- The debug build target produces `build/macos/Build/Products/Debug/yi_app.app`; the release build in `Products/Release/` is unaffected until you rebuild it.
