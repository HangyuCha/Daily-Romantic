import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';

/// 로그인 방식. Supabase 대시보드에 등록한 provider 이름과 맞춘다.
enum SocialProvider {
  kakao(OAuthProvider.kakao),
  // 네이버는 Supabase 커스텀 OIDC provider로 등록한다 (식별자: custom:naver).
  naver(OAuthProvider('custom:naver'));

  const SocialProvider(this.oauthProvider);
  final OAuthProvider oauthProvider;
}

class AuthService {
  AuthService([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// 로그인 페이지를 열고, 완료되면 딥링크로 앱에 돌아와 세션이 저장된다.
  /// 결과는 [onAuthStateChange]로 전달된다.
  Future<void> signIn(SocialProvider provider) {
    return _client.auth.signInWithOAuth(
      provider.oauthProvider,
      redirectTo: Env.authRedirectUrl,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}
