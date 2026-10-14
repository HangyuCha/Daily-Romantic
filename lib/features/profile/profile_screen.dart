import 'package:flutter/material.dart';

import '../../core/config/env.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/placeholder_view.dart';
import '../auth/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabProfile)),
      body: Column(
        children: [
          const Expanded(
            child: PlaceholderView(
              icon: Icons.person_rounded,
              title: AppStrings.tabProfile,
            ),
          ),
          if (Env.isConfigured)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: TextButton(
                onPressed: () => AuthService().signOut(),
                child: const Text(AppStrings.logout),
              ),
            ),
        ],
      ),
    );
  }
}
