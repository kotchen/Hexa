/// 一次卦例阅读的结果（由真实起卦生成）。
class Reading {
  const Reading({
    required this.id,
    required this.question,
    required this.castAt,
    required this.lines,
    required this.benGuaName,
    required this.benGuaNumber,
    required this.benGuaCi,
    required this.changingPositions,
    required this.selectedTexts,
    required this.primaryLabel,
    required this.selectionBasis,
    required this.isSimplified,
    required this.sourceCitation,
    required this.contentVersion,
    required this.castingMethod,
    required this.rulesBasis,
    this.bianGuaName,
    this.bianGuaNumber,
    this.bianGuaCi,
  });

  /// 唯一标识：起卦时生成，历史保存与重试幂等以此去重。
  final String id;

  final String question;
  final DateTime castAt;

  /// 六爻原始数值（6/7/8/9），自下而上。
  final List<int> lines;

  /// 本卦（通行本卦序与卦辞概览）。
  final String benGuaName;
  final int benGuaNumber;
  final String benGuaCi;

  /// 变卦；无变爻时为 null。
  final String? bianGuaName;
  final int? bianGuaNumber;
  final String? bianGuaCi;

  /// 变爻位置（1–6，自下而上）。
  final List<int> changingPositions;

  /// 本次取辞选中的经文条目（原文与可选解读）。
  final List<SelectedText> selectedTexts;

  /// 主读条目标签；三变简化读法无主次时为 null。
  final String? primaryLabel;

  /// 取辞依据说明，展示给用户。
  final String selectionBasis;

  /// 三变简化读法时为 true，界面须明确标注。
  final bool isSimplified;

  /// 出处（底本/版本）与内容版本。
  final String sourceCitation;
  final String contentVersion;

  /// 起卦方法与取辞规则版本说明。
  final String castingMethod;
  final String rulesBasis;
}

/// 一条被选中的经文及其解读快照。
class SelectedText {
  const SelectedText({
    required this.label,
    required this.original,
    this.isPrimary = false,
    this.vernacular,
    this.actionReference,
  });

  /// 如「乾为天 · 初九」「乾为天 · 卦辞」「乾为天 · 用九」。
  final String label;

  /// 原文（含位名引领，如「初九：潜龙勿用。」）。
  final String original;

  /// 是否主读条目。
  final bool isPrimary;

  /// 应用原创白话解释；null = 解读尚未完成，界面须明示。
  final String? vernacular;

  /// 应用编写的一般行动参考；null = 尚未编写。
  final String? actionReference;
}
