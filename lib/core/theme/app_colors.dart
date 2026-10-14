import 'package:flutter/material.dart';

/// 브랜드 컬러. 색을 바꾸고 싶으면 이 파일만 수정하면 된다.
class AppColors {
  AppColors._();

  // 포인트 컬러: 채도를 낮춘 로즈 톤
  static const rose = Color(0xFFE0607E);
  static const roseSoft = Color(0xFFFBE7EC);

  // 라이트 모드 중립 색
  static const background = Color(0xFFFAFAF9);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1C1B1F);
  static const textSecondary = Color(0xFF6B6870);
  static const divider = Color(0xFFECEAEE);

  // 다크 모드 중립 색
  static const backgroundDark = Color(0xFF121113);
  static const surfaceDark = Color(0xFF1C1B1E);
  static const textPrimaryDark = Color(0xFFF4F2F5);
  static const textSecondaryDark = Color(0xFFA19DA6);
  static const dividerDark = Color(0xFF2C2A2F);
  static const roseSoftDark = Color(0xFF3A2329);
}
