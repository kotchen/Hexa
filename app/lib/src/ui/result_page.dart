import 'package:flutter/material.dart';

import '../reading/reading.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context) {
    const vermilion = Color(0xFFB3392E);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(32),
            children: [
              if (reading.isDevSample)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: vermilion),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    reading.devBadgeLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: vermilion, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                reading.question,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    Text('本卦：${reading.benGuaName}'),
                    if (reading.changingPositions.isNotEmpty)
                      Text(
                        '变爻：第 ${reading.changingPositions.join('、')} 爻',
                        style: const TextStyle(color: vermilion),
                      ),
                    if (reading.bianGuaName != null) Text('变卦：${reading.bianGuaName}'),
                    if (reading.isSimplified)
                      const Text(
                        '（三爻变：并读两卦卦辞，不判主次。此为明确标注的简化读法，非完整传统复原。）',
                        style: TextStyle(color: vermilion),
                      ),
                  ],
                ),
              ),
              _Section(
                title: '取辞依据',
                child: Text(reading.selectionBasis),
              ),
              _Section(
                title: '原文',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final text in reading.originalTexts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(text, style: const TextStyle(fontSize: 16)),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '出处：${reading.sourceCitation}\n定位：${reading.sourceLocation}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              _Section(
                title: '白话解释（应用编写）',
                accent: vermilion,
                child: Text(reading.vernacularText),
              ),
              _Section(
                title: '行动参考（应用编写，非原文）',
                accent: vermilion,
                child: Text(reading.actionReference),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) =>
      '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';

  String _two(int v) => v.toString().padLeft(2, '0');
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.accent});

  final String title;
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? const Color(0xFF2B2926);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.only(left: 12), child: child),
        ],
      ),
    );
  }
}
