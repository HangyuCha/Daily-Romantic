import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_romantic/app.dart';
import 'package:daily_romantic/features/auth/auth_service.dart';
import 'package:daily_romantic/features/auth/login_screen.dart';

void main() {
  testWidgets('앱이 실행되고 하단 탭으로 이동할 수 있다', (tester) async {
    await tester.pumpWidget(const DailyRomanticApp());

    expect(find.text('오늘도 설레는 하루'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('캘린더'));
    await tester.pumpAndSettle();
    expect(find.text('준비 중인 화면이에요'), findsOneWidget);
  });

  testWidgets('로그인 버튼을 누르면 해당 provider로 로그인을 요청한다', (tester) async {
    SocialProvider? requested;
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(onSignIn: (p) async => requested = p)),
    );

    await tester.tap(find.text('네이버로 시작하기'));
    await tester.pump();
    expect(requested, SocialProvider.naver);

    await tester.tap(find.text('카카오로 시작하기'));
    await tester.pump();
    expect(requested, SocialProvider.kakao);
  });
}
