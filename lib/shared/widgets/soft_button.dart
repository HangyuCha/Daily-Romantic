import 'package:flutter/material.dart';

/// 연핑크 배경의 보조 버튼 (프로토타입의 고스트 버튼).
class SoftButton extends StatelessWidget {
  const SoftButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.primary,
      ),
      child: Text(label),
    );
  }
}
