/// 起卦动画时间轴：由经过时间推出每爻的绘制状态，见 ADR-0004。
///
/// 前导 [introMs] 毫秒「起卦中」淡入、爻不开始；之后六爻自下而上，
/// 每爻周期 [linePeriodMs] 毫秒（墨线生长 [growMs] + 停顿 [pauseMs]）；
/// 变爻落定后以 [vermilionMs] 毫秒由墨渐变朱红；末爻落定后停留
/// [outroMs] 毫秒进入结果页。全程 [totalMs] 毫秒，约三秒。
library;

/// 某一爻在某一时刻的绘制状态。
class YaoFrame {
  const YaoFrame._(this.grow, this.vermilion);

  /// 墨线生长进度 0–1；未开始为 0，落定后保持 1。
  final double grow;

  /// 墨→朱渐变进度 0–1；仅变爻在落定后增长，不变爻恒为 0。
  final double vermilion;

  bool get settled => grow >= 1;
}

class InkRevealTimeline {
  InkRevealTimeline({required List<int> lines})
    : assert(lines.length == 6, '六爻'),
      _changing = [for (var i = 0; i < 6; i++) lines[i] == 6 || lines[i] == 9];

  static const introMs = 300;
  static const growMs = 250;
  static const pauseMs = 150;
  static const linePeriodMs = growMs + pauseMs;
  static const vermilionMs = 200;
  static const outroMs = 300;
  static const totalMs = introMs + 6 * linePeriodMs + outroMs;

  final List<bool> _changing;

  /// 某一时刻六爻（自下而上）的绘制状态。
  List<YaoFrame> frameAt(int elapsedMs) =>
      List.unmodifiable([for (var i = 0; i < 6; i++) _yaoAt(i, elapsedMs)]);

  bool isFinished(int elapsedMs) => elapsedMs >= totalMs;

  YaoFrame _yaoAt(int i, int elapsedMs) {
    final start = introMs + i * linePeriodMs;
    if (elapsedMs <= start) return const YaoFrame._(0, 0);

    final grow = ((elapsedMs - start) / growMs).clamp(0.0, 1.0);
    if (grow < 1 || !_changing[i]) return YaoFrame._(grow, 0);

    final settledAt = start + growMs;
    final vermilion = ((elapsedMs - settledAt) / vermilionMs).clamp(0.0, 1.0);
    return YaoFrame._(1, vermilion);
  }
}
