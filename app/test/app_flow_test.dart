import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/app.dart';
import 'package:yi_app/src/reading/reading_factory.dart';
import 'package:yi_app/src/ui/cast_animation_page.dart';

import 'helpers/sequence_coins.dart';

void main() {
  Widget buildSubject(List<int> lines) {
    return YiApp(
      factory: ReadingFactory(coins: SequenceCoins(coinsFor(lines))),
    );
  }

  Future<void> submit(WidgetTester tester, String question) async {
    await tester.enterText(find.byType(TextField), question);
    await tester.tap(find.text('起卦'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('空问题不能提交，并有明确提示', (tester) async {
    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('起卦'));
    await tester.pumpAndSettle();

    expect(find.textContaining('请输入'), findsOneWidget);
    expect(find.text('起卦'), findsOneWidget);
  });

  testWidgets('真实起卦：结果页显示卦象、取辞依据、来源，无开发样例标注', (tester) async {
    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7]));
    await tester.pumpAndSettle();

    await submit(tester, '明天是否适合启动新项目');
    expect(find.byType(CastAnimationPage), findsOneWidget);

    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(find.text('明天是否适合启动新项目'), findsOneWidget);
    expect(find.textContaining('乾为天'), findsWidgets);
    expect(find.textContaining('天风姤'), findsWidgets);
    expect(find.textContaining('潜龙勿用'), findsWidgets);
    expect(find.text('本卦概览'), findsOneWidget);
    expect(find.text('取辞依据'), findsOneWidget);
    expect(find.text('重点原文'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('来源'), 120);
    await tester.pumpAndSettle();
    expect(find.text('来源'), findsOneWidget);
    expect(find.textContaining('通行本'), findsWidgets);
    expect(find.textContaining('ADR-0001'), findsWidgets);
    expect(find.textContaining('开发样例'), findsNothing);
  });

  testWidgets('提交期间重复点击只生成一次卦例', (tester) async {
    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7]));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '问签约');
    await tester.tap(find.text('起卦'));
    await tester.pump();
    await tester.tap(find.text('起卦'), warnIfMissed: false); // 已被阻止
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CastAnimationPage), findsOneWidget);
  });

  testWidgets('跳过动画与播完动画进入同一结果', (tester) async {
    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7]));
    await tester.pumpAndSettle();

    await submit(tester, '问出行');
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(find.text('问出行'), findsOneWidget);
    expect(find.textContaining('初九'), findsWidgets);
  });

  testWidgets('缺少白话解释的经文明确显示解读尚未完成', (tester) async {
    await tester.pumpWidget(buildSubject([7, 8, 7, 7, 7, 8])); // 泽火革（第 49 卦），无变爻
    await tester.pumpAndSettle();

    await submit(tester, '问变革时机');
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(find.textContaining('泽火革'), findsWidgets);
    expect(find.textContaining('解读尚未完成'), findsWidgets);
  });

  testWidgets('第 33–48 卦已完成条目显示白话解释与行动参考', (tester) async {
    await tester.pumpWidget(buildSubject([8, 8, 7, 7, 7, 7])); // 天山遁（第 33 卦），无变爻
    await tester.pumpAndSettle();

    await submit(tester, '问隐退时机');
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(find.textContaining('天山遁'), findsWidgets);
    expect(find.textContaining('白话解释（应用编写）'), findsOneWidget);
    expect(find.textContaining('行动参考（应用编写，非原文）'), findsOneWidget);
    expect(find.textContaining('解读尚未完成'), findsNothing);
    expect(find.textContaining('并非对未来的确定预测'), findsOneWidget);
  });

  testWidgets('第 17–32 卦已完成条目显示白话解释与行动参考', (tester) async {
    await tester.pumpWidget(buildSubject([7, 8, 8, 7, 7, 8])); // 泽雷随（第 17 卦），无变爻
    await tester.pumpAndSettle();

    await submit(tester, '问跟随取舍');
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(find.textContaining('泽雷随'), findsWidgets);
    expect(find.textContaining('白话解释（应用编写）'), findsOneWidget);
    expect(find.textContaining('行动参考（应用编写，非原文）'), findsOneWidget);
    expect(find.textContaining('解读尚未完成'), findsNothing);
    expect(find.textContaining('并非对未来的确定预测'), findsOneWidget);
  });

  testWidgets('第 1–16 卦已完成条目显示白话解释与行动参考', (tester) async {
    await tester.pumpWidget(buildSubject([7, 7, 7, 8, 7, 8])); // 水天需（第 5 卦），无变爻
    await tester.pumpAndSettle();

    await submit(tester, '问等待时机');
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(find.textContaining('水天需'), findsWidgets);
    expect(find.textContaining('白话解释（应用编写）'), findsOneWidget);
    expect(find.textContaining('行动参考（应用编写，非原文）'), findsOneWidget);
    expect(find.textContaining('解读尚未完成'), findsNothing);
    expect(find.textContaining('并非对未来的确定预测'), findsOneWidget);
  });

  testWidgets('三爻变明确标注简化读法', (tester) async {
    await tester.pumpWidget(buildSubject([9, 8, 8, 8, 9, 9])); // 风雷益之雷风恒
    await tester.pumpAndSettle();

    await submit(tester, '问转型');
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(find.textContaining('简化'), findsWidgets);
    expect(find.textContaining('不判主次'), findsWidgets);
  });

  testWidgets('返回后可主动再次起卦生成新卦例', (tester) async {
    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8]));
    await tester.pumpAndSettle();

    await submit(tester, '第一问');
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();
    expect(find.text('第一问'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('返回，再次起卦'), 120);
    await tester.pumpAndSettle();
    await tester.tap(find.text('返回，再次起卦'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '第二问');
    await tester.tap(find.text('起卦'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();
    expect(find.text('第二问'), findsOneWidget);
    expect(find.textContaining('坤为地'), findsWidgets);
  });

  testWidgets('不跳过动画播完得到同一结果', (tester) async {
    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7]));
    await tester.pumpAndSettle();

    await submit(tester, '同一个问题');
    // 播完约三秒动画
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('同一个问题'), findsOneWidget);
    expect(find.textContaining('乾为天'), findsWidgets);
  });

  testWidgets('点击画面空白处跳过动画，与播完进入同一结果', (tester) async {
    await tester.pumpWidget(buildSubject([9, 7, 7, 7, 7, 7]));
    await tester.pumpAndSettle();

    await submit(tester, '空白处跳过');
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tapAt(const Offset(20, 20)); // 页面左上角空白处
    await tester.pumpAndSettle();

    expect(find.text('空白处跳过'), findsOneWidget);
    expect(find.textContaining('初九'), findsWidgets);
  });
}
