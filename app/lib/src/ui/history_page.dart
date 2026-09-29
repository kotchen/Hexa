import 'dart:async';

import 'package:flutter/material.dart';

import '../history/history_controller.dart';
import '../reading/reading.dart';
import 'paper_background.dart';
import 'result_page.dart';

/// 本机历史卦例：空态、列表（时间倒序）、详情回看与确认后删除。
/// 数据只存在本机，无账号、同步或导出。
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.history});

  final HistoryController history;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? _loadError;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      await widget.history.load();
      if (mounted) setState(() => _loadError = null);
    } catch (_) {
      if (mounted) setState(() => _loadError = '历史读取失败，请重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('返回'),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '历史卦例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.history,
                builder: (context, _) {
                  if (_loadError != null) {
                    return _CenteredMessage(
                      message: _loadError!,
                      actionLabel: '重试',
                      onAction: _load,
                    );
                  }
                  final entries = widget.history.entries;
                  if (entries.isEmpty) {
                    return const _CenteredMessage(
                      message: '还没有历史卦例\n起卦后会自动保存在本机',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) => _HistoryTile(
                      entry: entries[index],
                      history: widget.history,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.history});

  final Reading entry;
  final HistoryController history;

  @override
  Widget build(BuildContext context) {
    final time =
        '${entry.castAt.year}-${_two(entry.castAt.month)}-${_two(entry.castAt.day)} '
        '${_two(entry.castAt.hour)}:${_two(entry.castAt.minute)}';
    final gua = entry.bianGuaName != null
        ? '${entry.benGuaName} 之 ${entry.bianGuaName}'
        : entry.benGuaName;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      title: Text(entry.question, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '$time · $gua',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      onTap: () {
        // 回看的是保存时的快照，不重新起卦、不按当前内容库重算。
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ResultPage(
              reading: entry,
              onDelete: () async => history.delete(entry.id),
            ),
          ),
        );
      },
    );
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
