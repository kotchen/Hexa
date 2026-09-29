import 'dart:io';

import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/history/file_reading_store.dart';
import 'src/history/history_controller.dart';

void main() {
  // macOS 应用沙盒会把 HOME 重写到本应用容器，
  // 因此历史数据落在容器内的 Application Support 下，只存本机。
  final historyDir =
      '${Platform.environment['HOME']}/Library/Application Support/yi_app/history';
  runApp(YiApp(history: HistoryController(FileReadingStore(historyDir))));
}
