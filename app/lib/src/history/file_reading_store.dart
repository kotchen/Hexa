import 'dart:io';

import '../reading/reading.dart';
import 'reading_json.dart';
import 'reading_store.dart';

/// 本机文件存储：每条卦例一个 JSON 文件（以 id 命名），保存即覆盖，
/// 天然按 id 幂等；数据只写本机目录。
class FileReadingStore implements ReadingStore {
  FileReadingStore(this.directoryPath);

  final String directoryPath;

  Directory get _directory => Directory(directoryPath);

  @override
  Future<void> save(Reading record) async {
    await _directory.create(recursive: true);
    final file = File('$directoryPath/${record.id}.json');
    // 先写临时文件再改名，避免写入中途被读取到半个文件。
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(ReadingJson.encode(record), flush: true);
    await tmp.rename(file.path);
  }

  @override
  Future<List<Reading>> list() async {
    if (!_directory.existsSync()) return const [];
    final entries = <Reading>[];
    await for (final entity in _directory.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final content = await entity.readAsString();
      entries.add(ReadingJson.decode(content));
    }
    entries.sort((a, b) {
      final byTime = b.castAt.compareTo(a.castAt);
      return byTime != 0 ? byTime : b.id.compareTo(a.id);
    });
    return List.unmodifiable(entries);
  }

  @override
  Future<void> delete(String id) async {
    final file = File('$directoryPath/$id.json');
    if (file.existsSync()) await file.delete();
  }
}
