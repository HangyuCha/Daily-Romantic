import '../../../core/location/geo.dart';

/// 받는 사람 유형 (S1). 추후 AI 추천의 관계 변수로 사용.
enum Recipient {
  school('🎓 학교 사람'),
  coworker('💼 회사 동료'),
  loved('💌 지인·연인');

  const Recipient(this.label);
  final String label;
}

/// 선물 카테고리 (S1 필터).
enum GiftCategory {
  all('전체'),
  snack('🍪 다과'),
  cake('🎂 레터링 케이크'),
  candle('🕯️ 양초·소품'),
  instant('🏪 즉석 선물');

  const GiftCategory(this.label);
  final String label;

  /// S1 칩에 노출하는 카테고리 (화면 정의서 기준)
  static const filterOptions = [all, snack, cake, candle];
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
  });

  final String id;
  final String name;
  final String emoji;
  final int price;
}

class Store {
  const Store({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.tag,
    required this.walkMinutes,
    required this.detourMinutes,
    required this.prepMinutes,
    required this.routePosition,
    required this.menu,
  });

  final String id;
  final String name;
  final String emoji;
  final GiftCategory category;

  /// 카드에 표시하는 태그 (예: 다과·쿠키)
  final String tag;
  final int walkMinutes;
  final int detourMinutes;

  /// 평균 준비 시간
  final int prepMinutes;

  /// 경로 위 위치 (0 = 출발지, 1 = 목적지).
  /// 실제 가게 데이터가 생기기 전까지 사용자의 실제 경로 위 이 지점에 가게를 놓는다.
  final double routePosition;
  final List<MenuItem> menu;
}

/// 경로 조건 (S1 → S2)
class RouteQuery {
  const RouteQuery({
    required this.origin,
    required this.destination,
    required this.route,
    required this.recipient,
    required this.category,
  });

  final Place origin;
  final Place destination;
  final WalkingRoute route;
  final Recipient recipient;
  final GiftCategory category;
}

/// 경로 위에 배치된 가게 (S2)
class StoreOnRoute {
  const StoreOnRoute({
    required this.store,
    required this.point,
    required this.walkMinutes,
  });

  final Store store;
  final LatLng point;

  /// 출발지에서 가게까지 걷는 시간
  final int walkMinutes;
}

/// 장바구니 (S3 → S4). 한 가게에서만 담을 수 있다.
class Cart {
  Cart(this.store, {this.storePoint, this.walkMinutes});

  final Store store;

  /// 지도에 표시할 가게 위치 (경로 검색을 거치지 않았으면 null)
  final LatLng? storePoint;

  /// 출발지에서 가게까지 걷는 시간 (모르면 null)
  final int? walkMinutes;
  final Map<MenuItem, int> quantities = {};
  String message = '';

  int quantityOf(MenuItem item) => quantities[item] ?? 0;

  void setQuantity(MenuItem item, int quantity) {
    if (quantity <= 0) {
      quantities.remove(item);
    } else {
      quantities[item] = quantity;
    }
  }

  int get itemCount => quantities.values.fold(0, (sum, q) => sum + q);

  int get total =>
      quantities.entries.fold(0, (sum, e) => sum + e.key.price * e.value);

  bool get isEmpty => itemCount == 0;
}

/// 결제 수단. 지금은 시연용 결제라 실제 결제는 일어나지 않는다.
enum PaymentMethod {
  kakaoPay('카카오페이', '💛'),
  naverPay('네이버페이', '💚'),
  tossPay('토스페이', '💙'),
  card('신용·체크카드', '💳');

  const PaymentMethod(this.label, this.emoji);
  final String label;
  final String emoji;
}

enum PickupStage {
  preparing('가게 준비'),
  packed('포장 완료'),
  ready('픽업 가능');

  const PickupStage(this.label);
  final String label;
}

/// 예약 완료된 주문 (S5, 주문 탭)
class PickupOrder {
  const PickupOrder({
    required this.code,
    required this.store,
    required this.items,
    required this.message,
    required this.total,
    required this.itemCount,
    required this.createdAt,
    required this.pickupAt,
    required this.paymentMethod,
    this.storePoint,
  });

  /// 픽업 코드. 형식: 알파벳 1자리 + 하이픈 + 숫자 4자리 (예: A-2741)
  final String code;
  final Store store;
  final Map<MenuItem, int> items;
  final String message;
  final int total;
  final int itemCount;
  final DateTime createdAt;
  final DateTime pickupAt;
  final PaymentMethod paymentMethod;
  final LatLng? storePoint;
}
