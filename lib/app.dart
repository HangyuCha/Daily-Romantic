import 'package:flutter/material.dart';

import 'core/config/env.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/shell/main_shell.dart';

class DailyRomanticApp extends StatelessWidget {
  const DailyRomanticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      // 백엔드 설정이 없으면 로그인을 건너뛰고 UI 작업만 할 수 있게 한다.
      home: Env.isConfigured ? const AuthGate() : const MainShell(),
    );
  }
}
