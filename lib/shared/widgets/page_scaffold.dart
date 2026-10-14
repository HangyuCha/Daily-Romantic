import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'app_header.dart';

/// 탭 안 화면의 공통 틀: 로고 헤더 + (뒤로 링크) + 제목·설명 + 본문 + 하단 고정 버튼.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.backLabel,
    this.onBack,
    required this.children,
    this.bottom,
  });

  final String title;
  final String? subtitle;

  /// 예: '← 뒤로', '← 가게 목록'. null이면 뒤로 링크를 숨긴다.
  final String? backLabel;
  final VoidCallback? onBack;
  final List<Widget> children;

  /// 화면 하단에 고정되는 버튼 영역
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                AppSpacing.lg,
              ),
              children: [
                if (backLabel != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onBack ?? () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(backLabel!),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Text(title, style: theme.textTheme.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                ...children,
              ],
            ),
          ),
          if (bottom != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              child: bottom,
            ),
        ],
      ),
    );
  }
}
