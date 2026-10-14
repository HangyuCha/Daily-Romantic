/// 로그인·회원가입 입력 검증. 통과하면 null, 아니면 오류 문구를 돌려준다.
class AuthValidators {
  AuthValidators._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static const minPasswordLength = 8;

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '이메일을 입력해 주세요.';
    if (!_emailPattern.hasMatch(v)) return '이메일 형식이 올바르지 않아요.';
    return null;
  }

  static String? loginPassword(String? value) =>
      (value ?? '').isEmpty ? '비밀번호를 입력해 주세요.' : null;

  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.length < minPasswordLength) {
      return '비밀번호는 $minPasswordLength자 이상이어야 해요.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return '영문과 숫자를 함께 넣어 주세요.';
    }
    return null;
  }

  static String? nickname(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '닉네임을 입력해 주세요.';
    if (v.length < 2 || v.length > 12) return '닉네임은 2~12자로 정해 주세요.';
    return null;
  }
}
