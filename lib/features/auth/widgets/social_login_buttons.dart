import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/auth_repository.dart';

/// 카카오·네이버 로그인 버튼 (각 사 브랜드 컬러)
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  /// 로딩 중인 provider. 하나라도 진행 중이면 모든 버튼을 막는다.
  final SocialProvider? loading;

  /// null이면 버튼이 비활성화된다.
  final ValueChanged<SocialProvider>? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Button(
          label: AppStrings.loginWithKakao,
          background: AppColors.kakao,
          foreground: AppColors.kakaoText,
          loading: loading == SocialProvider.kakao,
          onPressed: onPressed == null
              ? null
              : () => onPressed!(SocialProvider.kakao),
        ),
        const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
        _Button(
          label: AppStrings.loginWithNaver,
          background: AppColors.naver,
          foreground: Colors.white,
          loading: loading == SocialProvider.naver,
          onPressed: onPressed == null
              ? null
              : () => onPressed!(SocialProvider.naver),
        ),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
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
