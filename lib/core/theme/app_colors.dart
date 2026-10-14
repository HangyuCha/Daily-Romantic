import 'package:flutter/material.dart';

/// 브랜드 컬러. 화면 정의서(프로토타입) 기준. 색을 바꾸고 싶으면 이 파일만 수정하면 된다.
class AppColors {
  AppColors._();

  // 포인트 컬러
  static const pink = Color(0xFFE8587A);
  static const pinkSoft = Color(0xFFFDE4EB);

  // 라이트 모드
  static const background = Color(0xFFFDF6F3);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF2B2226);
  static const textSecondary = Color(0xFF8A7A80);
  static const line = Color(0xFFF0E2E6);

  // 다크 모드
  static const backgroundDark = Color(0xFF1A1517);
  static const surfaceDark = Color(0xFF241D20);
  static const textPrimaryDark = Color(0xFFF5EEF0);
  static const textSecondaryDark = Color(0xFFA8989E);
  static const lineDark = Color(0xFF3A2E33);
  static const pinkSoftDark = Color(0xFF3D2229);

  // 소셜 로그인 브랜드 컬러 (각 사 가이드 기준)
  static const kakao = Color(0xFFFEE500);
  static const kakaoText = Color(0xD9000000);
  static const naver = Color(0xFF03C75A);
}
