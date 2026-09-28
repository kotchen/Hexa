import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/content/classic_text.dart';
import 'package:yi_app/src/reading/reading.dart';
import 'package:yi_app/src/reading/reading_factory.dart';

import 'helpers/sequence_coins.dart';

/// 任务 04：第 17–32 卦（卦辞 + 六爻）的
/// 白话解释与一般行动参考完整覆盖验证。
void main() {
  ReadingFactory factoryFor(List<int> lines) => ReadingFactory(
      coins: SequenceCoins(coinsFor(lines)),
      clock: () => DateTime(2026, 9, 28));

  /// 从条目标签解析卦名并取卦序，如「泽雷随 · 初九」→ 17。
  int guaNumberOf(SelectedText t) =>
      ClassicLibrary.forName(t.label.substring(0, t.label.indexOf(' · '))).number;

  const actionBoundary = '以上为应用提供的一般性行动参考，并非对未来的确定预测。';

  group('内容库：第 17–32 卦每条经文的白话解释与行动参考齐全', () {
    test('卦辞与六条爻辞全部提供原创解读，无缺项', () {
      for (var n = 17; n <= 32; n++) {
        final g = ClassicLibrary.forNumber(n);
        expect(g.guaCiVernacular, isNotNull, reason: '${g.name} 卦辞白话');
        expect(g.guaCiAction, isNotNull, reason: '${g.name} 卦辞行动参考');
        expect(g.yaoCiVernacular, hasLength(6), reason: g.name);
        expect(g.yaoCiAction, hasLength(6), reason: g.name);
        for (var i = 0; i < 6; i++) {
          expect(g.yaoCiVernacular![i], isNotNull, reason: '${g.name} 第 ${i + 1} 爻白话');
          expect(g.yaoCiAction![i], isNotNull, reason: '${g.name} 第 ${i + 1} 爻行动参考');
          expect(g.yaoCiVernacular![i]!.length, greaterThan(30), reason: '${g.name} 第 ${i + 1} 爻白话过短');
          expect(g.yaoCiAction![i]!.length, greaterThan(30), reason: '${g.name} 第 ${i + 1} 爻行动参考过短');
          expect(g.yaoCiAction![i], contains('一般性行动参考'), reason: '${g.name} 第 ${i + 1} 爻缺边界');
          expect(g.yaoCiAction![i], contains('确定预测'), reason: '${g.name} 第 ${i + 1} 爻缺边界');
        }
      }
    });

    test('同一卦六爻白话解释各不相同（体现爻位递进，避免模板化）', () {
      for (var n = 17; n <= 32; n++) {
        final g = ClassicLibrary.forNumber(n);
        expect(g.yaoCiVernacular!.toSet(), hasLength(6), reason: g.name);
        expect(g.yaoCiAction!.toSet(), hasLength(6), reason: g.name);
      }
    });

    test('行动参考均保留边界表述；白话解释忠实关联对应原文', () {
      for (var n = 17; n <= 32; n++) {
        final g = ClassicLibrary.forNumber(n);
        // 边界表述完整（行动参考统一以边界句收尾）。
        expect(g.guaCiAction!.endsWith(actionBoundary), isTrue, reason: '${g.name} 卦辞');
        for (var i = 0; i < 6; i++) {
          expect(g.yaoCiAction![i]!.endsWith(actionBoundary), isTrue,
              reason: '${g.name} 第 ${i + 1} 爻');
          // 白话解释须能从原文逐字摘出关键字（逐条关联原文，非通用文案）。
          final stripped = g.yaoCi[i].replaceAll(RegExp('[，。；：？]'), '');
          final key =
              stripped.length >= 4 ? stripped.substring(0, 4) : stripped;
          final grams = [
            for (var j = 0; j + 2 <= key.length; j++) key.substring(j, j + 2),
          ];
          expect(
            grams.any((gram) => g.yaoCiVernacular![i]!.contains(gram)),
            isTrue,
            reason: '${g.name} 第 ${i + 1} 爻白话未关联原文',
          );
        }
        // 卦辞白话同样须关联卦辞原文。
        final gStripped = g.guaCi.replaceAll(RegExp('[，。；：？]'), '');
        final gKey =
            gStripped.length >= 4 ? gStripped.substring(0, 4) : gStripped;
        final gGrams = [
          for (var j = 0; j + 2 <= gKey.length; j++) gKey.substring(j, j + 2),
        ];
        expect(
          gGrams.any((gram) => g.guaCiVernacular!.contains(gram)),
          isTrue,
          reason: '${g.name} 卦辞白话未关联原文',
        );
      }
    });
  });

  group('业务入口：4096 穷举验证 17–32 卦选中条目的解读覆盖', () {
    test('凡引用第 17–32 卦的选中经文均有白话与行动参考，覆盖本卦与变卦引用；'
        '第 33 卦以后（姤卦辞任务 01 已批准样例除外）仍为 null', () {
      var coveredPrimary = 0; // 命中 17–32 卦的条目数（证明穷举确实覆盖）
      var coveredBen = 0; // 本卦引用命中
      var coveredBian = 0; // 变卦引用命中（跨本卦与变卦）
      var unfinishedAfter32 = 0; // 33 卦以后保持未完成
      for (var mask = 0; mask < 4096; mask++) {
        final lines = List.generate(6, (i) {
          final coin = (mask >> (i * 2)) & 3;
          return const [6, 7, 8, 9][coin];
        });
        final r = factoryFor(lines).cast('穷举验证');
        expect(r.selectedTexts, isNotEmpty);
        final ben = r.benGuaNumber;
        final bian = r.bianGuaNumber ?? -1;
        for (final t in r.selectedTexts) {
          final n = guaNumberOf(t);
          if (n >= 17 && n <= 32) {
            coveredPrimary++;
            if (n == ben) coveredBen++;
            if (n == bian) coveredBian++;
            expect(t.vernacular, isNotNull, reason: t.label);
            expect(t.actionReference, isNotNull, reason: t.label);
            expect(t.actionReference, contains('一般性行动参考'), reason: t.label);
            expect(t.actionReference, contains('确定预测'), reason: t.label);
          } else if (n > 32) {
            unfinishedAfter32++;
            if (t.label == '天风姤 · 卦辞') {
              // 任务 01 已批准的姤卦辞样例解读，属经批准的既有例外。
              expect(t.vernacular, isNotNull, reason: t.label);
              expect(t.actionReference, isNotNull, reason: t.label);
            } else {
              expect(t.vernacular, isNull, reason: '$t.label 不得误标为完成');
              expect(t.actionReference, isNull, reason: '$t.label 不得误标为完成');
            }
          }
        }
      }
      // 穷举必须真正命中两条覆盖范围与未完成范围。
      expect(coveredPrimary, greaterThan(0));
      expect(coveredBen, greaterThan(0));
      expect(coveredBian, greaterThan(0));
      expect(unfinishedAfter32, greaterThan(0));
    });

    test('五变路径：损之遁取遁上九，遁为第 33 卦仍显示未完成', () {
      final r = factoryFor([9, 9, 6, 6, 6, 7]).cast('问退出');
      expect(r.changingPositions, [1, 2, 3, 4, 5]);
      expect(r.benGuaName, '山泽损');
      expect(r.bianGuaName, '天山遁');
      final t = r.selectedTexts.single;
      expect(t.label, '天山遁 · 上九');
      expect(t.original, '上九：肥遯，无不利。');
      // 遁在第 33 卦：不得冒充完成。
      expect(t.vernacular, isNull);
      expect(t.actionReference, isNull);
    });

    test('五变路径取到变卦中第 17–32 卦爻辞时呈现完整解读（跨卦引用无缺项）', () {
      // 找一条五变输入，其变卦落在第 17–32 卦范围内。
      var found = false;
      for (var mask = 0; mask < 4096 && !found; mask++) {
        final lines = List.generate(6, (i) {
          final coin = (mask >> (i * 2)) & 3;
          return const [6, 7, 8, 9][coin];
        });
        final changing = [for (var i = 0; i < 6; i++) if (lines[i] == 6 || lines[i] == 9) i + 1];
        if (changing.length != 5) continue;
        final r = factoryFor(lines).cast('跨卦验证');
        if (r.bianGuaNumber != null && r.bianGuaNumber! >= 17 && r.bianGuaNumber! <= 32) {
          final t = r.selectedTexts.single;
          expect(t.vernacular, isNotNull, reason: t.label);
          expect(t.actionReference, isNotNull, reason: t.label);
          found = true;
        }
      }
      expect(found, isTrue, reason: '穷举内应存在五变且变卦在 17–32 的路径');
    });
  });
}
