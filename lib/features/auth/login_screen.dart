import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import 'data/auth_repository.dart';
import 'signup_screen.dart';
import 'widgets/auth_validators.dart';
import 'widgets/social_login_buttons.dart';

/// 로그인 화면: 이메일 로그인 + 카카오·네이버 + 회원가입 이동
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _obscure = true;

  /// 'email' 또는 SocialProvider. null이면 대기 중
  Object? _loading;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Object key, Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = key);
    try {
      await action();
    } on AuthFailure catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(AppStrings.loginFailed);
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _signInWithEmail() {
    if (!_formKey.currentState!.validate()) return;
    final auth = AuthScope.of(context);
    _run(
      'email',
      () => auth.signInWithEmail(
        email: _email.text.trim(),
        password: _password.text,
      ),
    );
  }

  void _signInWithSocial(SocialProvider provider) {
    final auth = AuthScope.of(context);
    _run(provider, () => auth.signInWithSocial(provider));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDemo = AuthScope.of(context).isDemo;
    final busy = _loading != null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '💝',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppStrings.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (isDemo) ...[
                    const SizedBox(height: AppSpacing.md),
                    const _DemoNotice(),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(hintText: '이메일'),
                    validator: AuthValidators.email,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _signInWithEmail(),
                    decoration: InputDecoration(
                      hintText: '비밀번호',
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
                    validator: AuthValidators.loginPassword,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: busy ? null : _signInWithEmail,
                    child: _loading == 'email'
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('로그인'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '아직 회원이 아니신가요?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              ),
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.primary,
                        ),
                        child: const Text('회원가입'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _OrDivider(),
                  const SizedBox(height: AppSpacing.md),
                  SocialLoginButtons(
                    loading: _loading is SocialProvider
                        ? _loading as SocialProvider
                        : null,
                    onPressed: busy ? null : _signInWithSocial,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            '간편 로그인',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        '데모 모드예요. 서버 없이 앱 안에서만 가입·로그인되고, 앱을 끄면 정보가 사라져요.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.5, color: scheme.primary, height: 1.4),
      ),
    );
  }
}
