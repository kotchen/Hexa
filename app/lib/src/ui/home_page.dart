import 'dart:async';

import 'package:flutter/material.dart';

import '../history/history_controller.dart';
import '../reading/reading_factory.dart';
import 'cast_animation_page.dart';
import 'history_page.dart';
import 'paper_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.factory, required this.history});

  /// 起卦工厂：应用注入真实随机源，测试注入可控序列。
  final ReadingFactory factory;

  /// 本机历史：起卦后自动保存卦例快照。
  final HistoryController history;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _questionController = TextEditingController();
  String? _errorText;
  var _submitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitting) return; // 提交期间阻止重复生成
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      setState(() => _errorText = '请输入要起卦的问题');
      return;
    }
    setState(() {
      _errorText = null;
      _submitting = true;
    });
    // 一次提交只生成一次卦例；动画仅展示，跳过不改变结果。
    final reading = widget.factory.cast(question);
    // 自动保存到本机历史；失败时结果页明示「尚未保存」并可幂等重试。
    unawaited(widget.history.save(reading));
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) =>
                CastAnimationPage(reading: reading, history: widget.history),
          ),
        )
        .then((_) {
          if (mounted) setState(() => _submitting = false);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperBackground(
        child: Stack(
          children: [
            Center(
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
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '围绕将要做的具体事情起卦，阅读有原文依据的处境解读与行动参考',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
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
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB3392E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '起卦',
                          style: TextStyle(fontSize: 18, letterSpacing: 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 历史入口：本机卦例回看（无账号、同步或导出）。
            Positioned(
              top: 0,
              right: 8,
              child: SafeArea(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => HistoryPage(history: widget.history),
                      ),
                    );
                  },
                  child: const Text('历史'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
