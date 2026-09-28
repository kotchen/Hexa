import 'package:flutter/material.dart';

/// 全应用共享的纸感背景：宣纸纹理铺满，起卦页可叠水墨底韵（ADR-0004）。
class PaperBackground extends StatelessWidget {
  const PaperBackground({super.key, required this.child, this.inkWash = false});

  final Widget child;

  /// 是否在画面中心叠一层极淡的水墨底韵（仅起卦页使用）。
  final bool inkWash;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: Image(
            image: AssetImage('assets/images/xuan-paper-texture.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        if (inkWash)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.10,
                child: Image.asset(
                  'assets/images/ink-wash-blob.png',
                  width: 420,
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
