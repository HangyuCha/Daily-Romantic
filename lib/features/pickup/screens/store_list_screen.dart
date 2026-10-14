import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../data/mock_stores.dart';
import '../data/models.dart';
import '../data/pickup_store.dart';
import '../widgets/route_map.dart';
import '../widgets/store_card.dart';
import 'store_menu_screen.dart';

/// S2. 경로 위 픽업 가능 가게 목록
class StoreListScreen extends StatelessWidget {
  const StoreListScreen({super.key, required this.query});

  final RouteQuery query;

  @override
  Widget build(BuildContext context) {
    final stores = searchStores(query);
    final pickup = PickupScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: PageScaffold(
        backLabel: AppStrings.back,
        title: '경로 위 픽업 가능 가게',
        subtitle:
            '${query.origin} → ${query.destination}\n'
            '우회 15분 이내 · ${stores.length}곳',
        children: [
          RouteMap(stores: stores),
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
          for (final (i, store) in stores.indexed) ...[
            StoreCard(
              store: store,
              index: i + 1,
              isFavorite: pickup.isFavorite(store),
              onFavoriteTap: () => pickup.toggleFavorite(store),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StoreMenuScreen(store: store),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
