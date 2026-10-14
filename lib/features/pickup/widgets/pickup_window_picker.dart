import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../data/models.dart';

/// "언제까지 픽업할 수 있어야 하나요?" — 15분 / 30분 큰 카드 선택
class PickupWindowPicker extends StatelessWidget {
  const PickupWindowPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PickupWindow selected;
  final ValueChanged<PickupWindow> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, w) in PickupWindow.values.indexed) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
          Expanded(
            child: _WindowCard(
              window: w,
              selected: w == selected,
              onTap: () => onSelected(w),
            ),
          ),
        ],
      ],
    );
  }
}

class _WindowCard extends StatelessWidget {
  const _WindowCard({
    required this.window,
    required this.selected,
    required this.onTap,
  });

  final PickupWindow window;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : scheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg + 2),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outline,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                window.label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: selected ? scheme.primary : scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                window.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
