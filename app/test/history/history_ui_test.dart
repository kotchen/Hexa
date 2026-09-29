import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/app.dart';
import 'package:yi_app/src/history/history_controller.dart';
import 'package:yi_app/src/history/reading_store.dart';
import 'package:yi_app/src/reading/reading.dart';
import 'package:yi_app/src/reading/reading_factory.dart';
import 'package:yi_app/src/ui/cast_animation_page.dart';
import 'package:yi_app/src/ui/history_page.dart';

import '../helpers/sample_reading.dart' show sampleReading;
import '../helpers/sequence_coins.dart';

/// 前 N 次保存抛错的存储：失败注入只经过存储小接口。
class FlakyStore implements ReadingStore {
  FlakyStore({this.failuresBeforeSuccess = 1});
  final int failuresBeforeSuccess;
  int saveAttempts = 0;
  final _delegate = InMemoryReadingStore();

  @override
  Future<void> save(Reading record) async {
    saveAttempts++;
    if (saveAttempts <= failuresBeforeSuccess) {
      throw StateError('模拟保存失败（$saveAttempts）');
    }
    await _delegate.save(record);
  }

  @override
  Future<List<Reading>> list() => _delegate.list();

  @override
  Future<void> delete(String id) => _delegate.delete(id);
}

void main() {
  Widget buildSubject(
    List<int> lines, {
    ReadingFactory? factory,
    required HistoryController history,
  }) {
    return YiApp(
      factory: factory ?? ReadingFactory(coins: SequenceCoins(coinsFor(lines))),
      history: history,
    );
  }

  Future<void> submitAndSkip(WidgetTester tester, String question) async {
    await tester.enterText(find.byType(TextField), question);
    await tester.tap(find.text('起卦'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CastAnimationPage), findsOneWidget);
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();
  }

  Future<void> tapAfterScroll(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(find.text(text), 120);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('历史为空时显示空态说明', (tester) async {
    final history = HistoryController(InMemoryReadingStore());
    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7], history: history));
    await tester.pumpAndSettle();

    await tester.tap(find.text('历史'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryPage), findsOneWidget);
    expect(find.textContaining('还没有历史卦例'), findsOneWidget);
  });

  testWidgets('起卦后自动保存：结果页显示已保存，历史列表可见', (tester) async {
    final history = HistoryController(InMemoryReadingStore());
    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7], history: history));
    await tester.pumpAndSettle();

    await submitAndSkip(tester, '问新项目');
    expect(find.textContaining('已保存到本机历史'), findsOneWidget);

    await tapAfterScroll(tester, '返回，再次起卦');
    await tester.tap(find.text('历史'));
    await tester.pumpAndSettle();

    expect(find.text('问新项目'), findsOneWidget);
  });

  testWidgets('保存失败：结果保留并明示尚未保存，重试成功后不重复保存', (tester) async {
    final store = FlakyStore(failuresBeforeSuccess: 1);
    final history = HistoryController(store);
    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7], history: history));
    await tester.pumpAndSettle();

    await submitAndSkip(tester, '问签约');

    // 结果仍在内存，完整呈现；保存状态明示失败。
    expect(find.text('问签约'), findsOneWidget);
    expect(find.textContaining('乾为天'), findsWidgets);
    expect(find.textContaining('尚未保存到本机历史'), findsOneWidget);
    expect(store.saveAttempts, 1);

    // 重试同一卦例：成功、不重新起卦、不重复记录。
    await tester.tap(find.text('重试保存'));
    await tester.pumpAndSettle();

    expect(find.textContaining('已保存到本机历史'), findsOneWidget);
    expect(store.saveAttempts, 2);
    expect(history.entries, hasLength(1));
    expect(find.text('问签约'), findsOneWidget);
  });

  testWidgets('历史详情呈现保存时的快照（旧内容版本与旧用字原样保留）', (tester) async {
    final store = InMemoryReadingStore();
    // 一条保存于 classic-v1.0 的旧卦例：原文用字与白话均为当时快照。
    final old = sampleReading(
      id: 'old-1',
      contentVersion: 'classic-v1.0',
      vernacular: '旧版白话（v1.0 快照）',
    );
    await store.save(old);
    final history = HistoryController(store);
    await history.load();

    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7], history: history));
    await tester.pumpAndSettle();

    await tester.tap(find.text('历史'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(old.question));
    await tester.pumpAndSettle();

    // 详情呈现的是当时快照，不是按当前内容库重算的结果。
    expect(find.textContaining('旧版白话（v1.0 快照）'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('内容版本：classic-v1.0'),
      120,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('内容版本：classic-v1.0'), findsOneWidget);
  });

  testWidgets('删除需确认：取消保留记录，确认后删除', (tester) async {
    final store = InMemoryReadingStore();
    await store.save(sampleReading(id: 'r-1', vernacular: null));
    final history = HistoryController(store);
    await history.load();

    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7], history: history));
    await tester.pumpAndSettle();

    await tester.tap(find.text('历史'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('明天是否适合启动新项目'));
    await tester.pumpAndSettle();

    // 取消：记录保留。
    await tester.scrollUntilVisible(find.text('删除此记录'), 120);
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除此记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(history.entries, hasLength(1));
    expect(find.text('删除此记录'), findsOneWidget);
    expect(find.text('确认删除'), findsNothing);

    // 确认：删除并回到列表。
    await tester.tap(find.text('删除此记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认删除'));
    await tester.pumpAndSettle();
    expect(history.entries, isEmpty);
    expect(find.byType(HistoryPage), findsOneWidget);
    expect(find.textContaining('还没有历史卦例'), findsOneWidget);
  });

  testWidgets('历史回看、返回与重复点击不会意外重新起卦', (tester) async {
    // 钱币序列只够起一次卦（18 枚）：任何意外重新起卦都会抛错。
    final store = InMemoryReadingStore();
    final history = HistoryController(store);
    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7], history: history));
    await tester.pumpAndSettle();

    await submitAndSkip(tester, '只起一次');

    await tapAfterScroll(tester, '返回，再次起卦');
    // 回到首页后重复点击起卦：清空问题后点击，得到空问题提示，不生成新卦例。
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('起卦'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('历史'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('只起一次'));
    await tester.pumpAndSettle();
    await tapAfterScroll(tester, '返回');

    expect(history.entries, hasLength(1));
  });
}
