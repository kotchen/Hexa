import 'package:flutter/material.dart';

import '../reading/reading.dart';
import 'paper_background.dart';

/// 卦例结果页：本卦概览与重点原文分区展示，附来源与取辞依据。
class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context) {
    const vermilion = Color(0xFFB3392E);
    return Scaffold(
      body: PaperBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                Text(
                  reading.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '起卦时间：${_formatTime(reading.castAt)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                _Section(
                  title: '卦象',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '本卦：${reading.benGuaName}（第 ${reading.benGuaNumber} 卦）',
                      ),
                      if (reading.changingPositions.isNotEmpty)
                        Text(
                          '变爻：第 ${reading.changingPositions.join('、')} 爻',
                          style: const TextStyle(color: vermilion),
                        ),
                      if (reading.bianGuaName != null)
                        Text(
                          '变卦：${reading.bianGuaName}（第 ${reading.bianGuaNumber} 卦）',
                        ),
                      if (reading.isSimplified)
                        const Text(
                          '三爻变：并读两卦卦辞，不判主次。此为明确标注的简化读法，非完整传统复原。',
                          style: TextStyle(color: vermilion),
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: '本卦概览',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reading.benGuaCi,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (reading.bianGuaCi != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '变卦（${reading.bianGuaName}）卦辞：${reading.bianGuaCi}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '概览供对照处境；本次重点阅读以下取辞条目。',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(title: '取辞依据', child: Text(reading.selectionBasis)),
                _Section(
                  title: '重点原文',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final t in reading.selectedTexts) ...[
                        _SelectedTextBlock(text: t),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                _Section(
                  title: '来源',
                  child: Text(
                    '${reading.sourceCitation}\n'
                    '内容版本：${reading.contentVersion}\n'
                    '${reading.castingMethod}\n'
                    '${reading.rulesBasis}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('返回，再次起卦'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) =>
      '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';

  String _two(int v) => v.toString().padLeft(2, '0');
}

class _SelectedTextBlock extends StatelessWidget {
  const _SelectedTextBlock({required this.text});

  final SelectedText text;

  @override
  Widget build(BuildContext context) {
    const vermilion = Color(0xFFB3392E);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                text.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (text.isPrimary) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: vermilion),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '主读',
                  style: TextStyle(fontSize: 11, color: vermilion),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(text.original, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: text.vernacular != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('白话解释（应用编写）：${text.vernacular}'),
                    if (text.actionReference != null) ...[
                      const SizedBox(height: 4),
                      Text('行动参考（应用编写，非原文）：${text.actionReference}'),
                    ],
                  ],
                )
              : const Text(
                  '解读尚未完成（白话解释将在内容任务补齐，此处不以通用文案冒充解读）',
                  style: TextStyle(fontSize: 13, color: vermilion),
                ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 18, color: const Color(0xFF2B2926)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.only(left: 12), child: child),
        ],
      ),
    );
  }
}
