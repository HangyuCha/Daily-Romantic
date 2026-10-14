import 'package:flutter/material.dart';

import 'core/config/env.dart';
import 'core/constants/app_strings.dart';
import 'core/location/map_services.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/demo_auth_repository.dart';
import 'features/auth/data/supabase_auth_repository.dart';
import 'features/pickup/data/pickup_store.dart';

class DailyRomanticApp extends StatefulWidget {
  const DailyRomanticApp({super.key, this.authRepository, this.mapServices});

  /// 테스트에서 바꿔 끼울 때만 넘긴다. 없으면 env.json 설정에 따라 고른다.
  final AuthRepository? authRepository;

  /// 테스트에서 가짜 GPS·검색·길찾기로 바꿔 끼울 때만 넘긴다.
  final MapServices? mapServices;

  @override
  State<DailyRomanticApp> createState() => _DailyRomanticAppState();
}

class _DailyRomanticAppState extends State<DailyRomanticApp> {
  // Supabase 설정(env.json)이 없으면 앱 안에서만 동작하는 데모 로그인을 쓴다.
  late final AuthRepository _auth =
      widget.authRepository ??
      (Env.isConfigured ? SupabaseAuthRepository() : DemoAuthRepository());
  late final _mapServices = widget.mapServices ?? MapServices.live();
  final _pickupStore = PickupStore();

  @override
  void dispose() {
    _pickupStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      repository: _auth,
      child: MapScope(
        services: _mapServices,
        child: PickupScope(
          store: _pickupStore,
          child: MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            home: const AuthGate(),
          ),
        ),
      ),
    );
  }
}
