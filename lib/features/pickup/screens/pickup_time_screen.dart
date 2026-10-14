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
  // 가게 도착 시간과 준비 시간을 둘 다 넘기는 가장 빠른 시간을 기본으로 고른다.
  late var _minutes = PickupTimeScreen.minuteOptions.firstWhere(
    (m) => m >= _earliestMinutes,
    orElse: () => PickupTimeScreen.minuteOptions.last,
  );

  int get _earliestMinutes {
    final cart = widget.cart;
    final walk = cart.walkMinutes ?? 0;
    return walk > cart.store.prepMinutes ? walk : cart.store.prepMinutes;
  }

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
    final walk = cart.walkMinutes;
    final tooTight = _minutes < _earliestMinutes;
    final String hint;
    if (walk != null && _minutes < walk) {
      hint = '가게까지 도보 약 $walk분이라 조금 늦게 도착해요.';
    } else if (_minutes < cart.store.prepMinutes) {
      hint = '가게 평균 준비 시간(${cart.store.prepMinutes}분)보다 짧아 조금 기다릴 수 있어요.';
    } else {
      hint =
          '${walk == null ? '' : '가게까지 도보 약 $walk분 · '}'
          '${formatTime(readyAt)}에 픽업할 수 있어요.';
    }

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
            hint,
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
