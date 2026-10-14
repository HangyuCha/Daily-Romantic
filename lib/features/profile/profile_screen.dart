import 'package:flutter/material.dart';

import '../../core/config/env.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../auth/auth_service.dart';

/// MY 탭
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '내 정보',
      children: [
        const EmptyView(
          emoji: '👤',
          title: '준비 중이에요',
          message: '내 정보 화면은 곧 채워질 예정이에요.',
        ),
        if (Env.isConfigured)
          TextButton(
            onPressed: () => AuthService().signOut(),
            child: const Text(AppStrings.logout),
          ),
      ],
    );
  }
}
