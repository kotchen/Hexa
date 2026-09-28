import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/reading/sample_reading.dart';

void main() {
  group('开发样例（乾为天，初九变 → 天风姤）', () {
    final reading = SampleReading.build('开发验证用问题');

    test('明确标注为开发样例，不伪装成真实起卦', () {
      expect(reading.isDevSample, isTrue);
      expect(reading.devBadgeLabel, isNotEmpty);
    });

    test('问题与卦例关联', () {
      expect(reading.question, '开发验证用问题');
    });

    test('原文为校核后的经文', () {
      expect(reading.originalTexts.any((t) => t.contains('潜龙勿用')), isTrue);
      expect(reading.originalTexts.any((t) => t.contains('乾：元亨利贞。')), isTrue);
      expect(reading.originalTexts.any((t) => t.contains('姤：女壮，勿用取女。')), isTrue);
    });

    test('原文附出处与定位', () {
      expect(reading.sourceCitation, contains('周易'));
      expect(reading.sourceLocation, isNotEmpty);
    });

    test('白话解释与行动参考为应用原创，且与原文区分', () {
      expect(reading.vernacularText, isNotEmpty);
      expect(reading.actionReference, isNotEmpty);
      expect(reading.vernacularText, isNot(contains('潜龙勿用')));
      expect(reading.actionReference, isNot(contains('潜龙勿用')));
    });

    test('取辞依据说明存在（一变爻取本卦爻辞）', () {
      expect(reading.selectionBasis, contains('一变'));
    });
  });
}
