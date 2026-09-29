import 'dart:io';

/// 端到端验证使用的真实文件存储目录：位于应用沙盒容器内
/// （与正式历史同根、独立子目录，验证后清理）。
String e2eHistoryDir() =>
    '${Platform.environment['HOME']}/Library/Application Support/yi_app/e2e_history';

/// 统计目录中的卦例 JSON 文件数。
int countSavedReadings() {
  final dir = Directory(e2eHistoryDir());
  if (!dir.existsSync()) return 0;
  return dir
      .listSync()
      .where((f) => f is File && f.path.endsWith('.json'))
      .length;
}
