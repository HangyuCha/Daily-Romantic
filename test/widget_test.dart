import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_romantic/app.dart';
import 'package:daily_romantic/features/auth/data/auth_repository.dart';
import 'package:daily_romantic/core/location/geo.dart';
import 'package:daily_romantic/core/location/location_service.dart';
import 'package:daily_romantic/core/location/map_services.dart';
import 'package:daily_romantic/features/auth/data/demo_auth_repository.dart';

import 'fakes.dart';

void main() {
  // 주문 흐름 테스트는 로그인된 상태에서 시작한다.
  Widget signedInApp({MapServices? mapServices}) => DailyRomanticApp(
    authRepository: DemoAuthRepository(
      signedInUser: const AppUser(id: 'test', nickname: '테스터'),
    ),
    mapServices: mapServices ?? fakeMapServices(),
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
    await tester.pumpAndSettle();

    // S1: GPS 현재 위치가 출발지로 채워진다
    expect(find.text('어디로 가세요?'), findsOneWidget);
    expect(find.text('서교동 양화로'), findsOneWidget);
    await tapText(tester, '가는 길 가게 찾기');

    // S2: 실제 경로 기준 도보 시간, 우회 시간 짧은 순 정렬
    expect(find.text('경로 위 픽업 가능 가게'), findsOneWidget);
    expect(find.textContaining('서교동 양화로 → 신촌역'), findsOneWidget);
    expect(find.textContaining('도보 24분'), findsOneWidget);
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
    await tapText(tester, '결제하고 픽업 예약');

    // 결제 (시연용): 동의 전에는 결제 버튼 비활성화
    expect(find.text('결제하기'), findsOneWidget);
    final payButton = find.widgetWithText(FilledButton, '9,800원 결제하기');
    expect(tester.widget<FilledButton>(payButton).onPressed, isNull);
    await tapText(tester, '네이버페이');
    await tapText(tester, '주문 내용을 확인했으며 결제에 동의합니다.');
    await tester.tap(payButton);
    await tester.pump();
    expect(find.text('네이버페이로 결제하는 중이에요'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));

    // S5
    expect(find.text('픽업 준비 중이에요'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^[A-Z]-\d{4}$')), findsOneWidget);
    expect(find.textContaining('네이버페이 결제 완료'), findsOneWidget);
    await tester.pumpAndSettle();
    await tapText(tester, '처음으로');
    expect(find.text('어디로 가세요?'), findsOneWidget);

    // 주문 탭
    await tapText(tester, '주문');
    expect(find.text('모리 베이커리'), findsOneWidget);
  });

  testWidgets('카테고리를 고르면 해당 가게만 보인다', (tester) async {
    await tester.pumpWidget(signedInApp());
    await tester.pumpAndSettle();

    await tapText(tester, '🎂 레터링 케이크');
    await tapText(tester, '가는 길 가게 찾기');

    expect(find.text('1. 레터링 케이크 하루'), findsOneWidget);
    expect(find.textContaining('모리 베이커리'), findsNothing);
  });

  testWidgets('GPS를 못 쓰면 안내하고, 출발지를 직접 입력해 검색할 수 있다', (tester) async {
    await tester.pumpWidget(
      signedInApp(
        mapServices: fakeMapServices(
          location: FakeLocationService(
            failure: const LocationFailure('위치 권한을 허용하면 현재 위치를 쓸 수 있어요.'),
          ),
          places: {
            '홍대입구역': [const Place(name: '홍대입구역', point: hongdae)],
            '신촌역': [const Place(name: '신촌역', point: sinchon)],
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('위치 권한을 허용하면 현재 위치를 쓸 수 있어요.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '홍대입구역');
    await tester.pump();
    await tapText(tester, '가는 길 가게 찾기');
    expect(find.textContaining('홍대입구역 → 신촌역'), findsOneWidget);
  });

  testWidgets('목적지 검색 결과가 여러 개면 고를 수 있다', (tester) async {
    await tester.pumpWidget(
      signedInApp(
        mapServices: fakeMapServices(
          places: {
            '신촌역': [
              const Place(name: '신촌역', point: sinchon, address: '서대문구'),
              const Place(
                name: '신촌역 (경의중앙선)',
                point: LatLng(37.5599, 126.9426),
                address: '서대문구 대현동',
              ),
            ],
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('가는 길 가게 찾기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text("'신촌역' 중 어디인가요?"), findsOneWidget);
    await tapText(tester, '신촌역 (경의중앙선)');
    expect(find.textContaining('→ 신촌역 (경의중앙선)'), findsOneWidget);
  });

  testWidgets('목적지를 못 찾으면 안내한다', (tester) async {
    await tester.pumpWidget(signedInApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), '없는장소');
    await tapText(tester, '가는 길 가게 찾기');
    expect(find.textContaining("'없는장소'을(를) 찾지 못했어요"), findsOneWidget);
    expect(find.text('어디로 가세요?'), findsOneWidget);
  });
}
