import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/history/file_reading_store.dart';
import 'package:yi_app/src/history/reading_json.dart';

import '../helpers/sample_reading.dart' show sampleReading, withCastAt;

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('yi-history-test-');
  });

  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  test('保存后可在同实例读取，完整保留全部快照字段', () async {
    final store = FileReadingStore(dir.path);
    final reading = sampleReading();

    await store.save(reading);
    final entries = await store.list();

    expect(entries, hasLength(1));
    final restored = entries.single;
    expect(restored.id, 'r-1');
    expect(restored.question, reading.question);
    expect(restored.castAt, reading.castAt);
    expect(restored.lines, reading.lines);
    expect(restored.benGuaName, reading.benGuaName);
    expect(restored.benGuaNumber, reading.benGuaNumber);
    expect(restored.benGuaCi, reading.benGuaCi);
    expect(restored.bianGuaName, reading.bianGuaName);
    expect(restored.bianGuaNumber, reading.bianGuaNumber);
    expect(restored.bianGuaCi, reading.bianGuaCi);
    expect(restored.changingPositions, reading.changingPositions);
    expect(restored.selectedTexts, hasLength(2));
    expect(restored.selectedTexts[0].label, '乾为天 · 初九');
    expect(restored.selectedTexts[0].original, '初九：潜龙勿用。');
    expect(restored.selectedTexts[0].isPrimary, isTrue);
    expect(restored.selectedTexts[0].vernacular, '样例白话解释');
    expect(restored.selectedTexts[0].actionReference, '样例行动参考');
    expect(restored.selectedTexts[1].vernacular, isNull);
    expect(restored.selectedTexts[1].actionReference, isNull);
    expect(restored.primaryLabel, reading.primaryLabel);
    expect(restored.selectionBasis, reading.selectionBasis);
    expect(restored.isSimplified, isFalse);
    expect(restored.sourceCitation, reading.sourceCitation);
    expect(restored.contentVersion, reading.contentVersion);
    expect(restored.castingMethod, reading.castingMethod);
    expect(restored.rulesBasis, reading.rulesBasis);
  });

  test('跨实例读取（模拟重启后回看），快照不被内容库重算', () async {
    final store = FileReadingStore(dir.path);
    // 保存于旧内容版本的卦例：重读后必须原样保留旧版本与旧快照。
    await store.save(
      sampleReading(id: 'old-1', contentVersion: 'classic-v1.0'),
    );

    final reopened = FileReadingStore(dir.path); // 全新实例，同目录
    final entries = await reopened.list();

    expect(entries, hasLength(1));
    expect(entries.single.contentVersion, 'classic-v1.0');
    expect(entries.single.selectedTexts.first.vernacular, '样例白话解释');
  });

  test('同一卦例重复保存（重试）不产生重复记录', () async {
    final store = FileReadingStore(dir.path);
    final reading = sampleReading();

    await store.save(reading);
    await store.save(reading); // 模拟失败后的重试

    expect(await store.list(), hasLength(1));
  });

  test('多条记录按起卦时间倒序返回', () async {
    final store = FileReadingStore(dir.path);
    await store.save(sampleReading(id: 'a', vernacular: null));
    await store.save(
      withCastAt(sampleReading(id: 'b'), DateTime(2026, 9, 30, 9, 0)),
    );

    final entries = await store.list();
    expect(entries.map((e) => e.id), ['b', 'a']);
  });

  test('删除后列表为空，重复删除不报错', () async {
    final store = FileReadingStore(dir.path);
    await store.save(sampleReading());

    await store.delete('r-1');
    expect(await store.list(), isEmpty);
    await store.delete('r-1'); // 幂等
    expect(await store.list(), isEmpty);
  });

  test('空目录返回空列表', () async {
    final store = FileReadingStore(dir.path);
    expect(await store.list(), isEmpty);
  });

  test('JSON 编解码往返完整保留快照（含旧内容版本）', () {
    final reading = sampleReading(contentVersion: 'classic-v1.0');
    final restored = ReadingJson.decode(ReadingJson.encode(reading));

    expect(restored.id, reading.id);
    expect(restored.castAt, reading.castAt);
    expect(restored.lines, reading.lines);
    expect(
      restored.selectedTexts[0].vernacular,
      reading.selectedTexts[0].vernacular,
    );
    expect(restored.selectedTexts[1].vernacular, isNull);
    expect(restored.contentVersion, 'classic-v1.0');
    expect(restored.isSimplified, isFalse);
  });
}
