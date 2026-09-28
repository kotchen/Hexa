import '../domain/reading_rules.dart';
import 'reading.dart';

/// 任务 01 的开发样例：乾为天，初九变 → 天风姤。
///
/// 原文已经人工校核（见 [sourceCitation]）；白话解释与行动参考为本应用原创编写，
/// 在界面上与原文明确区分。本样例固定不变、明确标注，不伪装成真实随机起卦。
class SampleReading {
  SampleReading._();

  static const String badgeLabel = '开发样例 · 非真实起卦结果';

  static Reading build(String question, {DateTime? castAt}) {
    // 固定爻值：初爻老阳（9），其余少阳（7）→ 乾之姤。
    const lines = [9, 7, 7, 7, 7, 7];
    final selection = ReadingRules.select(lines);
    final primary = selection.primary;

    return Reading(
      question: question,
      castAt: castAt ?? DateTime.now(),
      lines: lines,
      benGuaName: '乾为天',
      bianGuaName: '天风姤',
      changingPositions: const [1],
      selectedLabels: [for (final e in selection.entries) e.label],
      primaryLabel: primary?.label,
      selectionBasis: '一变爻：取本卦该爻辞（规则依据见决策记录 ADR-0001，参考《易学启蒙·考变占》）。'
          '本次变爻为乾卦初九，故重点阅读初九爻辞「潜龙勿用」。',
      isSimplified: selection.isSimplified,
      originalTexts: const [
        '乾：元亨利贞。',
        '初九：潜龙勿用。',
        '姤：女壮，勿用取女。',
      ],
      sourceCitation: '《周易》通行本（王弼注本系统），经文史对照核校',
      sourceLocation:
          '乾卦卦辞及初九爻辞见《周易》上经乾卦；姤卦卦辞见《周易》下经姤卦（第 44 卦，乾上巽下）。',
      vernacularText: '乾卦六爻皆阳，如巨龙自潜伏到飞天的六个阶段。初九处最下位，象征事物尚在起步阶段：'
          '龙深潜在水底，力量未充、时机未熟，此时不宜急于表现或行动。「勿用」不是永远不用，'
          '而是此时此刻不宜轻举妄动，宜暗中积蓄、耐心等待。',
      actionReference: '当前阶段宜低调准备：把计划做扎实、补齐短板、观察环境变化，不要急于公开推进或做重大承诺。'
          '待条件成熟（人、财、时机就位）再逐步展开。以上为应用提供的一般性行动参考，并非对未来的确定预测。',
      isDevSample: true,
      devBadgeLabel: badgeLabel,
    );
  }
}
