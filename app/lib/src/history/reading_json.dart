import 'dart:convert';

import '../reading/reading.dart';

/// 卦例快照的 JSON 编解码。
/// 序列化只记录起卦时留下的字段，不做任何重算；
/// 内容库升级后旧快照按原样解码呈现。
abstract final class ReadingJson {
  static const int schemaVersion = 1;

  static String encode(Reading r) => jsonEncode(_toMap(r));

  static Reading decode(String json) =>
      _fromMap(jsonDecode(json) as Map<String, Object?>);

  static Map<String, Object?> _toMap(Reading r) => {
    'schema': schemaVersion,
    'id': r.id,
    'question': r.question,
    'castAt': r.castAt.toIso8601String(),
    'lines': r.lines,
    'benGuaName': r.benGuaName,
    'benGuaNumber': r.benGuaNumber,
    'benGuaCi': r.benGuaCi,
    'bianGuaName': r.bianGuaName,
    'bianGuaNumber': r.bianGuaNumber,
    'bianGuaCi': r.bianGuaCi,
    'changingPositions': r.changingPositions,
    'selectedTexts': [
      for (final t in r.selectedTexts)
        {
          'label': t.label,
          'original': t.original,
          'isPrimary': t.isPrimary,
          'vernacular': t.vernacular,
          'actionReference': t.actionReference,
        },
    ],
    'primaryLabel': r.primaryLabel,
    'selectionBasis': r.selectionBasis,
    'isSimplified': r.isSimplified,
    'sourceCitation': r.sourceCitation,
    'contentVersion': r.contentVersion,
    'castingMethod': r.castingMethod,
    'rulesBasis': r.rulesBasis,
  };

  static Reading _fromMap(Map<String, Object?> m) => Reading(
    id: m['id']! as String,
    question: m['question']! as String,
    castAt: DateTime.parse(m['castAt']! as String),
    lines: (m['lines'] as List<Object?>).cast<int>(),
    benGuaName: m['benGuaName']! as String,
    benGuaNumber: m['benGuaNumber']! as int,
    benGuaCi: m['benGuaCi']! as String,
    bianGuaName: m['bianGuaName'] as String?,
    bianGuaNumber: m['bianGuaNumber'] as int?,
    bianGuaCi: m['bianGuaCi'] as String?,
    changingPositions: (m['changingPositions'] as List<Object?>).cast<int>(),
    selectedTexts: [
      for (final e in m['selectedTexts']! as List<Object?>)
        _selectedFromMap(e as Map<String, Object?>),
    ],
    primaryLabel: m['primaryLabel'] as String?,
    selectionBasis: m['selectionBasis']! as String,
    isSimplified: m['isSimplified']! as bool,
    sourceCitation: m['sourceCitation']! as String,
    contentVersion: m['contentVersion']! as String,
    castingMethod: m['castingMethod']! as String,
    rulesBasis: m['rulesBasis']! as String,
  );

  static SelectedText _selectedFromMap(Map<String, Object?> m) => SelectedText(
    label: m['label']! as String,
    original: m['original']! as String,
    isPrimary: m['isPrimary']! as bool,
    vernacular: m['vernacular'] as String?,
    actionReference: m['actionReference'] as String?,
  );
}
