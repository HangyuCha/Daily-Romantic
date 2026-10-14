import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:daily_romantic/core/location/geo.dart';
import 'package:daily_romantic/core/utils/formatters.dart';
import 'package:daily_romantic/features/pickup/data/mock_stores.dart';
import 'package:daily_romantic/features/pickup/data/models.dart';
import 'package:daily_romantic/features/pickup/data/pickup_store.dart';

import 'fakes.dart';

void main() {
  RouteQuery query(GiftCategory category) => RouteQuery(
    origin: const Place(name: 'A', point: hongdae),
    destination: const Place(name: 'B', point: sinchon),
    route: WalkingRoute.straight(hongdae, sinchon),
    recipient: Recipient.school,
    category: category,
  );

  test('전체 카테고리는 4곳을 우회 시간 오름차순으로 돌려준다', () {
    final stores = searchStores(query(GiftCategory.all));
    expect(stores.map((s) => s.detourMinutes), [2, 4, 7, 9]);
  });

  test('카테고리를 고르면 해당 가게만 남는다', () {
    final stores = searchStores(query(GiftCategory.candle));
    expect(stores.map((s) => s.name), ['소소한 캔들샵']);
  });

  test('장바구니 수량·합계 계산', () {
    final store = mockStores.firstWhere((s) => s.id == 'mori');
    final cart = Cart(store)
      ..setQuantity(store.menu[0], 1)
      ..setQuantity(store.menu[1], 1);
    expect(cart.itemCount, 2);
    expect(cart.total, 21800);

    cart.setQuantity(store.menu[0], 0);
    expect(cart.itemCount, 1);
    expect(cart.quantities.containsKey(store.menu[0]), isFalse);
  });

  test('주문하면 A-1234 형식 코드가 생기고 최신 주문이 앞에 온다', () {
    final pickup = PickupStore(random: Random(1));
    final store = mockStores.first;
    final first = pickup.placeOrder(
      Cart(store)..setQuantity(store.menu.first, 1),
      pickupInMinutes: 12,
      paymentMethod: PaymentMethod.kakaoPay,
    );
    final second = pickup.placeOrder(
      Cart(store)..setQuantity(store.menu.first, 2),
      pickupInMinutes: 20,
      paymentMethod: PaymentMethod.card,
    );

    expect(first.code, matches(RegExp(r'^[A-Z]-\d{4}$')));
    expect(pickup.orders, [second, first]);
  });

  test('찜 토글', () {
    final pickup = PickupStore();
    final store = mockStores.first;
    pickup.toggleFavorite(store);
    expect(pickup.isFavorite(store), isTrue);
    pickup.toggleFavorite(store);
    expect(pickup.isFavorite(store), isFalse);
  });

  test('금액 포맷', () {
    expect(formatWon(0), '0원');
    expect(formatWon(9800), '9,800원');
    expect(formatWon(1234567), '1,234,567원');
  });

  test('가게는 실제 경로 위 지점에 놓이고 도보 시간이 계산된다', () {
    final route = WalkingRoute(
      points: const [LatLng(37.55, 126.92), LatLng(37.55, 126.94)],
      distanceMeters: 670,
      durationSeconds: 600,
    );
    final mid = route.pointAt(0.5);
    expect(mid.latitude, closeTo(37.55, 1e-9));
    expect(mid.longitude, closeTo(126.93, 1e-6));
    expect(route.pointAt(0), route.points.first);
    expect(route.pointAt(1).longitude, closeTo(126.94, 1e-9));
    expect(route.minutesTo(0.5), 5); // 335m ÷ 67m/분

    final stores = storesOnRoute(
      RouteQuery(
        origin: const Place(name: 'A', point: hongdae),
        destination: const Place(name: 'B', point: sinchon),
        route: route,
        recipient: Recipient.school,
        category: GiftCategory.all,
      ),
    );
    final mori = stores.firstWhere((s) => s.store.id == 'mori');
    expect(mori.point.longitude, closeTo(126.92 + 0.02 * 0.3, 1e-6));
    // 201m ÷ 67m/분 ≈ 3분 (소수점 오차로 올림될 수 있음)
    expect(mori.walkMinutes, inInclusiveRange(3, 4));
  });
}
