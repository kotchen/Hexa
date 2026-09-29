import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/domain/casting.dart';

/// 可控钱币源：按预设序列依次返回 2 或 3。
class SequenceCoins implements CoinSource {
  SequenceCoins(this.values);
  final List<int> values;
  int _index = 0;

  @override
  int nextCoin() => values[_index++];
}

void main() {
  group('三钱法单爻', () {
    test('枚举八种钱币组合，四值计数为 1、3、3、1', () {
      final counts = <int, int>{6: 0, 7: 0, 8: 0, 9: 0};
      for (var mask = 0; mask < 8; mask++) {
        final coins = <int>[
          (mask & 1) == 0 ? 2 : 3,
          (mask & 2) == 0 ? 2 : 3,
          (mask & 4) == 0 ? 2 : 3,
        ];
        final yao = CastingEngine.tossYao(SequenceCoins(coins));
        counts[yao] = counts[yao]! + 1;
      }
      expect(counts[6], 1); // 2+2+2 老阴
      expect(counts[7], 3);
      expect(counts[8], 3);
      expect(counts[9], 1); // 3+3+3 老阳
    });
  });

  group('六爻起卦', () {
    test('六爻自下而上生成', () {
      // 初爻 2+2+2=6（老阴），其余五爻 3+3+3=9（老阳）
      final coins = <int>[2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
      final lines = CastingEngine.castLines(SequenceCoins(coins));
      expect(lines, [6, 9, 9, 9, 9, 9]);
    });

    test('6/9 为变爻，7/8 不变', () {
      expect(CastingEngine.isChanging(6), isTrue);
      expect(CastingEngine.isChanging(9), isTrue);
      expect(CastingEngine.isChanging(7), isFalse);
      expect(CastingEngine.isChanging(8), isFalse);
    });

    test('变爻阴阳翻转：6→7，9→8，其余不变', () {
      expect(CastingEngine.flipped(6), 7);
      expect(CastingEngine.flipped(9), 8);
      expect(CastingEngine.flipped(7), 7);
      expect(CastingEngine.flipped(8), 8);
    });
  });
}
