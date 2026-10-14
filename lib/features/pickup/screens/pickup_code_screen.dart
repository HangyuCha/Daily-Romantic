import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_map.dart';
import '../../../shared/widgets/soft_button.dart';
import '../data/models.dart';
import '../data/pickup_store.dart';

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

class _PickupCodeScreenState extends State<PickupCodeScreen> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    // 가게 쪽 상태 연동 전까지는 주문~픽업 시각의 시간 흐름으로 진행 상황을 보여준다.
    _ticker = Timer.periodic(
      const Duration(seconds: 5),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  Future<void> _complete(PickupStore pickup, PickupStage stage) async {
    if (stage != PickupStage.ready) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('아직 준비 중이에요'),
          content: const Text('가게에서 받으셨다면 픽업 완료로 바꿀게요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('픽업 완료'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    pickup.completeOrder(widget.order);
  }

  /// 단계별 진행 바 최소값 (시연용으로 단계를 넘겼을 때 바도 따라가도록)
  static const _stageFloor = {
    PickupStage.preparing: 0.1,
    PickupStage.packed: 0.6,
    PickupStage.ready: 1.0,
  };

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final pickup = PickupScope.of(context);
    final now = DateTime.now();
    final stage = pickup.stageOf(order, now);
    final completed = pickup.isCompleted(order);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final timeValue = 0.1 + 0.9 * order.progressAt(now);
    final progress = completed
        ? 1.0
        : (timeValue > _stageFloor[stage]! ? timeValue : _stageFloor[stage]!);

    final String emoji;
    final String title;
    final String message;
    if (completed) {
      emoji = '💝';
      title = '픽업 완료!';
      message = '${order.store.name}에서 픽업을 마쳤어요.\n마음이 잘 전해지길 바라요.';
    } else if (stage == PickupStage.ready) {
      emoji = '🛍️';
      title = stage.headline;
      message = '${order.store.name}에 들러\n아래 코드를 보여주세요.';
    } else {
      emoji = '🎁';
      title = stage.headline;
      message = '${order.store.name}에서 준비하고 있어요.\n목적지 도착 전에 들르세요!';
    }

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
                    Text(
                      emoji,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 56),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(message, textAlign: TextAlign.center, style: muted),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      order.code,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                        color: completed
                            ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
                            : scheme.primary,
                      ),
                    ),
                    Text(
                      completed ? '사용한 픽업 코드' : '매장에서 이 코드를 보여주세요',
                      textAlign: TextAlign.center,
                      style: muted,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: progress),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, v, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 8,
                          backgroundColor: scheme.outline,
                        ),
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
                              color: s == stage && !completed
                                  ? scheme.primary
                                  : null,
                              fontWeight: s == stage && !completed
                                  ? FontWeight.w700
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (order.storePoint != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        child: SizedBox(
                          height: 160,
                          child: AppMap(
                            interactive: false,
                            points: [order.storePoint!],
                            layers: [
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: order.storePoint!,
                                    width: 36,
                                    height: 36,
                                    child: MapPin(
                                      label: order.store.emoji,
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!completed) ...[
                      FilledButton(
                        onPressed: () => _complete(pickup, stage),
                        child: const Text('픽업했어요'),
                      ),
                      if (stage != PickupStage.ready)
                        TextButton(
                          onPressed: () => pickup.advanceStage(order),
                          child: Text(
                            '시연용 · 가게 상태를 '
                            '\'${PickupStage.values[stage.index + 1].label}\'(으)로',
                          ),
                        ),
                    ],
                    if (widget.showHomeButton) ...[
                      const SizedBox(height: AppSpacing.xs),
                      SoftButton(
                        label: '처음으로',
                        onPressed: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
