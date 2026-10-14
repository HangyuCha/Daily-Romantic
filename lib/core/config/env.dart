/// 빌드할 때 `--dart-define-from-file=env.json` 으로 넣어 주는 값.
/// env.json은 git에 올리지 않는다 (env.example.json 참고).
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// 소셜 로그인 후 앱으로 돌아올 딥링크. iOS Info.plist / AndroidManifest와 맞춰야 한다.
  static const authRedirectUrl = 'dailyromantic://login-callback';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
