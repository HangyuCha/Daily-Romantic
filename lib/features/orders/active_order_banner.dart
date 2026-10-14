import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/emoji_thumb.dart';
import '../pickup/data/models.dart';
import '../pickup/data/pickup_store.dart';
import '../pickup/screens/pickup_code_screen.dart';

/// 홈 상단에 떠 있는 진행 중 주문 상태. 진행 중인 주문이 없으면 아무것도 그리지 않는다.
class ActiveOrderBanner extends StatefulWidget {
  const ActiveOrderBanner({super.key});

  @override
  State<ActiveOrderBanner> createState() => _ActiveOrderBannerState();
}

class _ActiveOrderBannerState extends State<ActiveOrderBanner> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    // 준비 단계가 시간에 따라 바뀌므로 주기적으로 다시 그린다.
    _ticker = Timer.periodic(
      const Duration(seconds: 15),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final active = PickupScope.of(context).activeOrders(now);
    if (active.isEmpty) return const SizedBox.shrink();

    final order = active.first;
    final stage = order.stageAt(now);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) =>
                  PickupCodeScreen(order: order, showHomeButton: false),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    EmojiThumb(order.store.emoji, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _headline(stage),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${order.store.name} · '
                            '${formatTime(order.pickupAt)} 픽업'
                            '${active.length > 1 ? ' · 외 ${active.length - 1}건' : ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: muted,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('픽업 코드', style: muted),
                        Text(
                          order.code,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _StageSteps(current: stage),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _headline(PickupStage stage) => switch (stage) {
    PickupStage.preparing => '가게에서 준비 중이에요',
    PickupStage.packed => '포장이 끝났어요',
    PickupStage.ready => '지금 픽업할 수 있어요',
  };
}

/// 가게 준비 → 포장 완료 → 픽업 가능 3단계 표시
class _StageSteps extends StatelessWidget {
  const _StageSteps({required this.current});

  final PickupStage current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final stage in PickupStage.values) ...[
          if (stage.index > 0) const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: stage.index <= current.index
                        ? scheme.primary
                        : scheme.surface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stage.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: stage == current
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: stage.index <= current.index
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
