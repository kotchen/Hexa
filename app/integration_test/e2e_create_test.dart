import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yi_app/src/app.dart';
import 'package:yi_app/src/history/file_reading_store.dart';
import 'package:yi_app/src/history/history_controller.dart';
import 'package:yi_app/src/ui/cast_animation_page.dart';
import 'package:yi_app/src/ui/result_page.dart';

import 'e2e_helpers.dart';

/// 任务 08 端到端验证（第一次启动）：真实 macOS 窗口 + 真实随机起卦 +
/// 真实文件存储（沙盒容器内目录）。覆盖：空问题提示 → 起卦 → 动画 →
/// 跳过 → 结果页完整呈现 → 自动保存落盘 → 窗口缩小 → 再次起卦。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> castAndSkip(WidgetTester tester, String question) async {
    // 真实窗口下先点按聚焦，再输入；重复 enterText 前必须重新聚焦。
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), question);
    // 真实窗口下编辑值下一帧才生效，先 pump 再提交。
    await tester.pump();
    await tester.tap(find.text('起卦'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(CastAnimationPage), findsOneWidget);
    expect(find.text('跳过'), findsOneWidget);
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();
    expect(find.byType(ResultPage), findsOneWidget);
  }

  testWidgets('起卦主流程与自动保存落盘（第一次启动）', (tester) async {
    final dir = Directory(e2eHistoryDir());
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);

    await tester.pumpWidget(
      YiApp(history: HistoryController(FileReadingStore(dir.path))),
    );
    await tester.pumpAndSettle();

    // 空问题：明确提示，不起卦。
    await tester.tap(find.text('起卦'));
    await tester.pumpAndSettle();
    expect(find.text('请输入要起卦的问题'), findsOneWidget);
    expect(countSavedReadings(), 0);

    // 第一次起卦：动画可跳过，结果完整呈现。
    await castAndSkip(tester, '端到端验证：是否适合启动新项目？');
    expect(find.text('端到端验证：是否适合启动新项目？'), findsOneWidget);
    expect(find.textContaining('白话解释（应用编写）'), findsWidgets);
    expect(find.textContaining('行动参考（应用编写，非原文）'), findsWidgets);
    expect(find.textContaining('并非对未来的确定预测'), findsWidgets);
    expect(find.textContaining('解读尚未完成'), findsNothing);
    expect(find.textContaining('已保存到本机历史'), findsOneWidget);
    expect(countSavedReadings(), 1);

    // 窗口调整（缩小渲染面）：不溢出、关键内容仍在。
    await tester.binding.setSurfaceSize(const Size(520, 420));
    await tester.pumpAndSettle();
    expect(find.text('端到端验证：是否适合启动新项目？'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
    await tester.pumpAndSettle();

    // 主动再次起卦：生成第二条独立卦例。
    await tester.scrollUntilVisible(find.text('返回，再次起卦'), 120);
    await tester.pumpAndSettle();
    await tester.tap(find.text('返回，再次起卦'));
    await tester.pumpAndSettle();
    await castAndSkip(tester, '端到端验证：是否适合调整计划？');
    expect(find.textContaining('已保存到本机历史'), findsOneWidget);
    expect(countSavedReadings(), 2);
  });
}
