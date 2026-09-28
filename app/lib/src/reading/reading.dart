/// 一次卦例阅读的结果。
class Reading {
  const Reading({
    required this.question,
    required this.castAt,
    required this.lines,
    required this.benGuaName,
    required this.bianGuaName,
    required this.changingPositions,
    required this.selectedLabels,
    required this.primaryLabel,
    required this.selectionBasis,
    required this.isSimplified,
    required this.originalTexts,
    required this.sourceCitation,
    required this.sourceLocation,
    required this.vernacularText,
    required this.actionReference,
    required this.isDevSample,
    required this.devBadgeLabel,
  });

  final String question;
  final DateTime castAt;

  /// 六爻原始数值（6/7/8/9），自下而上。
  final List<int> lines;
  final String benGuaName;

  /// 无变爻时为 null。
  final String? bianGuaName;
  final List<int> changingPositions;

  /// 本次取辞选中的经文条目标签（如「乾为天 · 初九」）。
  final List<String> selectedLabels;

  /// 主读条目标签；三变简化读法无主次时为 null。
  final String? primaryLabel;

  /// 取辞依据说明，展示给用户。
  final String selectionBasis;
  final bool isSimplified;

  /// 选中的原文文字。
  final List<String> originalTexts;

  /// 出处（底本/版本）与定位。
  final String sourceCitation;
  final String sourceLocation;

  /// 应用原创白话解释。
  final String vernacularText;

  /// 应用编写的一般性行动参考，与原文、白话分开展示。
  final String actionReference;

  /// 开发样例标记：明确标注、不伪装成真实随机起卦。
  final bool isDevSample;
  final String devBadgeLabel;
}
