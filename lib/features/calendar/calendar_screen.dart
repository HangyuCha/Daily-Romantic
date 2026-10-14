import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/placeholder_view.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabCalendar)),
      body: const PlaceholderView(
        icon: Icons.calendar_today_rounded,
        title: AppStrings.tabCalendar,
      ),
    );
  }
}
