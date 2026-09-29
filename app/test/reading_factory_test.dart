import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/content/classic_text.dart';
import 'package:yi_app/src/domain/reading_rules.dart';
import 'package:yi_app/src/reading/reading_factory.dart';

import 'helpers/sequence_coins.dart';

ReadingFactory factoryFor(List<int> lines) =>
    ReadingFactory(coins: SequenceCoins(coinsFor(lines)), clock: () => DateTime(2026, 9, 28));

void main() {
  group('真实起卦生成完整卦例（独立典型用例）', () {
    test('全七：乾为天，无变爻，取卦辞', () {
      final r = factoryFor([7, 7, 7, 7, 7, 7]).cast('问事业');
      expect(r.benGuaName, '乾为天');
      expect(r.bianGuaName, isNull);
      expect(r.changingPositions, isEmpty);
      expect(r.selectedTexts, hasLength(1));
      expect(r.selectedTexts.single.original, '乾：元亨。利贞。');
      expect(r.selectedTexts.single.isPrimary, isTrue);
      expect(r.isSimplified, isFalse);
    });

    test('全八：坤为地，无变爻，取卦辞', () {
      final r = factoryFor([8, 8, 8, 8, 8, 8]).cast('问出行');
      expect(r.benGuaName, '坤为地');
      expect(r.selectedTexts.single.original, '坤：元亨。利牝马之贞。');
    });

    test('全九：乾之坤，六爻皆变，取用九', () {
      final r = factoryFor([9, 9, 9, 9, 9, 9]).cast('问变动');
      expect(r.benGuaName, '乾为天');
      expect(r.bianGuaName, '坤为地');
      expect(r.changingPositions, [1, 2, 3, 4, 5, 6]);
      expect(r.selectedTexts, hasLength(1));
      expect(r.selectedTexts.single.label, '乾为天 · 用九');
      expect(r.selectedTexts.single.original, '用九：见群龙无首，吉。');
      expect(r.selectedTexts.single.vernacular, isNotNull); // 用九解读已随任务 03 补齐
      expect(r.selectedTexts.single.actionReference, contains('确定预测'));
    });

    test('全六：坤之乾，六爻皆变，取用六', () {
      final r = factoryFor([6, 6, 6, 6, 6, 6]).cast('问合作');
      expect(r.benGuaName, '坤为地');
      expect(r.bianGuaName, '乾为天');
      expect(r.selectedTexts.single.label, '坤为地 · 用六');
      expect(r.selectedTexts.single.original, '用六：利永贞。');
    });

    test('乾初爻变：乾之姤，取初九为主读，含已审校白话解释', () {
      final r = factoryFor([9, 7, 7, 7, 7, 7]).cast('明天是否适合启动新项目');
      expect(r.benGuaName, '乾为天');
      expect(r.bianGuaName, '天风姤');
      expect(r.changingPositions, [1]);
      expect(r.primaryLabel, '乾为天 · 初九');
      final t = r.selectedTexts.single;
      expect(t.original, '初九：潜龙勿用。');
      expect(t.vernacular, isNotNull);
      expect(t.vernacular, contains('勿用'));
      expect(t.actionReference, isNotNull);
    });

    test('坤初爻变：坤之复，取初六（抓上下爻序颠倒）', () {
      final r = factoryFor([6, 8, 8, 8, 8, 8]).cast('问康复');
      expect(r.benGuaName, '坤为地');
      expect(r.bianGuaName, '地雷复');
      expect(r.primaryLabel, '坤为地 · 初六');
      expect(r.selectedTexts.single.original, '初六：履霜，坚冰至。');
    });

    test('二爻变：取本卦两爻辞，以较高爻为主', () {
      final r = factoryFor([9, 7, 7, 7, 9, 7]).cast('问取舍');
      expect(r.changingPositions, [1, 5]);
      expect(r.selectedTexts, hasLength(2));
      expect(r.primaryLabel, '乾为天 · 九五');
      expect(r.selectedTexts.map((t) => t.label), ['乾为天 · 初九', '乾为天 · 九五']);
      expect(r.selectedTexts.firstWhere((t) => t.label.endsWith('九五')).isPrimary, isTrue);
    });

    test('三爻变：并读两卦卦辞，不判主次，明确标注简化', () {
      final r = factoryFor([9, 8, 8, 8, 9, 9]).cast('问转型');
      expect(r.changingPositions, [1, 5, 6]);
      expect(r.isSimplified, isTrue);
      expect(r.primaryLabel, isNull);
      expect(r.benGuaName, '风雷益');
      expect(r.selectedTexts, hasLength(2));
      expect(r.selectedTexts.map((t) => t.label), ['风雷益 · 卦辞', '坤为地 · 卦辞']);
      expect(r.selectionBasis, contains('简化'));
    });

    test('四爻变：取变卦中两条原不变爻爻辞，以较低爻为主，不误取本卦', () {
      final r = factoryFor([9, 9, 7, 7, 9, 9]).cast('问调整');
      expect(r.changingPositions, [1, 2, 5, 6]);
      expect(r.benGuaName, '乾为天');
      expect(r.bianGuaName, '雷山小过');
      expect(r.selectedTexts.map((t) => t.label), ['雷山小过 · 九三', '雷山小过 · 九四']);
      expect(r.primaryLabel, '雷山小过 · 九三');
      expect(r.selectedTexts.first.original, '九三：弗过防之，从或戕之，凶。');
    });

    test('五爻变：取变卦中唯一原不变爻爻辞（变卦爻位阴阳按变卦判定）', () {
      final r = factoryFor([9, 9, 9, 9, 9, 7]).cast('问收官');
      expect(r.changingPositions, [1, 2, 3, 4, 5]);
      expect(r.bianGuaName, '山地剥');
      expect(r.selectedTexts, hasLength(1));
      expect(r.primaryLabel, '山地剥 · 上九');
      expect(r.selectedTexts.single.original, '上九：硕果不食，君子得舆，小人剥庐。');
    });

    test('六爻变（非乾坤）：取变卦卦辞', () {
      final r = factoryFor([9, 9, 9, 6, 6, 6]).cast('问大势');
      expect(r.benGuaName, '地天泰');
      expect(r.bianGuaName, '天地否');
      expect(r.selectedTexts.single.label, '天地否 · 卦辞');
      expect(r.selectedTexts.single.original, '否之匪人，不利君子贞，大往小来。');
    });

    test('第 49 卦（泽火革）条目解读已补齐，呈现白话与行动参考', () {
      final r = factoryFor([7, 8, 7, 7, 7, 8]).cast('问变革时机'); // 泽火革（第 49 卦），无变爻
      expect(r.benGuaName, '泽火革');
      expect(r.selectedTexts.single.vernacular, isNotNull); // 任务 06 补齐
      expect(r.selectedTexts.single.actionReference, isNotNull);
      expect(r.selectedTexts.single.actionReference, contains('确定预测'));
    });

    test('卦例带问题、时间、来源、版本与取辞依据', () {
      final r = factoryFor([9, 7, 7, 7, 7, 7]).cast('问启动');
      expect(r.question, '问启动');
      expect(r.castAt, DateTime(2026, 9, 28));
      expect(r.lines, [9, 7, 7, 7, 7, 7]);
      expect(r.sourceCitation, ClassicLibrary.sourceCitation);
      expect(r.contentVersion, ClassicLibrary.contentVersion);
      expect(r.selectionBasis, contains('ADR-0001'));
      expect(r.benGuaCi, '乾：元亨。利贞。');
      expect(r.bianGuaCi, '姤：女壮，勿用取女。');
      expect(r.benGuaNumber, 1);
      expect(r.bianGuaNumber, 44);
    });
  });

  group('取辞结果与内容库解析', () {
    test('每条选中经文都能从内容库解析出非空原文', () {
      final cases = [
        [7, 7, 7, 7, 7, 7],
        [8, 8, 8, 8, 8, 8],
        [9, 9, 9, 9, 9, 9],
        [6, 6, 6, 6, 6, 6],
        [9, 7, 7, 7, 7, 7],
        [6, 8, 8, 8, 8, 8],
        [9, 7, 7, 7, 9, 7],
        [9, 8, 8, 8, 9, 9],
        [9, 9, 7, 7, 9, 9],
        [9, 9, 9, 9, 9, 7],
        [9, 9, 9, 6, 6, 6],
      ];
      for (final lines in cases) {
        final selection = ReadingRules.select(lines);
        final texts = ReadingFactory.resolveSelection(selection, lines);
        expect(texts, isNotEmpty);
        for (final t in texts) {
          expect(t.original, isNotEmpty, reason: t.label);
          expect(t.label, isNotEmpty);
        }
      }
    });
  });
}
