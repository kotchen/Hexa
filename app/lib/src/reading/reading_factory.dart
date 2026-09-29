import 'dart:math';

import '../content/classic_text.dart';
import '../domain/casting.dart';
import '../domain/hexagram.dart';
import '../domain/reading_rules.dart';
import 'reading.dart';

/// 真实随机钱币源：每枚独立等概率取 2 或 3。
class RandomCoinSource implements CoinSource {
  RandomCoinSource([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  int nextCoin() => 2 + _random.nextInt(2);
}

/// 卦例标识来源的小接口：应用注入随机实现，测试注入固定值。
abstract class IdSource {
  String nextId();
}

/// 随机标识源：128 位随机数的十六进制串。
class RandomIdSource implements IdSource {
  RandomIdSource([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  String nextId() => [
    for (var i = 0; i < 16; i++)
      _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

/// 由钱币源起卦并装配完整卦例（卦象、取辞、原文、来源）。
class ReadingFactory {
  ReadingFactory({
    required CoinSource coins,
    DateTime Function()? clock,
    IdSource? ids,
  })
    // ignore: prefer_initializing_formals
    : _coins = coins,
       _clock = clock ?? DateTime.now,
       _ids = ids ?? RandomIdSource();
  static const String castingMethod =
      '三钱法数字模拟（每枚钱币独立等概率取 2/3，三枚之和为一爻，6/7/8/9 为老阴/少阳/少阴/老阳，六爻自下而上）';
  static const String rulesBasis = '取辞规则见决策记录 ADR-0001（参考《易学启蒙·考变占》）';

  final CoinSource _coins;
  final DateTime Function() _clock;
  final IdSource _ids;

  /// 起六爻并生成卦例。一次调用只生成一次结果。
  Reading cast(String question) {
    final lines = CastingEngine.castLines(_coins);
    final selection = ReadingRules.select(lines);
    final benName = HexagramMap.nameFor(lines);
    final hasChanging = lines.any(CastingEngine.isChanging);
    final bianName = hasChanging
        ? HexagramMap.nameFor(lines.map(CastingEngine.flipped).toList())
        : null;
    final ben = ClassicLibrary.forName(benName);
    final bian = bianName != null ? ClassicLibrary.forName(bianName) : null;

    return Reading(
      id: _ids.nextId(),
      question: question,
      castAt: _clock(),
      lines: lines,
      benGuaName: benName,
      benGuaNumber: ben.number,
      benGuaCi: ben.guaCi,
      bianGuaName: bianName,
      bianGuaNumber: bian?.number,
      bianGuaCi: bian?.guaCi,
      changingPositions: [
        for (var i = 0; i < 6; i++)
          if (CastingEngine.isChanging(lines[i])) i + 1,
      ],
      selectedTexts: resolveSelection(selection, lines),
      primaryLabel: selection.primary?.label,
      selectionBasis: basisFor(lines),
      isSimplified: selection.isSimplified,
      sourceCitation: ClassicLibrary.sourceCitation,
      contentVersion: ClassicLibrary.contentVersion,
      castingMethod: castingMethod,
      rulesBasis: rulesBasis,
    );
  }

  /// 把取辞结果解析为带原文与解读的条目；每条原文必须能定位到内容库。
  static List<SelectedText> resolveSelection(
    Selection selection,
    List<int> lines,
  ) {
    final texts = <SelectedText>[];
    for (final entry in selection.entries) {
      final sep = entry.label.indexOf(' · ');
      final guaName = entry.label.substring(0, sep);
      final part = entry.label.substring(sep + 3);
      final gua = ClassicLibrary.forName(guaName);

      if (part == '卦辞') {
        texts.add(
          SelectedText(
            label: entry.label,
            original: gua.guaCi,
            isPrimary: entry.isPrimary,
            vernacular: gua.guaCiVernacular,
            actionReference: gua.guaCiAction,
          ),
        );
      } else if (part == '用九' || part == '用六') {
        final original = part == '用九' ? gua.yong9 : gua.yong6;
        if (original == null) {
          throw StateError('内容库缺 $part：${gua.name}');
        }
        texts.add(
          SelectedText(
            label: entry.label,
            original: '$part：$original',
            isPrimary: entry.isPrimary,
            vernacular: part == '用九'
                ? gua.yong9Vernacular
                : gua.yong6Vernacular,
            actionReference: part == '用九' ? gua.yong9Action : gua.yong6Action,
          ),
        );
      } else {
        final position = _positionOf(part);
        if (position == 0) throw StateError('未知爻位名：$part');
        texts.add(
          SelectedText(
            label: entry.label,
            original: '$part：${gua.yaoCi[position - 1]}',
            isPrimary: entry.isPrimary,
            vernacular: gua.yaoCiVernacular?[position - 1],
            actionReference: gua.yaoCiAction?[position - 1],
          ),
        );
      }
    }
    return texts;
  }

  /// 展示给用户的取辞依据说明。
  static String basisFor(List<int> lines) {
    final changing = <int>[
      for (var i = 0; i < 6; i++)
        if (CastingEngine.isChanging(lines[i])) i + 1,
    ];
    final unchanged = <int>[
      for (var p = 1; p <= 6; p++)
        if (!changing.contains(p)) p,
    ];
    final pos = changing.join('、');
    final benName = HexagramMap.nameFor(lines);
    final bianName = HexagramMap.nameFor(
      lines.map(CastingEngine.flipped).toList(),
    );

    return switch (changing.length) {
      0 => '本次起卦六爻皆不变，取本卦卦辞。$rulesBasis。',
      1 => '本次起卦一爻变（第 $pos 爻），取本卦该爻爻辞为阅读依据。$rulesBasis。',
      2 =>
        '本次起卦二爻变（第 $pos 爻），取本卦两条爻辞并读，以较高爻（第 ${changing.last} 爻）为主。$rulesBasis。',
      3 =>
        '本次起卦三爻变（第 $pos 爻），并读本卦（$benName）与变卦（$bianName）卦辞，不判主次。'
            '此为明确标注的简化读法，非完整传统复原。$rulesBasis。',
      4 =>
        '本次起卦四爻变（第 $pos 爻），取变卦（$bianName）中对应两条原不变爻（第 ${unchanged.join('、')} 爻）的爻辞并读，'
            '以较低爻（第 ${unchanged.first} 爻）为主。$rulesBasis。',
      5 =>
        '本次起卦五爻变（第 $pos 爻），取变卦（$bianName）中对应唯一原不变爻（第 ${unchanged.single} 爻）的爻辞。$rulesBasis。',
      _ =>
        benName == '乾为天'
            ? '本次起卦六爻皆变，本卦为乾，取用九辞。$rulesBasis。'
            : benName == '坤为地'
            ? '本次起卦六爻皆变，本卦为坤，取用六辞。$rulesBasis。'
            : '本次起卦六爻皆变，本卦非乾坤，取变卦（$bianName）卦辞。$rulesBasis。',
    };
  }

  static int _positionOf(String name) => switch (name) {
    '初九' || '初六' => 1,
    '九二' || '六二' => 2,
    '九三' || '六三' => 3,
    '九四' || '六四' => 4,
    '九五' || '六五' => 5,
    '上九' || '上六' => 6,
    _ => 0,
  };
}
