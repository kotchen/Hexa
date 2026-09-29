// 任务 08 验收用一次性核对脚本（不进测试套件）：
// 程序化统计全部可选原文条目的解读完整性。
import 'package:yi_app/src/content/classic_text.dart';

void main() {
  var guaCiTotal = 0, guaCiDone = 0;
  var yaoTotal = 0, yaoDone = 0;
  var yongTotal = 0, yongDone = 0;
  var minVernacular = 1 << 30, minAction = 1 << 30;
  final boundary = '以上为应用提供的一般性行动参考，并非对未来的确定预测。';
  var boundaryOk = 0, boundaryMissing = 0;

  void check(String? v, String? a, String label) {
    if (v == null || v.isEmpty || a == null || a.isEmpty) {
      print('缺项: $label');
      return;
    }
    if (v.length < minVernacular) minVernacular = v.length;
    if (a.length < minAction) minAction = a.length;
    if (a.endsWith(boundary)) {
      boundaryOk++;
    } else {
      boundaryMissing++;
      print('缺边界句: $label');
    }
  }

  for (final g in ClassicLibrary.all) {
    guaCiTotal++;
    check(g.guaCiVernacular, g.guaCiAction, '${g.name} 卦辞');
    if (g.guaCiVernacular != null && g.guaCiAction != null) guaCiDone++;
    for (var i = 0; i < 6; i++) {
      yaoTotal++;
      final v = g.yaoCiVernacular?[i];
      final a = g.yaoCiAction?[i];
      check(v, a, '${g.name} 第${i + 1}爻');
      if (v != null && a != null) yaoDone++;
    }
    if (g.yong9 != null) {
      yongTotal++;
      check(g.yong9Vernacular, g.yong9Action, '${g.name} 用九');
      if (g.yong9Vernacular != null && g.yong9Action != null) yongDone++;
    }
    if (g.yong6 != null) {
      yongTotal++;
      check(g.yong6Vernacular, g.yong6Action, '${g.name} 用六');
      if (g.yong6Vernacular != null && g.yong6Action != null) yongDone++;
    }
  }

  print('卦数: ${ClassicLibrary.all.length}');
  print('卦辞: $guaCiDone/$guaCiTotal 完整');
  print('爻辞: $yaoDone/$yaoTotal 完整');
  print('用九/用六: $yongDone/$yongTotal 完整');
  print('行动参考边界句: 齐 $boundaryOk, 缺 $boundaryMissing');
  print('最短白话解释长度: $minVernacular 字; 最短行动参考长度: $minAction 字');
  print('内容版本: ${ClassicLibrary.contentVersion}');
}
