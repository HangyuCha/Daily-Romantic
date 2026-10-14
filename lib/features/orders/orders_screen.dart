import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/emoji_thumb.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../pickup/data/pickup_store.dart';
import '../pickup/screens/pickup_code_screen.dart';

/// 주문 탭 — 예약한 주문과 픽업 코드 다시 보기
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = PickupScope.of(context).orders;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return PageScaffold(
      title: '주문 내역',
      subtitle: '픽업 코드를 다시 확인할 수 있어요.',
      children: [
        if (orders.isEmpty)
          const EmptyView(
            emoji: '🧾',
            title: '아직 주문이 없어요',
            message: '홈에서 가는 길 가게를 찾아 선물을 예약해 보세요.',
          ),
        for (final order in orders) ...[
          Card(
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
                child: Row(
                  children: [
                    EmojiThumb(order.store.emoji),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.store.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${formatTime(order.pickupAt)} 픽업 · '
                            '${order.itemCount}개 · ${formatWon(order.total)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      order.code,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
