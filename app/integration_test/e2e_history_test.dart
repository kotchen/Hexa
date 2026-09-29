import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yi_app/src/app.dart';
import 'package:yi_app/src/history/file_reading_store.dart';
import 'package:yi_app/src/history/history_controller.dart';
import 'package:yi_app/src/ui/history_page.dart';
import 'package:yi_app/src/ui/result_page.dart';

import 'e2e_helpers.dart';

/// 任务 08 端到端验证（第二次启动，模拟退出重开）：新进程从同一真实
/// 存储目录读回上一 run 落盘的两条卦例，覆盖历史列表 → 详情快照 →
/// 删除取消 → 确认删除 → 文件同步移除。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('退出重开后历史回看、删除取消与确认（第二次启动）', (tester) async {
    expect(
      countSavedReadings(),
      2,
      reason: '依赖 e2e_create_test 第一次启动落盘的两条记录',
    );

    final history = HistoryController(FileReadingStore(e2eHistoryDir()));
    await history.load();
    await tester.pumpWidget(YiApp(history: history));
    await tester.pumpAndSettle();

    // 历史列表：两条记录均在（重启后回看）。
    await tester.tap(find.text('历史'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryPage), findsOneWidget);
    expect(find.text('端到端验证：是否适合启动新项目？'), findsOneWidget);
    expect(find.text('端到端验证：是否适合调整计划？'), findsOneWidget);

    // 详情：呈现保存时的快照与内容版本。
    await tester.tap(find.text('端到端验证：是否适合启动新项目？'));
    await tester.pumpAndSettle();
    expect(find.byType(ResultPage), findsOneWidget);
    expect(find.textContaining('白话解释（应用编写）'), findsWidgets);
    expect(find.textContaining('行动参考（应用编写，非原文）'), findsWidgets);
    await tester.scrollUntilVisible(find.textContaining('内容版本：'), 120);
    await tester.pumpAndSettle();
    expect(find.textContaining('内容版本：classic-v1.4'), findsOneWidget);

    // 删除取消：记录保留。
    await tester.scrollUntilVisible(find.text('删除此记录'), 120);
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除此记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(countSavedReadings(), 2);

    // 确认删除：记录与文件同步移除。
    await tester.tap(find.text('删除此记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认删除'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryPage), findsOneWidget);
    expect(find.text('端到端验证：是否适合启动新项目？'), findsNothing);
    expect(find.text('端到端验证：是否适合调整计划？'), findsOneWidget);
    expect(countSavedReadings(), 1);
  });
}
