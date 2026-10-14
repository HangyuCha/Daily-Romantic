import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'data/auth_repository.dart';
import 'signup_screen.dart';
import 'widgets/auth_validators.dart';

/// 로그인 화면: Daily Romantic 워드마크 + 카카오 로그인 + 이메일 로그인(펼치기) + 회원가입
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
  var _showEmail = false;

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

  void _signInWithKakao() {
    final auth = AuthScope.of(context);
    _run(
      SocialProvider.kakao,
      () => auth.signInWithSocial(SocialProvider.kakao),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDemo = AuthScope.of(context).isDemo;
    final busy = _loading != null;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _MoodBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 3),
                          const _FadeIn(child: _Wordmark()),
                          const Spacer(flex: 3),
                          _FadeIn(
                            delay: const Duration(milliseconds: 250),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _KakaoButton(
                                  loading: _loading == SocialProvider.kakao,
                                  onPressed: busy ? null : _signInWithKakao,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                if (!_showEmail)
                                  OutlinedButton(
                                    onPressed: busy
                                        ? null
                                        : () =>
                                              setState(() => _showEmail = true),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(52),
                                      foregroundColor: scheme.onSurface,
                                      backgroundColor: scheme.surface
                                          .withValues(alpha: 0.7),
                                      side: BorderSide(color: scheme.outline),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusMd,
                                        ),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    child: const Text(
                                      AppStrings.loginWithEmail,
                                    ),
                                  ),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  child: _showEmail
                                      ? _emailForm(busy)
                                      : const SizedBox(width: double.infinity),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '처음이신가요?',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                    TextButton(
                                      onPressed: busy
                                          ? null
                                          : () => Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const SignUpScreen(),
                                              ),
                                            ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: scheme.primary,
                                      ),
                                      child: const Text('회원가입'),
                                    ),
                                  ],
                                ),
                                if (isDemo)
                                  Text(
                                    '데모 모드 · 가입 정보는 이 기기에서만 잠시 유지돼요',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailForm(bool busy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _email,
          autofocus: true,
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
        const SizedBox(height: AppSpacing.sm),
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
      ],
    );
  }
}

/// 세리프 글꼴. iOS 기본 글꼴(Didot)을 쓰고, 없으면 시스템 세리프로 대체한다.
const _serif = 'Didot';
const _serifFallback = ['Bodoni 72', 'Georgia', 'Times New Roman', 'serif'];

/// DAILY / Romantic 워드마크와 슬로건
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Daily Romantic, ${AppStrings.tagline}',
      excludeSemantics: true,
      child: Column(
        children: [
          Text(
            'DAILY',
            style: TextStyle(
              fontFamily: _serif,
              fontFamilyFallback: _serifFallback,
              fontSize: 17,
              letterSpacing: 11,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          Text(
            'Romantic',
            style: TextStyle(
              fontFamily: _serif,
              fontFamilyFallback: _serifFallback,
              fontSize: 64,
              height: 1.05,
              fontStyle: FontStyle.italic,
              letterSpacing: -1,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HairLine(color: scheme.primary),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 12,
                  color: scheme.primary.withValues(alpha: 0.8),
                ),
              ),
              _HairLine(color: scheme.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '가는 길에 15분,\n마음을 픽업하세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              letterSpacing: 0.2,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HairLine extends StatelessWidget {
  const _HairLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 44, height: 1, color: color.withValues(alpha: 0.4));
}

/// 배경색은 그대로 두고, 은은한 분홍빛 번짐과 작은 반짝임만 얹는다.
class _MoodBackground extends StatelessWidget {
  const _MoodBackground();

  @override
  Widget build(BuildContext context) {
    final pink = Theme.of(context).colorScheme.primary;
    Widget glow(double size, double alpha) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            pink.withValues(alpha: alpha),
            pink.withValues(alpha: 0),
          ],
        ),
      ),
    );
    Widget sparkle(String c, double size, double alpha) => Text(
      c,
      style: TextStyle(
        fontSize: size,
        color: pink.withValues(alpha: alpha),
      ),
    );

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: -w * 0.35,
                right: -w * 0.3,
                child: glow(w * 1.0, 0.16),
              ),
              Positioned(
                top: h * 0.42,
                left: -w * 0.45,
                child: glow(w * 0.9, 0.10),
              ),
              Positioned(
                bottom: -w * 0.4,
                right: -w * 0.2,
                child: glow(w * 0.9, 0.12),
              ),
              Positioned(
                top: h * 0.14,
                left: w * 0.16,
                child: sparkle('✦', 14, 0.35),
              ),
              Positioned(
                top: h * 0.22,
                right: w * 0.14,
                child: sparkle('♡', 18, 0.30),
              ),
              Positioned(
                top: h * 0.46,
                right: w * 0.2,
                child: sparkle('✦', 9, 0.30),
              ),
              Positioned(
                top: h * 0.08,
                right: w * 0.36,
                child: sparkle('·', 22, 0.35),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 처음 열릴 때 살짝 떠오르며 나타나는 효과
class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final total = const Duration(milliseconds: 700) + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// 카카오 로그인 버튼 (카카오 디자인 가이드: 노란 배경 + 말풍선 + 검정 글자)
class _KakaoButton extends StatelessWidget {
  const _KakaoButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.kakao,
        foregroundColor: AppColors.kakaoText,
        disabledBackgroundColor: AppColors.kakao.withValues(alpha: 0.6),
        disabledForegroundColor: AppColors.kakaoText.withValues(alpha: 0.6),
      ),
      child: loading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.kakaoText,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_rounded, size: 18),
                SizedBox(width: 8),
                Text(AppStrings.loginWithKakao),
              ],
            ),
    );
  }
}
