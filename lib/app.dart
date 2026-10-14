import 'package:flutter/material.dart';

import 'core/config/env.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/pickup/data/pickup_store.dart';
import 'features/shell/main_shell.dart';

class DailyRomanticApp extends StatefulWidget {
  const DailyRomanticApp({super.key});

  @override
  State<DailyRomanticApp> createState() => _DailyRomanticAppState();
}

class _DailyRomanticAppState extends State<DailyRomanticApp> {
  final _pickupStore = PickupStore();

  @override
  void dispose() {
    _pickupStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PickupScope(
      store: _pickupStore,
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        // 백엔드 설정이 없으면 로그인을 건너뛰고 UI 작업만 할 수 있게 한다.
        home: Env.isConfigured ? const AuthGate() : const MainShell(),
      ),
    );
  }
}
