/// 起卦随机来源的小接口：测试注入可控序列，应用内用真实随机。
abstract class CoinSource {
  /// 返回 2 或 3，等概率由实现保证。
  int nextCoin();
}

/// 三钱法数字模拟：每枚独立取 2 或 3，三枚之和为一爻，六爻自下而上。
class CastingEngine {
  CastingEngine._();

  static const int laoYin = 6; // 老阴，变爻
  static const int shaoYang = 7; // 少阳
  static const int shaoYin = 8; // 少阴
  static const int laoYang = 9; // 老阳，变爻

  /// 用给定的钱币来源掷一爻（2+2+2=6 … 3+3+3=9）。
  static int tossYao(CoinSource coins) =>
      coins.nextCoin() + coins.nextCoin() + coins.nextCoin();

  /// 起六爻，自下而上返回。
  static List<int> castLines(CoinSource coins) =>
      List<int>.generate(6, (_) => tossYao(coins));

  /// 6/9 为变爻（老阴、老阳）。
  static bool isChanging(int line) => line == laoYin || line == laoYang;

  /// 变爻阴阳翻转：6→7（老阴变少阳），9→8（老阳变少阴），不变爻原样。
  static int flipped(int line) => switch (line) {
        laoYin => shaoYang,
        laoYang => shaoYin,
        _ => line,
      };
}
