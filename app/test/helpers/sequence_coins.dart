import 'package:yi_app/src/domain/casting.dart';

/// 测试共用：按预设序列返回钱币的可控 CoinSource。
class SequenceCoins implements CoinSource {
  SequenceCoins(this.values);
  final List<int> values;
  int _index = 0;

  @override
  int nextCoin() => values[_index++];
}

/// 由六爻数值（6/7/8/9）展开为 18 枚钱币序列。
List<int> coinsFor(List<int> lines) {
  final coins = <int>[];
  for (final line in lines) {
    final threes = line - 6; // 6→0 7→1 8→2 9→3
    coins.addAll([for (var i = 0; i < 3 - threes; i++) 2]);
    coins.addAll([for (var i = 0; i < threes; i++) 3]);
  }
  return coins;
}
