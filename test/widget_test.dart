import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_romantic/app.dart';
import 'package:daily_romantic/features/auth/data/auth_repository.dart';
import 'package:daily_romantic/features/auth/data/demo_auth_repository.dart';

void main() {
  // 주문 흐름 테스트는 로그인된 상태에서 시작한다.
  Widget signedInApp() => DailyRomanticApp(
    authRepository: DemoAuthRepository(
      signedInUser: const AppUser(id: 'test', nickname: '테스터'),
    ),
  );

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).first);
    await tester.tap(find.text(text).first);
    await tester.pumpAndSettle();
  }

  testWidgets('S1~S5 주문 흐름: 가게 찾기 → 담기 → 예약 → 주문 탭에 표시', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(signedInApp());

    // S1
    expect(find.text('어디로 가세요?'), findsOneWidget);
    await tapText(tester, '가는 길 가게 찾기');

    // S2: 우회 시간 짧은 순 정렬
    expect(find.text('경로 위 픽업 가능 가게'), findsOneWidget);
    expect(find.text('1. 편의점 큐레이션 GS'), findsOneWidget);
    await tapText(tester, '2. 모리 베이커리');

    // S3: 0개면 비활성화, 담으면 금액 표시
    expect(find.text('장바구니 비었어요'), findsOneWidget);
    await tester.tap(find.byTooltip('더하기').first);
    await tester.pump();
    expect(find.text('1개 담기 · 9,800원'), findsOneWidget);
    await tapText(tester, '1개 담기 · 9,800원');

    // S4
    expect(find.text('픽업 시간 선택'), findsOneWidget);
    await tapText(tester, '20분 후');
    await tester.tap(find.text('결제하고 픽업 예약'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // S5
    expect(find.text('픽업 준비 중이에요'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^[A-Z]-\d{4}$')), findsOneWidget);
    await tester.pumpAndSettle();
    await tapText(tester, '처음으로');
    expect(find.text('어디로 가세요?'), findsOneWidget);

    // 주문 탭
    await tapText(tester, '주문');
    expect(find.text('모리 베이커리'), findsOneWidget);
  });

  testWidgets('카테고리를 고르면 해당 가게만 보인다', (tester) async {
    await tester.pumpWidget(signedInApp());

    await tapText(tester, '🎂 레터링 케이크');
    await tapText(tester, '가는 길 가게 찾기');

    expect(find.text('1. 레터링 케이크 하루'), findsOneWidget);
    expect(find.textContaining('모리 베이커리'), findsNothing);
  });
}
