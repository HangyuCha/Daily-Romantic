import 'package:flutter/widgets.dart';

/// 로그인 방식
enum SocialProvider {
  kakao('kakao', '카카오');

  const SocialProvider(this.supabaseId, this.label);

  /// Supabase에 등록한 provider 이름
  final String supabaseId;
  final String label;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.nickname,
    this.email,
    this.provider = 'email',
  });

  final String id;
  final String nickname;
  final String? email;

  /// email, kakao
  final String provider;

  String get providerLabel => switch (provider) {
    'kakao' => '카카오',
    _ => '이메일',
  };
}

enum SignUpResult {
  /// 가입과 동시에 로그인됨
  signedIn,

  /// 인증 메일 확인 후 로그인 가능 (Supabase 'Confirm email' 설정이 켜져 있을 때)
  needsEmailConfirmation,
}

/// 화면에 그대로 보여줄 수 있는 한국어 메시지를 담은 예외
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// 로그인 기능의 공통 인터페이스.
/// Supabase 설정이 있으면 [SupabaseAuthRepository], 없으면 [DemoAuthRepository]를 쓴다.
abstract class AuthRepository {
  bool get isDemo => false;

  AppUser? get currentUser;

  /// 로그인·로그아웃할 때마다 현재 사용자를 내보낸다.
  Stream<AppUser?> authStateChanges();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
  });

  /// 소셜 로그인 페이지를 연다. 결과는 [authStateChanges]로 전달된다.
  Future<void> signInWithSocial(SocialProvider provider);

  Future<void> signOut();
}

/// 위젯 트리 어디서든 AuthScope.of(context)로 꺼내 쓴다.
class AuthScope extends InheritedWidget {
  const AuthScope({super.key, required this.repository, required super.child});

  final AuthRepository repository;

  static AuthRepository of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()!.repository;

  @override
  bool updateShouldNotify(AuthScope old) => old.repository != repository;
}
