import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/domain/reading_rules.dart';

void main() {
  group('取辞规则（爻位自下而上，位置 1–6）', () {
    test('零变爻：取本卦卦辞', () {
      final r = ReadingRules.select([7, 7, 7, 7, 7, 7]);
      expect(r.kind, SelectionKind.guaCi);
      expect(r.entries, hasLength(1));
      expect(r.entries.single.label, '乾为天 · 卦辞');
    });

    test('一变爻：取本卦该爻辞', () {
      // 乾初爻变：9,7,7,7,7,7
      final r = ReadingRules.select([9, 7, 7, 7, 7, 7]);
      expect(r.kind, SelectionKind.yaoCi);
      expect(r.entries, hasLength(1));
      expect(r.entries.single.label, '乾为天 · 初九');
      expect(r.entries.single.isPrimary, isTrue);
    });

    test('二变爻：取本卦两爻辞，较高为主', () {
      // 乾二、五爻变
      final r = ReadingRules.select([7, 9, 7, 7, 9, 7]);
      expect(r.kind, SelectionKind.yaoCi);
      expect(r.entries, hasLength(2));
      expect(r.primary!.label, '乾为天 · 九五');
      expect(r.secondary!.label, '乾为天 · 九二');
    });

    test('三变爻：并读本卦、变卦卦辞，不判主次，标注简化', () {
      // 乾一、二、三爻变 → 下卦全变阴 = 巽? 9→8 三个，下卦 8,8,8 = 坤 → 天地否
      final r = ReadingRules.select([9, 9, 9, 7, 7, 7]);
      expect(r.kind, SelectionKind.bothGuaCiSimplified);
      expect(r.isSimplified, isTrue);
      expect(r.entries, hasLength(2));
      expect(r.primary, isNull);
      expect(r.entries.map((e) => e.label), contains('乾为天 · 卦辞'));
      expect(r.entries.map((e) => e.label), contains('天地否 · 卦辞'));
    });

    test('四变爻：取变卦中两条原不变爻爻辞，较低为主', () {
      // 乾只有二、五不变：9,7,9,9,7,9 → 变卦 8,7,8,8,7,8 = 下巽? 8,7,8=坎(010) 上 8,7,8=坎 → 坎为水
      final r = ReadingRules.select([9, 7, 9, 9, 7, 9]);
      expect(r.kind, SelectionKind.yaoCi);
      expect(r.entries, hasLength(2));
      expect(r.primary!.label, '坎为水 · 九二');
      expect(r.secondary!.label, '坎为水 · 九五');
    });

    test('五变爻：取变卦中唯一原不变爻爻辞', () {
      // 乾只有三不变：9,9,7,9,9,9 → 变卦 8,8,7,8,8,8 = 上坤下艮 = 地山谦
      // 第三爻原为少阳（7），变卦中仍为阳爻，故称九三
      final r = ReadingRules.select([9, 9, 7, 9, 9, 9]);
      expect(r.kind, SelectionKind.yaoCi);
      expect(r.entries, hasLength(1));
      expect(r.entries.single.label, '地山谦 · 九三');
    });

    test('六变爻：乾取用九，坤取用六，其余取变卦卦辞', () {
      final qian = ReadingRules.select([9, 9, 9, 9, 9, 9]);
      expect(qian.kind, SelectionKind.yong9);
      expect(qian.entries.single.label, '乾为天 · 用九');

      final kun = ReadingRules.select([6, 6, 6, 6, 6, 6]);
      expect(kun.kind, SelectionKind.yong6);
      expect(kun.entries.single.label, '坤为地 · 用六');

      // 泰卦六爻全变（下乾上坤 → 全老阳/老阴），变卦为天地否，取变卦卦辞
      final other = ReadingRules.select([9, 9, 9, 6, 6, 6]);
      expect(other.kind, SelectionKind.guaCi);
      expect(other.entries.single.label, '天地否 · 卦辞');
    });
  });
}
