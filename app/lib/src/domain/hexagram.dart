/// 六爻卦象 → 卦名映射。
///
/// 六爻自下而上；下三爻为下卦（内卦），上三爻为上卦（外卦）。
/// 每卦三爻，阳爻记 1、阴爻记 0，自下而上组成三位，得索引：
/// 0=坤 1=震 2=坎 3=兑 4=艮 5=离 6=巽 7=乾。
/// 表按 [上卦索引][下卦索引] 取卦名（通行本六十四卦）。
class HexagramMap {
  HexagramMap._();

  static bool _isYang(int line) => line == 7 || line == 9;

  static int _trigramIndex(List<int> threeLines) {
    var bits = 0;
    for (var i = 0; i < 3; i++) {
      if (_isYang(threeLines[i])) bits |= 1 << i;
    }
    return bits;
  }

  /// [upper][lower]，行=上卦，列=下卦；索引顺序 坤震坎兑艮离巽乾。
  static const List<List<String>> _names = [
    // 下卦：坤        震        坎        兑        艮        离        巽        乾
    [
      '坤为地', '地雷复', '地水师', '地泽临', '地山谦', '地火明夷', '地风升', '地天泰'
    ], // 上坤
    [
      '雷地豫', '震为雷', '雷水解', '雷泽归妹', '雷山小过', '雷火丰', '雷风恒', '雷天大壮'
    ], // 上震
    [
      '水地比', '水雷屯', '坎为水', '水泽节', '水山蹇', '水火既济', '水风井', '水天需'
    ], // 上坎
    [
      '泽地萃', '泽雷随', '泽水困', '兑为泽', '泽山咸', '泽火革', '泽风大过', '泽天夬'
    ], // 上兑
    [
      '山地剥', '山雷颐', '山水蒙', '山泽损', '艮为山', '山火贲', '山风蛊', '山天大畜'
    ], // 上艮
    [
      '火地晋', '火雷噬嗑', '火水未济', '火泽睽', '火山旅', '离为火', '火风鼎', '火天大有'
    ], // 上离
    [
      '风地观', '风雷益', '风水涣', '风泽中孚', '风山渐', '风火家人', '巽为风', '风天小畜'
    ], // 上巽
    [
      '天地否', '天雷无妄', '天水讼', '天泽履', '天山遁', '天火同人', '天风姤', '乾为天'
    ], // 上乾
  ];

  /// 六爻数值（自下而上，6/7/8/9）→ 卦名。
  static String nameFor(List<int> lines) {
    assert(lines.length == 6);
    final lower = _trigramIndex(lines.sublist(0, 3));
    final upper = _trigramIndex(lines.sublist(3, 6));
    return _names[upper][lower];
  }

  /// 爻位称呼：位置 1–6（自下而上）。初爻称「初九/初六」，上爻称「上九/上六」。
  static String positionName(int position, {required bool yang}) {
    final yinYang = yang ? '九' : '六';
    return switch (position) {
      1 => '初$yinYang',
      6 => '上$yinYang',
      _ => '$yinYang${_chineseDigit(position)}',
    };
  }

  static String _chineseDigit(int position) => switch (position) {
        2 => '二',
        3 => '三',
        4 => '四',
        5 => '五',
        _ => throw ArgumentError('爻位须为 1–6'),
      };
}
