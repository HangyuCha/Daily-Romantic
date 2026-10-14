import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/soft_button.dart';
import '../data/models.dart';

/// S5. 픽업 코드 및 준비 상태. 뒤로가기 없는 플로우 종결 화면.
/// 주문 탭에서 다시 열 때는 [showHomeButton]을 false로 둔다.
class PickupCodeScreen extends StatefulWidget {
  const PickupCodeScreen({
    super.key,
    required this.order,
    this.showHomeButton = true,
  });

  final PickupOrder order;
  final bool showHomeButton;

  @override
  State<PickupCodeScreen> createState() => _PickupCodeScreenState();
}

class _PickupCodeScreenState extends State<PickupCodeScreen>
    with SingleTickerProviderStateMixin {
  // 가게 쪽 상태 연동 전까지 30% → 85%로 진행하는 애니메이션으로 표현한다.
  late final _progress = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
    lowerBound: 0.3,
    upperBound: 0.85,
  )..forward();

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  PickupStage _stageFor(double value) {
    if (value >= 0.9) return PickupStage.ready;
    if (value >= 0.5) return PickupStage.packed;
    return PickupStage.preparing;
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return PopScope(
      canPop: !widget.showHomeButton,
      child: Scaffold(
        appBar: widget.showHomeButton ? null : AppBar(),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showHomeButton) const AppHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      '🎁',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 56),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '픽업 준비 중이에요',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${order.store.name}에서 곧 준비돼요.\n목적지 도착 전에 들르세요!',
                      textAlign: TextAlign.center,
                      style: muted,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      order.code,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                        color: scheme.primary,
                      ),
                    ),
                    Text(
                      '매장에서 이 코드를 보여주세요',
                      textAlign: TextAlign.center,
                      style: muted,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (context, _) {
                        final stage = _stageFor(_progress.value);
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progress.value,
                                minHeight: 8,
                                backgroundColor: scheme.outline,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (final s in PickupStage.values) ...[
                                  if (s.index > 0) Text(' → ', style: muted),
                                  Text(
                                    s.label,
                                    style: muted?.copyWith(
                                      color: s == stage ? scheme.primary : null,
                                      fontWeight: s == stage
                                          ? FontWeight.w700
                                          : null,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '픽업 예정 ${formatTime(order.pickupAt)} · '
                      '${order.itemCount}개 · ${formatWon(order.total)}\n'
                      '${order.paymentMethod.label} 결제 완료',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showHomeButton)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.sm,
                    AppSpacing.screenPadding,
                    AppSpacing.md,
                  ),
                  child: SoftButton(
                    label: '처음으로',
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
