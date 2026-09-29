import 'package:flutter/foundation.dart';

import '../reading/reading.dart';
import 'reading_store.dart';

/// 单条卦例的保存状态（结果页明示「尚未保存」与重试的依据）。
enum SaveStatus { saving, saved, failed }

/// 历史簿：把存储小接口接给界面。
///
/// 幂等语义：
/// - save 以卦例 id 去重；同一卦例的重试只覆盖同一条记录，不新增、不起卦。
/// - 保存失败时状态置为 [SaveStatus.failed]，卦例本身由调用方（结果页）保留在内存。
class HistoryController extends ChangeNotifier {
  HistoryController(this._store);

  final ReadingStore _store;

  List<Reading> entries = const [];

  final _statusById = <String, SaveStatus>{};

  bool _loaded = false;

  /// 从存储载入历史（进入历史页时调用）。
  Future<void> load() async {
    entries = await _store.list();
    _loaded = true;
    notifyListeners();
  }

  /// 自动保存（或用户重试）一条卦例；返回是否成功。
  /// 已成功保存过的同一卦例直接视为成功（不重复写存储）。
  Future<bool> save(Reading reading) async {
    if (_statusById[reading.id] == SaveStatus.saved) return true;
    _statusById[reading.id] = SaveStatus.saving;
    notifyListeners();
    try {
      await _store.save(reading);
    } catch (_) {
      _statusById[reading.id] = SaveStatus.failed;
      notifyListeners();
      return false;
    }
    _statusById[reading.id] = SaveStatus.saved;
    final index = entries.indexWhere((e) => e.id == reading.id);
    entries = index >= 0
        ? [
            for (var i = 0; i < entries.length; i++)
              if (i == index) reading else entries[i],
          ]
        : _sorted([...entries, reading]);
    notifyListeners();
    return true;
  }

  /// 删除一条历史（界面已先经确认）。
  Future<void> delete(String id) async {
    await _store.delete(id);
    entries = [
      for (final e in entries)
        if (e.id != id) e,
    ];
    _statusById.remove(id);
    notifyListeners();
  }

  SaveStatus statusOf(String id) {
    final known = _statusById[id];
    if (known != null) return known;
    if (entries.any((e) => e.id == id)) return SaveStatus.saved;
    // 从未保存过、也没有失败记录：视为保存中（自动保存刚触发尚未回执）。
    return SaveStatus.saving;
  }

  bool get isLoaded => _loaded;

  static List<Reading> _sorted(List<Reading> source) => source
    ..sort((a, b) {
      final byTime = b.castAt.compareTo(a.castAt);
      return byTime != 0 ? byTime : b.id.compareTo(a.id);
    });
}
