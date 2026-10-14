import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository extends AuthRepository {
  SupabaseAuthRepository([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.onAuthStateChange.map((state) => _toAppUser(state.session?.user));

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _guard(() => _auth.signInWithPassword(email: email, password: password));

  @override
  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final response = await _guard(
      () => _auth.signUp(
        email: email,
        password: password,
        // profiles 테이블 트리거가 이 값으로 닉네임을 채운다.
        data: {'nickname': nickname},
        emailRedirectTo: Env.authRedirectUrl,
      ),
    );
    // 이미 가입된 이메일이면 Supabase는 오류 대신 identities가 빈 사용자를 돌려준다.
    if (response.user?.identities?.isEmpty ?? false) {
      throw const AuthFailure('이미 가입된 이메일이에요.');
    }
    return response.session == null
        ? SignUpResult.needsEmailConfirmation
        : SignUpResult.signedIn;
  }

  @override
  Future<void> signInWithSocial(SocialProvider provider) => _guard(
    () => _auth.signInWithOAuth(
      OAuthProvider(provider.supabaseId),
      redirectTo: Env.authRedirectUrl,
      // iOS 앱 안 브라우저(SFSafariViewController)는 로그인 후 dailyromantic://
      // 주소로 넘어가지 못하고 멈춘다. Safari 앱으로 열면 앱으로 돌아올 수 있다.
      authScreenLaunchMode: LaunchMode.externalApplication,
    ),
  );

  @override
  Future<void> signOut() => _auth.signOut();

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    final meta = user.userMetadata ?? const {};
    final nickname =
        meta['nickname'] ??
        meta['name'] ??
        meta['full_name'] ??
        user.email?.split('@').first ??
        '회원';
    return AppUser(
      id: user.id,
      email: user.email,
      nickname: '$nickname',
      provider: '${user.appMetadata['provider'] ?? 'email'}',
    );
  }

  /// Supabase 오류를 화면에 보여줄 한국어 메시지로 바꾼다.
  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on AuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    } catch (_) {
      throw const AuthFailure('네트워크 상태를 확인하고 다시 시도해 주세요.');
    }
  }

  String _messageFor(AuthException e) {
    final code = e.code ?? '';
    final message = e.message.toLowerCase();
    if (code == 'invalid_credentials' || message.contains('invalid login')) {
      return '이메일 또는 비밀번호가 맞지 않아요.';
    }
    if (code == 'email_not_confirmed') return '메일함에서 이메일 인증을 먼저 완료해 주세요.';
    if (code == 'user_already_exists') return '이미 가입된 이메일이에요.';
    if (code == 'weak_password') return '비밀번호가 너무 단순해요. 8자 이상으로 정해 주세요.';
    if (code.contains('rate_limit') || e.statusCode == '429') {
      return '요청이 많아요. 잠시 후 다시 시도해 주세요.';
    }
    return '로그인 처리 중 문제가 생겼어요. 다시 시도해 주세요.';
  }
}
