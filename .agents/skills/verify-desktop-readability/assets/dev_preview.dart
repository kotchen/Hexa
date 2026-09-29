import 'dart:async';

import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/domain/casting.dart';
import 'src/reading/reading.dart';
import 'src/reading/reading_factory.dart';
import 'src/ui/result_page.dart';

/// 临时开发预览入口（可读性核对用，用后删除，不进正式构建）。
///
/// 以 --dart-define=PREVIEW=<key> 选择固定卦例；每个 case 是一组六爻数值
/// （6/7/8/9，自下而上）。新增 case 时务必用 test/classic_library_test.dart
/// 的卦象表核对本卦与变卦，不要手推。
void main() {
  const preview = String.fromEnvironment('PREVIEW', defaultValue: 'a');
  final lines = switch (preview) {
    // 'short' => [ ... ], // 示例：短文本条目（一变取单爻）
    // 'two' => [ ... ],   // 示例：两爻变并读、主次标注
    _ => [9, 7, 7, 7, 7, 7], // 默认样例
  };
  final reading = ReadingFactory(
    coins: _FixedCoins(_coinsFor(lines)),
    clock: () => DateTime(2026, 9, 28),
  ).cast('可读性核对样例');
  runApp(_PreviewApp(reading: reading));
}

List<int> _coinsFor(List<int> lines) {
  final coins = <int>[];
  for (final line in lines) {
    final threes = line - 6;
    coins.addAll([for (var i = 0; i < 3 - threes; i++) 2]);
    coins.addAll([for (var i = 0; i < threes; i++) 3]);
  }
  return coins;
}

class _FixedCoins implements CoinSource {
  _FixedCoins(this.values);
  final List<int> values;
  int _index = 0;

  @override
  int nextCoin() => values[_index++];
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp({required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();
    // 字体加载后文本会回流、内容高度变化，单次 jumpTo 会不到位；
    // 周期性跳到底部，直到布局稳定。
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (controller.hasClients) {
        controller.jumpTo(controller.position.maxScrollExtent);
      }
      if (timer.tick >= 20) timer.cancel();
    });
    return MaterialApp(
      title: '周易卜卦（预览）',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: YiApp.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: YiApp.vermilion,
          primary: YiApp.vermilion,
          surface: YiApp.paper,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: YiApp.ink,
            fontFamily: 'Songti SC',
            height: 1.6,
          ),
        ),
      ),
      // macOS 桌面端 ListView 默认不继承 PrimaryScrollController，
      // 必须显式声明自动继承，否则页面不滚动。
      home: PrimaryScrollController(
        controller: controller,
        automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
        scrollDirection: Axis.vertical,
        child: ResultPage(reading: reading),
      ),
    );
  }
}
