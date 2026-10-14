import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_romantic/app.dart';
import 'package:daily_romantic/features/auth/data/auth_repository.dart';
import 'package:daily_romantic/features/auth/data/demo_auth_repository.dart';
import 'package:daily_romantic/features/auth/widgets/auth_validators.dart';

import 'package:daily_romantic/features/pickup/data/mock_stores.dart';
import 'package:daily_romantic/features/pickup/data/models.dart';
import 'package:daily_romantic/features/pickup/data/pickup_store.dart';

import 'fakes.dart';

void main() {
  group('입력 검증', () {
    test('이메일', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('abc'), isNotNull);
      expect(AuthValidators.email('a@b.co'), isNull);
    });

    test('비밀번호는 영문·숫자 포함 8자 이상', () {
      expect(AuthValidators.newPassword('abc123'), isNotNull);
      expect(AuthValidators.newPassword('abcdefgh'), isNotNull);
      expect(AuthValidators.newPassword('12345678'), isNotNull);
      expect(AuthValidators.newPassword('abcd1234'), isNull);
    });

    test('닉네임은 2~12자', () {
      expect(AuthValidators.nickname('a'), isNotNull);
      expect(AuthValidators.nickname('데로'), isNull);
    });
  });

  group('데모 로그인', () {
    test('가입하면 바로 로그인되고, 같은 이메일로는 다시 가입할 수 없다', () async {
      final auth = DemoAuthRepository();
      final result = await auth.signUpWithEmail(
        email: 'me@test.com',
        password: 'abcd1234',
        nickname: '나',
      );
      expect(result, SignUpResult.signedIn);
      expect(auth.currentUser?.nickname, '나');

      await auth.signOut();
      expect(auth.currentUser, isNull);

      expect(
        () => auth.signUpWithEmail(
          email: 'ME@test.com',
          password: 'abcd1234',
          nickname: '나',
        ),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('비밀번호가 틀리면 로그인 실패', () async {
      final auth = DemoAuthRepository();
      await auth.signUpWithEmail(
        email: 'me@test.com',
        password: 'abcd1234',
        nickname: '나',
      );
      await auth.signOut();

      expect(
        () => auth.signInWithEmail(email: 'me@test.com', password: 'wrong123'),
        throwsA(isA<AuthFailure>()),
      );
      await auth.signInWithEmail(email: 'me@test.com', password: 'abcd1234');
      expect(auth.currentUser, isNotNull);
    });
  });

  testWidgets('회원가입 → 메인 진입 → 로그아웃 → 로그인', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      DailyRomanticApp(
        authRepository: DemoAuthRepository(),
        mapServices: fakeMapServices(),
      ),
    );
    expect(find.text('카카오로 시작하기'), findsOneWidget);

    // 회원가입
    await tester.tap(find.text('회원가입'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '로맨틱');
    await tester.enterText(fields.at(1), 'me@test.com');
    await tester.enterText(fields.at(2), 'abcd1234');
    await tester.enterText(fields.at(3), 'abcd1234');

    // 필수 약관에 동의하기 전에는 가입 버튼이 비활성화
    final signUpButton = find.widgetWithText(FilledButton, '가입하기');
    expect(tester.widget<FilledButton>(signUpButton).onPressed, isNull);
    await tester.tap(find.text('전체 동의'));
    await tester.pump();
    expect(tester.widget<FilledButton>(signUpButton).onPressed, isNotNull);

    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('어디로 가세요?'), findsOneWidget);

    // MY 탭에서 로그아웃
    await tester.tap(find.text('MY'));
    await tester.pumpAndSettle();
    expect(find.text('로맨틱님'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '로그아웃'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '로그아웃').last);
    await tester.pumpAndSettle();
    expect(find.text('카카오로 시작하기'), findsOneWidget);

    // 이메일 로그인 펼치기
    await tester.tap(find.text('이메일로 로그인'));
    await tester.pumpAndSettle();

    // 틀린 비밀번호 → 오류 안내
    final loginFields = find.byType(TextFormField);
    await tester.enterText(loginFields.at(0), 'me@test.com');
    await tester.enterText(loginFields.at(1), 'wrong123');
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();
    expect(find.text('이메일 또는 비밀번호가 맞지 않아요.'), findsOneWidget);

    // 올바른 비밀번호 → 메인
    await tester.enterText(loginFields.at(1), 'abcd1234');
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();
    expect(find.text('어디로 가세요?'), findsOneWidget);
  });

  testWidgets('카카오 버튼으로 로그인', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      DailyRomanticApp(
        authRepository: DemoAuthRepository(),
        mapServices: fakeMapServices(),
      ),
    );
    await tester.tap(find.text('카카오로 시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('어디로 가세요?'), findsOneWidget);
  });

  test('계정이 바뀌면 이전 주문이 지워진다', () async {
    // 앱 상태 클래스 대신 같은 규칙을 PickupStore + 인증 흐름으로 확인
    final auth = DemoAuthRepository(
      signedInUser: const AppUser(id: 'a', nickname: 'A'),
    );
    final pickup = PickupStore();
    String? userId = auth.currentUser?.id;
    final sub = auth.authStateChanges().listen((u) {
      if (u?.id == userId) return;
      userId = u?.id;
      pickup.reset();
    });
    pickup.placeOrder(
      Cart(mockStores.first)..setQuantity(mockStores.first.menu.first, 1),
      pickupInMinutes: 15,
      paymentMethod: PaymentMethod.card,
    );
    await auth.signOut();
    await Future<void>.delayed(Duration.zero);
    expect(pickup.orders, isEmpty);
    await sub.cancel();
  });
}
