import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../calendar/calendar_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

/// 하단 탭 바와 탭별 화면을 묶는 뼈대. 탭을 추가/삭제하려면 _tabs만 고치면 된다.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    (
      label: AppStrings.tabHome,
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
      screen: HomeScreen(),
    ),
    (
      label: AppStrings.tabCalendar,
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today_rounded,
      screen: CalendarScreen(),
    ),
    (
      label: AppStrings.tabProfile,
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      screen: ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack: 탭을 오가도 각 화면의 스크롤 위치 등 상태가 유지된다.
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
          onDestinationSelected: (i) => setState(() => _index = i),
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
