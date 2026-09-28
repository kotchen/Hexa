import 'package:flutter/material.dart';

import 'reading/reading_factory.dart';
import 'ui/home_page.dart';

/// 米白纸感、墨色卦爻、少量朱红的简洁中式视觉。
class YiApp extends StatelessWidget {
  YiApp({super.key, ReadingFactory? factory})
      : factory = factory ?? ReadingFactory(coins: RandomCoinSource());

  final ReadingFactory factory;

  static const paper = Color(0xFFF6F1E7);
  static const ink = Color(0xFF2B2926);
  static const vermilion = Color(0xFFB3392E);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '周易卜卦',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: vermilion,
          primary: vermilion,
          surface: paper,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: ink, fontFamily: 'Songti SC', height: 1.6),
        ),
      ),
      home: HomePage(factory: factory),
    );
  }
}
