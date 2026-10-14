import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../pickup/data/mock_stores.dart';
import '../pickup/data/pickup_store.dart';
import '../pickup/screens/store_menu_screen.dart';
import '../pickup/widgets/store_card.dart';

/// 찜 탭 — 하트를 누른 가게 모음
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pickup = PickupScope.of(context);
    final stores = mockStores.where(pickup.isFavorite).toList();

    return PageScaffold(
      title: '찜한 가게',
      subtitle: '자주 들르는 가게를 모아 두세요.',
      children: [
        if (stores.isEmpty)
          const EmptyView(
            emoji: '💗',
            title: '찜한 가게가 없어요',
            message: '가게 목록에서 하트를 눌러 보세요.',
          ),
        for (final store in stores) ...[
          StoreCard(
            store: store,
            isFavorite: true,
            onFavoriteTap: () => pickup.toggleFavorite(store),
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => StoreMenuScreen(store: store)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
