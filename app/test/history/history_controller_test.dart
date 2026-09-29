import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/history/history_controller.dart';
import 'package:yi_app/src/history/reading_store.dart';
import 'package:yi_app/src/reading/reading.dart';

import '../helpers/sample_reading.dart' show sampleReading, withCastAt;

/// 前 N 次保存抛错的存储：通过存储小接口注入失败，不依赖真实随机或时序。
class FlakyStore implements ReadingStore {
  FlakyStore({this.failuresBeforeSuccess = 1});
  final int failuresBeforeSuccess;
  int saveAttempts = 0;
  final _delegate = InMemoryReadingStore();

  @override
  Future<void> save(Reading record) async {
    saveAttempts++;
    if (saveAttempts <= failuresBeforeSuccess) {
      throw StateError('模拟保存失败（$saveAttempts）');
    }
    await _delegate.save(record);
  }

  @override
  Future<List<Reading>> list() => _delegate.list();

  @override
  Future<void> delete(String id) => _delegate.delete(id);
}

void main() {
  test('保存失败：状态为 failed 且不入列表；结果对象仍在内存（由调用方保留）', () async {
    final store = FlakyStore(failuresBeforeSuccess: 99);
    final history = HistoryController(store);
    final reading = sampleReading();

    final ok = await history.save(reading);

    expect(ok, isFalse);
    expect(history.statusOf(reading.id), SaveStatus.failed);
    expect(history.entries, isEmpty);
  });

  test('重试成功：状态恢复 saved 且只有一条记录；再次保存仍不重复', () async {
    final store = FlakyStore(failuresBeforeSuccess: 1);
    final history = HistoryController(store);
    final reading = sampleReading();

    expect(await history.save(reading), isFalse);
    expect(await history.save(reading), isTrue); // 重试同一卦例

    expect(history.statusOf(reading.id), SaveStatus.saved);
    expect(history.entries, hasLength(1));
    expect(history.entries.single.id, reading.id);

    // 成功后不会触发第三次写入（状态已 saved，无重复保存语义）
    await history.save(reading);
    expect(store.saveAttempts, 2);
    expect(history.entries, hasLength(1));
  });

  test('删除后状态清除、列表移除', () async {
    final history = HistoryController(InMemoryReadingStore());
    final reading = sampleReading();

    await history.save(reading);
    expect(history.statusOf(reading.id), SaveStatus.saved);

    await history.delete(reading.id);
    expect(history.entries, isEmpty);
  });

  test('load 从存储读入历史并按时间倒序', () async {
    final store = InMemoryReadingStore();
    final history = HistoryController(store);
    final older = withCastAt(sampleReading(id: 'older'), DateTime(2026, 9, 28, 8, 0));
    final newer = withCastAt(sampleReading(id: 'newer'), DateTime(2026, 9, 29, 9, 0));
    await store.save(older);
    await store.save(newer);

    await history.load();
    expect(history.entries.map((e) => e.id), ['newer', 'older']);
  });
}
