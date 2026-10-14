import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../data/models.dart';
import '../data/pickup_store.dart';
import 'pickup_code_screen.dart';

/// S4 → S5 사이의 결제 화면. 시연용이라 실제 결제는 일어나지 않는다.
/// 실제 결제를 붙일 때는 [_pay]에서 PG사 SDK(토스페이먼츠, 포트원 등)를 호출하면 된다.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.cart,
    required this.pickupInMinutes,
  });

  final Cart cart;
  final int pickupInMinutes;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  var _method = PaymentMethod.kakaoPay;
  var _agreed = false;
  var _paying = false;

  Future<void> _pay() async {
    final pickup = PickupScope.of(context);
    final navigator = Navigator.of(context);
    setState(() => _paying = true);

    // 결제사 화면을 다녀오는 시간을 흉내 낸다.
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PayingDialog(method: _method),
    );
    if (!mounted) return;

    final order = pickup.placeOrder(
      widget.cart,
      pickupInMinutes: widget.pickupInMinutes,
      paymentMethod: _method,
    );
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => PickupCodeScreen(order: order)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Scaffold(
      body: PageScaffold(
        backLabel: AppStrings.back,
        title: '결제하기',
        subtitle: '${cart.store.name} · ${widget.pickupInMinutes}분 후 픽업',
        bottom: FilledButton(
          onPressed: _agreed && !_paying ? _pay : null,
          child: Text('${formatWon(cart.total)} 결제하기'),
        ),
        children: [
          const _DemoBanner(),
          const SizedBox(height: AppSpacing.lg),
          Text('결제 수단', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final method in PaymentMethod.values) ...[
            _MethodTile(
              method: method,
              selected: method == _method,
              onTap: () => setState(() => _method = method),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (_method == PaymentMethod.card)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                '시연용이라 카드 번호를 입력하지 않아요.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text('결제 금액', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _AmountRow(
                    label: '상품 금액 (${cart.itemCount}개)',
                    value: formatWon(cart.total),
                    style: muted,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _AmountRow(label: '할인', value: formatWon(0), style: muted),
                  const SizedBox(height: AppSpacing.xs),
                  _AmountRow(
                    label: '픽업 수수료',
                    value: formatWon(0),
                    style: muted,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _AmountRow(
                    label: '최종 결제 금액',
                    value: formatWon(cart.total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          CheckboxListTile(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              '주문 내용을 확인했으며 결제에 동의합니다.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : scheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(method.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  method.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value, this.style});

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        '시연용 결제 화면이에요. 실제로 돈이 나가지 않아요.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.5, color: scheme.primary),
      ),
    );
  }
}

/// 결제 진행 중 표시. 잠시 뒤 스스로 닫힌다.
class _PayingDialog extends StatefulWidget {
  const _PayingDialog({required this.method});

  final PaymentMethod method;

  @override
  State<_PayingDialog> createState() => _PayingDialogState();
}

class _PayingDialogState extends State<_PayingDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '${widget.method.label}로 결제하는 중이에요',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
