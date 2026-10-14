import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../data/mock_stores.dart';
import '../data/models.dart';
import '../data/pickup_store.dart';
import '../widgets/route_map.dart';
import '../widgets/store_card.dart';
import 'route_map_screen.dart';
import 'store_menu_screen.dart';

/// S2. 경로 위 픽업 가능 가게 목록
class StoreListScreen extends StatelessWidget {
  const StoreListScreen({super.key, required this.query});

  final RouteQuery query;

  void _open(BuildContext context, StoreOnRoute s) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoreMenuScreen(
          store: s.store,
          storePoint: s.point,
          walkMinutes: s.walkMinutes,
        ),
      ),
    );
  }

  Future<void> _openFullMap(
    BuildContext context,
    List<StoreOnRoute> stores,
  ) async {
    // 하단 탭을 가리도록 최상위 Navigator에 띄운다.
    final picked = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<StoreOnRoute>(
        builder: (_) => RouteMapScreen(query: query, stores: stores),
      ),
    );
    if (picked != null && context.mounted) _open(context, picked);
  }

  @override
  Widget build(BuildContext context) {
    final stores = storesOnRoute(query);
    final pickup = PickupScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      body: PageScaffold(
        backLabel: AppStrings.back,
        title: '경로 위 픽업 가능 가게',
        subtitle:
            '${query.origin.name} → ${query.destination.name}\n'
            '도보 ${query.route.durationMinutes}분 · 우회 15분 이내 · ${stores.length}곳',
        children: [
          RoutePreviewMap(
            query: query,
            stores: stores,
            onOpenFullMap: () => _openFullMap(context, stores),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            query.route.isEstimated
                ? '길찾기 서버에 연결하지 못해 직선 거리로 표시했어요.'
                : '가게 위치는 시연용으로 경로 위에 배치했어요.',
            style: muted,
          ),
          const SizedBox(height: AppSpacing.md),
          if (stores.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Text(
                '조건에 맞는 가게가 없어요.\n다른 카테고리를 골라 보세요.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final (i, s) in stores.indexed) ...[
            StoreCard(
              store: s.store,
              index: i + 1,
              walkMinutes: s.walkMinutes,
              isFavorite: pickup.isFavorite(s.store),
              onFavoriteTap: () => pickup.toggleFavorite(s.store),
              onTap: () => _open(context, s),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
