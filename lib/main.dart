import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
    );
  } else {
    debugPrint('[Env] env.json 없이 실행 중: 로그인 없이 화면만 확인할 수 있어요.');
  }

  runApp(const DailyRomanticApp());
}
