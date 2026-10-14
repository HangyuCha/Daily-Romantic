import 'dart:async';

import 'auth_repository.dart';

/// Supabase 설정(env.json)이 없을 때 쓰는 가짜 로그인.
/// 가입 정보는 앱 메모리에만 있고, 앱을 끄면 사라진다. 시연·UI 작업용.
class DemoAuthRepository extends AuthRepository {
  DemoAuthRepository({AppUser? signedInUser}) : _current = signedInUser;

  final _accounts = <String, ({String password, AppUser user})>{};
  final _changes = StreamController<AppUser?>.broadcast();
  AppUser? _current;

  @override
  bool get isDemo => true;

  @override
  AppUser? get currentUser => _current;

  @override
  Stream<AppUser?> authStateChanges() => _changes.stream;

  void _set(AppUser? user) {
    _current = user;
    _changes.add(user);
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _fakeDelay();
    final account = _accounts[email.toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthFailure('이메일 또는 비밀번호가 맞지 않아요.');
    }
    _set(account.user);
  }

  @override
  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
  }) async {
    await _fakeDelay();
    final key = email.toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthFailure('이미 가입된 이메일이에요.');
    }
    final user = AppUser(id: 'demo-$key', email: email, nickname: nickname);
    _accounts[key] = (password: password, user: user);
    _set(user);
    return SignUpResult.signedIn;
  }

  @override
  Future<void> signInWithSocial(SocialProvider provider) async {
    await _fakeDelay();
    _set(
      AppUser(
        id: 'demo-${provider.name}',
        nickname: '${provider.label} 사용자',
        provider: provider.supabaseId,
      ),
    );
  }

  @override
  Future<void> signOut() async => _set(null);

  Future<void> _fakeDelay() =>
      Future.delayed(const Duration(milliseconds: 400));
}
