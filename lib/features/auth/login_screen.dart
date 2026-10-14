import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onSignIn});

  final Future<void> Function(SocialProvider provider) onSignIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  SocialProvider? _loading;

  Future<void> _signIn(SocialProvider provider) async {
    setState(() => _loading = provider);
    try {
      await widget.onSignIn(provider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.loginFailed)));
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.favorite_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.appName,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.loginSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              _SocialButton(
                label: AppStrings.loginWithKakao,
                // 카카오 브랜드 가이드 색상
                background: const Color(0xFFFEE500),
                foreground: const Color(0xD9000000),
                loading: _loading == SocialProvider.kakao,
                onPressed: _loading == null
                    ? () => _signIn(SocialProvider.kakao)
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              _SocialButton(
                label: AppStrings.loginWithNaver,
                // 네이버 브랜드 가이드 색상
                background: const Color(0xFF03C75A),
                foreground: Colors.white,
                loading: _loading == SocialProvider.naver,
                onPressed: _loading == null
                    ? () => _signIn(SocialProvider.naver)
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: background.withValues(alpha: 0.6),
        disabledForegroundColor: foreground.withValues(alpha: 0.6),
      ),
      child: loading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
              ),
            )
          : Text(label),
    );
  }
}
