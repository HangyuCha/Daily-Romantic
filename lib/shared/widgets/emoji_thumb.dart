import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// 연핑크 배경의 이모지 썸네일. 실제 사진이 생기면 이 위젯만 교체하면 된다.
class EmojiThumb extends StatelessWidget {
  const EmojiThumb(this.emoji, {super.key, this.size = 48});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}
