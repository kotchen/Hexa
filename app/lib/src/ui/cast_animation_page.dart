import 'package:flutter/material.dart';

import '../reading/reading.dart';
import 'ink_reveal_timeline.dart';
import 'paper_background.dart';
import 'result_page.dart';

/// 约三秒的水墨起卦动画；跳过与播完进入同一个结果页，卦例不变。
class CastAnimationPage extends StatefulWidget {
  const CastAnimationPage({super.key, required this.reading});

  final Reading reading;

  @override
  State<CastAnimationPage> createState() => _CastAnimationPageState();
}

class _CastAnimationPageState extends State<CastAnimationPage>
    with SingleTickerProviderStateMixin {
  late final InkRevealTimeline _timeline;
  late final AnimationController _controller;
  var _finished = false;

  @override
  void initState() {
    super.initState();
    _timeline = InkRevealTimeline(lines: widget.reading.lines);
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: InkRevealTimeline.totalMs),
          )
          ..addListener(() => setState(() {}))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) _finish();
          })
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _elapsedMs => (_controller.value * InkRevealTimeline.totalMs).round();

  void _finish() {
    if (_finished) return;
    _finished = true;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultPage(reading: widget.reading),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final intro = (_elapsedMs / InkRevealTimeline.introMs).clamp(0.0, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // 画面任意处可跳过
      onTap: _finish,
      child: Scaffold(
        body: PaperBackground(
          inkWash: true,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: intro,
                  child: const Text(
                    '起卦中',
                    style: TextStyle(fontSize: 24, letterSpacing: 6),
                  ),
                ),
                const SizedBox(height: 32),
                CustomPaint(
                  size: const Size(176, 120),
                  painter: _HexagramPainter(
                    frames: _timeline.frameAt(_elapsedMs),
                    lines: widget.reading.lines,
                    elapsedMs: _elapsedMs,
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton(onPressed: _finish, child: const Text('跳过')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 六爻自下而上绘制：墨线从左到右生长，变爻落定后由墨渐变朱红，
/// 落定瞬间线条轻微下沉回弹作视觉顿点。时序见 [InkRevealTimeline]。
class _HexagramPainter extends CustomPainter {
  _HexagramPainter({
    required this.frames,
    required this.lines,
    required this.elapsedMs,
  });

  final List<YaoFrame> frames;
  final List<int> lines;
  final int elapsedMs;

  static const _lineWidth = 160.0;
  static const _lineHeight = 10.0;
  static const _yinGap = 24.0;
  static const _spacing = 20.0; // 爻高 10 + 上下各 5 留白
  static const _bounceMs = 130;
  static const _bounceDepth = 2.0;

  static const _ink = Color(0xFF2B2926);
  static const _vermilion = Color(0xFFB3392E);

  @override
  void paint(Canvas canvas, Size size) {
    final left = (size.width - _lineWidth) / 2;
    for (var i = 0; i < 6; i++) {
      final frame = frames[i];
      if (frame.grow <= 0) continue;

      var dy = 0.0;
      if (frame.settled) {
        final sinceSettle =
            elapsedMs -
            (InkRevealTimeline.introMs +
                i * InkRevealTimeline.linePeriodMs +
                InkRevealTimeline.growMs);
        if (sinceSettle >= 0 && sinceSettle < _bounceMs) {
          dy =
              _bounceDepth *
              (1 - (sinceSettle / _bounceMs)) *
              (sinceSettle / _bounceMs) *
              4; // 下沉后回弹
        }
      }

      final paint = Paint()
        ..color = Color.lerp(_ink, _vermilion, frame.vermilion)!;
      final top = size.height - (i + 1) * _spacing + (_spacing - _lineHeight);
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(left, 0, _lineWidth * frame.grow, size.height),
      );
      final rect = Rect.fromLTWH(left, top + dy, _lineWidth, _lineHeight);
      if (lines[i] == 7 || lines[i] == 9) {
        canvas.drawRect(rect, paint);
      } else {
        final seg = (_lineWidth - _yinGap) / 2;
        canvas.drawRect(Rect.fromLTWH(left, top + dy, seg, _lineHeight), paint);
        canvas.drawRect(
          Rect.fromLTWH(left + seg + _yinGap, top + dy, seg, _lineHeight),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_HexagramPainter oldDelegate) => true; // 每帧时序都不同
}
