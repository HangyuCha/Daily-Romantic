import 'package:flutter/material.dart';

import '../shell/main_shell.dart';
import 'auth_service.dart';
import 'login_screen.dart';

/// 로그인 상태에 따라 로그인 화면 또는 메인 화면을 보여준다.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.onAuthStateChange,
      builder: (context, _) {
        return _auth.currentSession == null
            ? LoginScreen(onSignIn: _auth.signIn)
            : const MainShell();
      },
    );
  }
}
