import 'dart:async';

import 'package:flutter/material.dart';

import '../reading/reading.dart';
import 'result_page.dart';

/// 约三秒的卦象动画；跳过与播完进入同一个结果页，卦例不变。
class CastAnimationPage extends StatefulWidget {
  const CastAnimationPage({super.key, required this.reading});

  final Reading reading;

  @override
  State<CastAnimationPage> createState() => _CastAnimationPageState();
}

class _CastAnimationPageState extends State<CastAnimationPage> {
  late final Timer _timer;
  var _revealed = 0; // 已亮出的爻数（0–6）

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() => _revealed++);
      if (_revealed >= 6) _finish();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _finish() {
    _timer.cancel();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ResultPage(reading: widget.reading)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('起卦中', style: TextStyle(fontSize: 24, letterSpacing: 6)),
            const SizedBox(height: 32),
            _HexagramFigure(lines: widget.reading.lines, revealed: _revealed),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: _finish,
              child: const Text('跳过'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 六爻自下而上绘制；阳爻实线、阴爻断线，变爻朱红。
class _HexagramFigure extends StatelessWidget {
  const _HexagramFigure({required this.lines, required this.revealed});

  final List<int> lines;
  final int revealed;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF2B2926);
    const vermilion = Color(0xFFB3392E);
    return Column(
      children: [
        for (var i = 5; i >= 0; i--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Opacity(
              opacity: i < revealed ? 1 : 0.12,
              child: _YaoBar(yang: lines[i] == 7 || lines[i] == 9, color: lines[i] == 6 || lines[i] == 9 ? vermilion : ink),
            ),
          ),
      ],
    );
  }
}

class _YaoBar extends StatelessWidget {
  const _YaoBar({required this.yang, required this.color});

  final bool yang;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const width = 160.0;
    const height = 10.0;
    if (yang) {
      return Container(width: width, height: height, color: color);
    }
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        children: [
          Expanded(child: Container(color: color)),
          const SizedBox(width: 24),
          Expanded(child: Container(color: color)),
        ],
      ),
    );
  }
}
