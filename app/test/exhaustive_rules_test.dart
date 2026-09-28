import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/domain/casting.dart';
import 'package:yi_app/src/domain/hexagram.dart';
import 'package:yi_app/src/domain/reading_rules.dart';
import 'package:yi_app/src/reading/reading_factory.dart';

void main() {
  group('4096 种六爻输入穷举', () {
    test('变爻位置、变卦映射、取辞分支与内容解析全部合法', () {
      const values = [6, 7, 8, 9];
      var checked = 0;
      for (var mask = 0; mask < 4096; mask++) {
        final lines = <int>[
          for (var i = 0; i < 6; i++) values[(mask >> (i * 2)) & 3],
        ];
        final changing = <int>[
          for (var i = 0; i < 6; i++)
            if (CastingEngine.isChanging(lines[i])) i + 1,
        ];

        // 变卦：仅变爻翻转；变卦与本卦恰好在变爻位上阴阳相反
        final bianLines = lines.map(CastingEngine.flipped).toList();
        final benName = HexagramMap.nameFor(lines);
        final bianName = HexagramMap.nameFor(bianLines);
        expect(benName, isNotEmpty);
        expect(bianName, isNotEmpty);
        for (var i = 0; i < 6; i++) {
          final differs = (lines[i] == 7 || lines[i] == 9) !=
              (bianLines[i] == 7 || bianLines[i] == 9);
          expect(differs, changing.contains(i + 1), reason: 'lines=$lines');
        }

        final selection = ReadingRules.select(lines);
        expect(selection.isSimplified, changing.length == 3);

        // 取辞分支与变爻数对应
        switch (changing.length) {
          case 0:
            expect(selection.kind, SelectionKind.guaCi);
            expect(selection.entries.single.label, '$benName · 卦辞');
            expect(selection.primary, isNotNull);
          case 1 || 2:
            expect(selection.kind, SelectionKind.yaoCi);
            expect(selection.entries, hasLength(changing.length));
            expect(selection.primary, isNotNull);
          case 3:
            expect(selection.kind, SelectionKind.bothGuaCiSimplified);
            expect(selection.entries, hasLength(2));
            expect(selection.entries.map((e) => e.label),
                ['$benName · 卦辞', '$bianName · 卦辞']);
            expect(selection.primary, isNull);
          case 4 || 5:
            expect(selection.kind, SelectionKind.yaoCi);
            expect(selection.entries, hasLength(6 - changing.length));
            expect(selection.primary, isNotNull);
          case 6:
            if (benName == '乾为天') {
              expect(selection.kind, SelectionKind.yong9);
            } else if (benName == '坤为地') {
              expect(selection.kind, SelectionKind.yong6);
            } else {
              expect(selection.kind, SelectionKind.guaCi);
              expect(selection.entries.single.label, '$bianName · 卦辞');
            }
          default:
            fail('变爻数不可能超过 6');
        }

        // 每条选中经文都能解析出非空原文（含白话/行动参考缺省为 null 的条目）
        final texts = ReadingFactory.resolveSelection(selection, lines);
        expect(texts, isNotEmpty);
        for (final t in texts) {
          expect(t.original, isNotEmpty, reason: '${t.label} lines=$lines');
        }
        checked++;
      }
      expect(checked, 4096);
    });
  });
}
