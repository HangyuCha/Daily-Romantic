import 'package:flutter/material.dart';

import '../../../core/location/geo.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/emoji_thumb.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../data/models.dart';
import '../widgets/quantity_stepper.dart';
import 'pickup_time_screen.dart';

/// S3. 가게 상세 — 메뉴 선택 및 장바구니.
/// 이 화면을 벗어나면(가게 목록으로 돌아가면) 장바구니는 버려진다.
class StoreMenuScreen extends StatefulWidget {
  const StoreMenuScreen({
    super.key,
    required this.store,
    this.storePoint,
    this.walkMinutes,
  });

  final Store store;

  /// S2 지도에서 넘어온 가게 위치와 도보 시간 (찜 탭에서 열면 null)
  final LatLng? storePoint;
  final int? walkMinutes;

  @override
  State<StoreMenuScreen> createState() => _StoreMenuScreenState();
}

class _StoreMenuScreenState extends State<StoreMenuScreen> {
  late final _cart = Cart(
    widget.store,
    storePoint: widget.storePoint,
    walkMinutes: widget.walkMinutes,
  );

  Future<void> _editMessage() async {
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _MessageSheet(initial: _cart.message),
    );
    if (message != null) setState(() => _cart.message = message);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: PageScaffold(
        backLabel: '← 가게 목록',
        title: store.name,
        subtitle:
            '${widget.walkMinutes == null ? '' : '도보 ${widget.walkMinutes}분 · '}'
            '+${store.detourMinutes}분 우회 · 평균 준비 ${store.prepMinutes}분',
        bottom: FilledButton(
          onPressed: _cart.isEmpty
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PickupTimeScreen(cart: _cart),
                  ),
                ),
          child: Text(
            _cart.isEmpty
                ? '장바구니 비었어요'
                : '${_cart.itemCount}개 담기 · ${formatWon(_cart.total)}',
          ),
        ),
        children: [
          for (final item in store.menu) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    EmojiThumb(item.emoji),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatWon(item.price),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    QuantityStepper(
                      value: _cart.quantityOf(item),
                      onChanged: (q) =>
                          setState(() => _cart.setQuantity(item, q)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.xs),
          // 메시지 카드 (선택)
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _editMessage,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    const Text('💌', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _cart.message.isEmpty
                            ? '메시지 카드 추가 (선택)'
                            : _cart.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _cart.message.isEmpty
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      _cart.message.isEmpty
                          ? Icons.add_rounded
                          : Icons.edit_rounded,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageSheet extends StatefulWidget {
  const _MessageSheet({required this.initial});

  final String initial;

  @override
  State<_MessageSheet> createState() => _MessageSheetState();
}

class _MessageSheetState extends State<_MessageSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('메시지 카드', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 80,
            maxLines: 3,
            decoration: const InputDecoration(hintText: '예) 오늘 하루도 고생 많았어요 :)'),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
