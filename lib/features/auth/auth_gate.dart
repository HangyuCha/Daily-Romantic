import 'package:flutter/material.dart';

import '../shell/main_shell.dart';
import 'data/auth_repository.dart';
import 'login_screen.dart';

/// 로그인 상태에 따라 로그인 화면 또는 메인 화면을 보여준다.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return StreamBuilder<AppUser?>(
      stream: auth.authStateChanges(),
      initialData: auth.currentUser,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: snapshot.data == null
              ? const LoginScreen(key: ValueKey('login'))
              : const MainShell(key: ValueKey('main')),
        );
      },
    );
  }
}
