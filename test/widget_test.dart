import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_romantic/app.dart';

void main() {
  testWidgets('앱이 실행되고 하단 탭으로 이동할 수 있다', (tester) async {
    await tester.pumpWidget(const DailyRomanticApp());

    expect(find.text('오늘도 설레는 하루'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('캘린더'));
    await tester.pumpAndSettle();
    expect(find.text('준비 중인 화면이에요'), findsOneWidget);
  });
}
