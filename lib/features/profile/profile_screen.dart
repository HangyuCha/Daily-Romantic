import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/placeholder_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabProfile)),
      body: const PlaceholderView(
        icon: Icons.person_rounded,
        title: AppStrings.tabProfile,
      ),
    );
  }
}
