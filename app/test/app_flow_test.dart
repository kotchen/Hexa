import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/app.dart';

void main() {
  Widget buildSubject() {
    return const YiApp();
  }

  testWidgets('空问题不能提交，并有明确提示', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('起卦'));
    await tester.pumpAndSettle();

    expect(find.textContaining('请输入'), findsOneWidget);
    // 仍在首页，未进入动画页
    expect(find.text('起卦'), findsOneWidget);
  });

  testWidgets('输入问题后起卦，进入动画页', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '明天是否适合启动新项目');
    await tester.tap(find.text('起卦'));
    // 第一帧处理点击，第二帧导航入栈
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('跳过'), findsOneWidget);
  });

  testWidgets('跳过动画后得到结果，问题与结果关联', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '明天是否适合启动新项目');
    await tester.tap(find.text('起卦'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(find.textContaining('开发样例'), findsWidgets);
    expect(find.text('明天是否适合启动新项目'), findsOneWidget);
    expect(find.textContaining('潜龙勿用'), findsWidgets);
  });

  testWidgets('不跳过动画播完得到同一结果', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '同一个问题');
    await tester.tap(find.text('起卦'));
    // 第一帧处理点击，第二帧导航入栈，之后播完约三秒动画
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.textContaining('开发样例'), findsWidgets);
    expect(find.text('同一个问题'), findsOneWidget);
  });

  testWidgets('结果页展示本卦、变爻、变卦及区分展示的原文/白话/建议',
      (tester) async {
    // 加高测试视口，让结果页各分节都在可视范围内
    tester.view.physicalSize = const Size(1440, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'q');
    await tester.tap(find.text('起卦'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(find.textContaining('乾为天'), findsWidgets);
    expect(find.textContaining('天风姤'), findsWidgets);
    expect(find.textContaining('白话'), findsOneWidget);
    expect(find.textContaining('行动参考'), findsWidgets);
  });
}
