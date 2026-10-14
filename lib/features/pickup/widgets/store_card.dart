import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/emoji_thumb.dart';
import '../data/models.dart';

/// 가게 카드: 썸네일 + 가게명 + 도보·우회 시간 + 태그. 카드 전체가 탭 영역.
class StoreCard extends StatelessWidget {
  const StoreCard({
    super.key,
    required this.store,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    this.index,
    this.walkMinutes,
  });

  final Store store;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  /// 지도 핀 번호와 맞추기 위한 순번 (1부터)
  final int? index;

  /// 실제 경로 기준 도보 시간. 없으면 가게 기본값을 쓴다.
  final int? walkMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              EmojiThumb(store.emoji),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      index == null ? store.name : '$index. ${store.name}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '도보 ${walkMinutes ?? store.walkMinutes}분 · +${store.detourMinutes}분 우회',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _Tag(store.tag),
              IconButton(
                onPressed: onFavoriteTap,
                tooltip: isFavorite ? '찜 해제' : '찜하기',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? scheme.primary : scheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: scheme.primary,
        ),
      ),
    );
  }
}
