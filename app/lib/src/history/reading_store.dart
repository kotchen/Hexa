import '../reading/reading.dart';

/// 卦例历史存储的小接口：应用注入本机持久化实现，测试注入内存或失败注入。
/// 语义：save 以卦例 id 去重（同一卦例重复保存不产生重复记录）。
abstract class ReadingStore {
  /// 保存（或按 id 覆盖）一条卦例快照。
  Future<void> save(Reading record);

  /// 全部历史，按起卦时间倒序；空存储返回空列表。
  Future<List<Reading>> list();

  /// 删除指定 id；id 不存在时不报错（幂等）。
  Future<void> delete(String id);
}

/// 内存实现：供界面默认组合与单元测试使用。
class InMemoryReadingStore implements ReadingStore {
  final _byId = <String, Reading>{};

  @override
  Future<void> save(Reading record) async {
    _byId[record.id] = record;
  }

  @override
  Future<List<Reading>> list() async {
    final entries = _byId.values.toList()
      ..sort((a, b) {
        final byTime = b.castAt.compareTo(a.castAt);
        return byTime != 0 ? byTime : b.id.compareTo(a.id);
      });
    return List.unmodifiable(entries);
  }

  @override
  Future<void> delete(String id) async {
    _byId.remove(id);
  }
}
