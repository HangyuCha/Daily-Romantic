import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../favorites/favorites_screen.dart';
import '../orders/orders_screen.dart';
import '../pickup/screens/route_input_screen.dart';
import '../profile/profile_screen.dart';

/// 하단 탭 바와 탭별 화면을 묶는 뼈대. 탭을 추가/삭제하려면 _tabs만 고치면 된다.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // 홈 탭은 S1~S5를 탭 안에서 이동하도록 자체 Navigator를 가진다 (하단 탭 유지).
  final _homeNavigatorKey = GlobalKey<NavigatorState>();

  late final _tabs = [
    (
      label: AppStrings.tabHome,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      screen: NavigatorPopHandler(
        onPopWithResult: (_) => _homeNavigatorKey.currentState?.maybePop(),
        child: Navigator(
          key: _homeNavigatorKey,
          onGenerateRoute: (_) =>
              MaterialPageRoute(builder: (_) => const RouteInputScreen()),
        ),
      ),
    ),
    (
      label: AppStrings.tabOrders,
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      screen: const Scaffold(body: OrdersScreen()),
    ),
    (
      label: AppStrings.tabFavorites,
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
      screen: const Scaffold(body: FavoritesScreen()),
    ),
    (
      label: AppStrings.tabMy,
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      screen: const Scaffold(body: ProfileScreen()),
    ),
  ];

  void _onTabSelected(int i) {
    // 홈 탭을 다시 누르면 S1으로 돌아간다.
    if (i == _index && i == 0) {
      _homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack: 탭을 오가도 각 화면의 입력값·스크롤 위치가 유지된다.
      body: IndexedStack(
        index: _index,
        children: [for (final tab in _tabs) tab.screen],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _onTabSelected,
          destinations: [
            for (final tab in _tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}
