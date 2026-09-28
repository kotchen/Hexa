import 'casting.dart';
import 'hexagram.dart';

enum SelectionKind {
  /// 零变或六变（非乾坤）：取卦辞。
  guaCi,

  /// 取一爻或多条爻辞。
  yaoCi,

  /// 三变：并读本卦、变卦卦辞，不判主次，明确标注为产品简化。
  bothGuaCiSimplified,

  /// 六变，乾卦：取用九。
  yong9,

  /// 六变，坤卦：取用六。
  yong6,
}

class SelectionEntry {
  const SelectionEntry({required this.label, this.isPrimary = false});

  /// 如「乾为天 · 初九」「乾为天 · 卦辞」。
  final String label;
  final bool isPrimary;
}

class Selection {
  const Selection({
    required this.kind,
    required this.entries,
    required this.isSimplified,
  });

  final SelectionKind kind;
  final List<SelectionEntry> entries;

  /// 三变简化读法时为 true，界面须明确标注。
  final bool isSimplified;

  SelectionEntry? get primary {
    for (final e in entries) {
      if (e.isPrimary) return e;
    }
    return null;
  }

  SelectionEntry? get secondary {
    final p = primary;
    for (final e in entries) {
      if (!e.isPrimary && e != p) return e;
    }
    return null;
  }
}

/// 取辞规则（依据已接受的决策记录 ADR-0001，参考《易学启蒙·考变占》）：
/// 零变取本卦卦辞；一变取本卦该爻辞；二变取本卦两爻辞、较高为主；
/// 三变并读两卦卦辞、不判主次且标注简化；四变取变卦中对应两条原不变爻的爻辞、较低为主；
/// 五变取变卦中对应唯一原不变爻的爻辞；六变乾取用九、坤取用六，其余取变卦卦辞。
class ReadingRules {
  ReadingRules._();

  static Selection select(List<int> lines) {
    assert(lines.length == 6);
    final changing = <int>[
      for (var i = 0; i < 6; i++)
        if (CastingEngine.isChanging(lines[i])) i + 1,
    ];
    final benName = HexagramMap.nameFor(lines);
    final bianLines = lines.map(CastingEngine.flipped).toList();
    final bianName = HexagramMap.nameFor(bianLines);

    String yaoLabel(String guaName, int position, List<int> guaLines) {
      final yang = guaLines[position - 1] == 7 || guaLines[position - 1] == 9;
      return '$guaName · ${HexagramMap.positionName(position, yang: yang)}';
    }

    Selection yaoSelection(List<int> positions, List<int> guaLines,
        String guaName, bool higherPrimary) {
      final sorted = [...positions]..sort();
      final primaryPos =
          higherPrimary ? sorted.last : sorted.first;
      return Selection(
        kind: SelectionKind.yaoCi,
        isSimplified: false,
        entries: [
          for (final p in sorted)
            SelectionEntry(
              label: yaoLabel(guaName, p, guaLines),
              isPrimary: p == primaryPos,
            ),
        ],
      );
    }

    switch (changing.length) {
      case 0:
        return Selection(
          kind: SelectionKind.guaCi,
          isSimplified: false,
          entries: [SelectionEntry(label: '$benName · 卦辞', isPrimary: true)],
        );
      case 1:
        return yaoSelection(changing, lines, benName, true);
      case 2:
        return yaoSelection(changing, lines, benName, true);
      case 3:
        return Selection(
          kind: SelectionKind.bothGuaCiSimplified,
          isSimplified: true,
          entries: [
            SelectionEntry(label: '$benName · 卦辞'),
            SelectionEntry(label: '$bianName · 卦辞'),
          ],
        );
      case 4:
        final unchanged = [
          for (var p = 1; p <= 6; p++)
            if (!changing.contains(p)) p,
        ];
        return yaoSelection(unchanged, bianLines, bianName, false);
      case 5:
        final unchanged = [
          for (var p = 1; p <= 6; p++)
            if (!changing.contains(p)) p,
        ];
        return yaoSelection(unchanged, bianLines, bianName, true);
      case 6:
        if (benName == '乾为天') {
          return Selection(
            kind: SelectionKind.yong9,
            isSimplified: false,
            entries: [
              SelectionEntry(label: '$benName · 用九', isPrimary: true),
            ],
          );
        }
        if (benName == '坤为地') {
          return Selection(
            kind: SelectionKind.yong6,
            isSimplified: false,
            entries: [
              SelectionEntry(label: '$benName · 用六', isPrimary: true),
            ],
          );
        }
        return Selection(
          kind: SelectionKind.guaCi,
          isSimplified: false,
          entries: [SelectionEntry(label: '$bianName · 卦辞', isPrimary: true)],
        );
      default:
        throw StateError('变爻数不可能超过 6');
    }
  }
}
