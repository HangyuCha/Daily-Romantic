import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/page_scaffold.dart';
import 'data/auth_repository.dart';
import 'widgets/auth_validators.dart';

enum _Agreement {
  terms('[필수] 서비스 이용약관 동의', required: true),
  privacy('[필수] 개인정보 수집·이용 동의', required: true),
  age('[필수] 만 14세 이상입니다', required: true),
  marketing('[선택] 이벤트·혜택 알림 수신 동의', required: false);

  const _Agreement(this.label, {required this.required});
  final String label;
  final bool required;
}

/// 이메일 회원가입: 닉네임, 이메일, 비밀번호(확인), 약관 동의
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nickname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _agreed = <_Agreement>{};
  var _obscure = true;
  var _loading = false;

  @override
  void dispose() {
    _nickname.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  bool get _allAgreed => _agreed.length == _Agreement.values.length;

  bool get _requiredAgreed =>
      _Agreement.values.where((a) => a.required).every(_agreed.contains);

  void _toggleAll(bool? value) => setState(() {
    value == true ? _agreed.addAll(_Agreement.values) : _agreed.clear();
  });

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = AuthScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _loading = true);
    try {
      final result = await auth.signUpWithEmail(
        email: _email.text.trim(),
        password: _password.text,
        nickname: _nickname.text.trim(),
      );
      if (!mounted) return;
      if (result == SignUpResult.needsEmailConfirmation) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('메일함을 확인해 주세요'),
            content: Text(
              '${_email.text.trim()}로 인증 메일을 보냈어요.\n'
              '메일의 링크를 누르면 가입이 완료돼요.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
      // 가입과 동시에 로그인되면 AuthGate가 메인 화면으로 바꿔 준다.
      navigator.pop();
    } on AuthFailure catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.loginFailed)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Scaffold(
      body: Form(
        key: _formKey,
        child: PageScaffold(
          backLabel: AppStrings.back,
          title: '회원가입',
          subtitle: '이메일로 간단하게 가입하세요.',
          bottom: FilledButton(
            onPressed: _requiredAgreed && !_loading ? _submit : null,
            child: _loading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('가입하기'),
          ),
          children: [
            Text('닉네임', style: labelStyle),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _nickname,
              textInputAction: TextInputAction.next,
              maxLength: 12,
              decoration: const InputDecoration(
                hintText: '2~12자',
                counterText: '',
              ),
              validator: AuthValidators.nickname,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('이메일', style: labelStyle),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(hintText: 'example@email.com'),
              validator: AuthValidators.email,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('비밀번호', style: labelStyle),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                hintText: '영문·숫자 포함 ${AuthValidators.minPasswordLength}자 이상',
                suffixIcon: IconButton(
                  tooltip: _obscure ? '비밀번호 보기' : '비밀번호 숨기기',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                ),
              ),
              validator: AuthValidators.newPassword,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _passwordConfirm,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(hintText: '비밀번호 확인'),
              validator: (v) => v != _password.text ? '비밀번호가 서로 달라요.' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _allAgreed,
                      onChanged: _toggleAll,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        '전체 동의',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    for (final a in _Agreement.values)
                      CheckboxListTile(
                        dense: true,
                        value: _agreed.contains(a),
                        onChanged: (v) => setState(
                          () => v == true ? _agreed.add(a) : _agreed.remove(a),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(a.label, style: theme.textTheme.bodyMedium),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
