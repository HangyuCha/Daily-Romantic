import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/choice_chip_group.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../data/models.dart';
import 'payment_screen.dart';

/// S4. 픽업 시간 선택 및 주문 확인
class PickupTimeScreen extends StatefulWidget {
  const PickupTimeScreen({super.key, required this.cart});

  final Cart cart;

  static const minuteOptions = [12, 20, 30];

  @override
  State<PickupTimeScreen> createState() => _PickupTimeScreenState();
}

class _PickupTimeScreenState extends State<PickupTimeScreen> {
  var _minutes = PickupTimeScreen.minuteOptions.first;

  void _goToPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PaymentScreen(cart: widget.cart, pickupInMinutes: _minutes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final readyAt = DateTime.now().add(Duration(minutes: _minutes));
    final tooTight = _minutes < cart.store.prepMinutes;

    return Scaffold(
      body: PageScaffold(
        backLabel: AppStrings.back,
        title: '픽업 시간 선택',
        subtitle: '경로 도착 예상 시각에 맞춰 가게가 준비해둬요.',
        bottom: FilledButton(
          onPressed: _goToPayment,
          child: const Text('결제하고 픽업 예약'),
        ),
        children: [
          ChoiceChipGroup<int>(
            options: PickupTimeScreen.minuteOptions,
            selected: _minutes,
            labelOf: (m) => '$m분 후',
            onSelected: (m) => setState(() => _minutes = m),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            tooTight
                ? '가게 평균 준비 시간(${cart.store.prepMinutes}분)보다 짧아 조금 기다릴 수 있어요.'
                : '${formatTime(readyAt)}에 픽업할 수 있어요.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: tooTight ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('주문 요약', style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Text(
                        formatWon(cart.total),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${cart.store.name} · ${cart.itemCount}개',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Divider(height: AppSpacing.lg),
                  for (final MapEntry(key: item, value: qty)
                      in cart.quantities.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.name} × $qty',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            formatWon(item.price * qty),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  if (cart.message.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '💌 ${cart.message}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
