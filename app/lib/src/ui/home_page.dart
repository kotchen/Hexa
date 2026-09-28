import 'package:flutter/material.dart';

import '../reading/sample_reading.dart';
import 'cast_animation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _questionController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _submit() {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      setState(() => _errorText = '请输入要起卦的问题');
      return;
    }
    setState(() => _errorText = null);
    // 任务 01 使用固定开发样例；起卦生成将在内容任务就位后接入 CastingEngine。
    final reading = SampleReading.build(question);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CastAnimationPage(reading: reading)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '周易卜卦',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 8),
                ),
                const SizedBox(height: 8),
                Text(
                  '围绕将要做的具体事情起卦，阅读有原文依据的处境解读与行动参考',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _questionController,
                  maxLines: 3,
                  minLines: 2,
                  decoration: InputDecoration(
                    hintText: '请写下本次起卦关心的问题，例如：明天是否适合启动新项目？',
                    errorText: _errorText,
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB3392E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('起卦', style: TextStyle(fontSize: 18, letterSpacing: 4)),
                ),
                const SizedBox(height: 16),
                Text(
                  '开发阶段：当前结果页为固定开发样例，已明确标注，非真实随机起卦。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
