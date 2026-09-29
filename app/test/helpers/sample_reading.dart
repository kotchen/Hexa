import 'package:yi_app/src/reading/reading.dart';

/// 测试共用：一条字段齐全的卦例快照（可直接改 id / 内容版本 / 白话）。
Reading sampleReading({
  String id = 'r-1',
  String contentVersion = 'classic-v1.4',
  String? vernacular = '样例白话解释',
}) {
  return Reading(
    id: id,
    question: '明天是否适合启动新项目',
    castAt: DateTime(2026, 9, 29, 11, 30),
    lines: const [9, 7, 7, 7, 7, 7],
    benGuaName: '乾为天',
    benGuaNumber: 1,
    benGuaCi: '乾：元亨利贞。',
    bianGuaName: '天风姤',
    bianGuaNumber: 44,
    bianGuaCi: '姤：女壮，勿用取女。',
    changingPositions: const [1],
    selectedTexts: [
      SelectedText(
        label: '乾为天 · 初九',
        original: '初九：潜龙勿用。',
        isPrimary: true,
        vernacular: vernacular,
        actionReference: '样例行动参考',
      ),
      SelectedText(label: '乾为天 · 卦辞', original: '乾：元亨利贞。'),
    ],
    primaryLabel: '乾为天 · 初九',
    selectionBasis: '本次起卦一爻变（第 1 爻），取本卦该爻爻辞为阅读依据。',
    isSimplified: false,
    sourceCitation: '样例出处',
    contentVersion: contentVersion,
    castingMethod: '样例起卦方法',
    rulesBasis: '样例规则依据',
  );
}

/// 返回起卦时间被替换的副本（测试列表排序用）。
Reading withCastAt(Reading r, DateTime t) => Reading(
  id: r.id,
  question: r.question,
  castAt: t,
  lines: r.lines,
  benGuaName: r.benGuaName,
  benGuaNumber: r.benGuaNumber,
  benGuaCi: r.benGuaCi,
  bianGuaName: r.bianGuaName,
  bianGuaNumber: r.bianGuaNumber,
  bianGuaCi: r.bianGuaCi,
  changingPositions: r.changingPositions,
  selectedTexts: r.selectedTexts,
  primaryLabel: r.primaryLabel,
  selectionBasis: r.selectionBasis,
  isSimplified: r.isSimplified,
  sourceCitation: r.sourceCitation,
  contentVersion: r.contentVersion,
  castingMethod: r.castingMethod,
  rulesBasis: r.rulesBasis,
);
