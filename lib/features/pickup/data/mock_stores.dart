import 'models.dart';

/// 화면 정의서의 예시 가게 4곳. 실제 가게 데이터(Supabase)가 생기면 교체한다.
/// 모리 베이커리 외 가게의 메뉴는 화면 정의서에 없어 임시로 채운 값이다.
const mockStores = <Store>[
  Store(
    id: 'mori',
    name: '모리 베이커리',
    emoji: '🍪',
    category: GiftCategory.snack,
    tag: '다과·쿠키',
    walkMinutes: 3,
    detourMinutes: 4,
    prepMinutes: 8,
    routePosition: 0.3,
    menu: [
      MenuItem(id: 'mori-cookie', name: '수제 쿠키 6입', emoji: '🍪', price: 9800),
      MenuItem(id: 'mori-madeleine', name: '마들렌 세트', emoji: '🧁', price: 12000),
      MenuItem(id: 'mori-tea', name: '핸드드립 티백', emoji: '🍵', price: 6500),
    ],
  ),
  Store(
    id: 'haru',
    name: '레터링 케이크 하루',
    emoji: '🎂',
    category: GiftCategory.cake,
    tag: '레터링 케이크',
    walkMinutes: 6,
    detourMinutes: 7,
    prepMinutes: 15,
    routePosition: 0.52,
    menu: [
      MenuItem(id: 'haru-mini', name: '미니 레터링 케이크', emoji: '🎂', price: 18000),
      MenuItem(id: 'haru-lunchbox', name: '도시락 케이크', emoji: '🍰', price: 15000),
      MenuItem(id: 'haru-cupcake', name: '컵케이크 2입', emoji: '🧁', price: 8000),
    ],
  ),
  Store(
    id: 'soso',
    name: '소소한 캔들샵',
    emoji: '🕯️',
    category: GiftCategory.candle,
    tag: '양초·소품',
    walkMinutes: 8,
    detourMinutes: 9,
    prepMinutes: 5,
    routePosition: 0.78,
    menu: [
      MenuItem(id: 'soso-soy', name: '소이 캔들', emoji: '🕯️', price: 14000),
      MenuItem(id: 'soso-mini', name: '미니 캔들 3종', emoji: '✨', price: 9900),
      MenuItem(id: 'soso-card', name: '향기 카드', emoji: '💐', price: 7500),
    ],
  ),
  Store(
    id: 'gs',
    name: '편의점 큐레이션 GS',
    emoji: '🏪',
    category: GiftCategory.instant,
    tag: '즉석 선물',
    walkMinutes: 2,
    detourMinutes: 2,
    prepMinutes: 3,
    routePosition: 0.12,
    menu: [
      MenuItem(id: 'gs-choco', name: '초콜릿 기프트', emoji: '🍫', price: 5500),
      MenuItem(id: 'gs-flower', name: '꽃 한 송이', emoji: '🌷', price: 4900),
      MenuItem(id: 'gs-drink', name: '음료 세트', emoji: '🥤', price: 6000),
    ],
  ),
];

/// 카테고리로 거르고 우회 시간이 짧은 순으로 정렬한다.
/// '전체'면 모든 가게를 보여준다.
List<Store> searchStores(RouteQuery query) {
  final result = mockStores
      .where(
        (s) =>
            query.category == GiftCategory.all || s.category == query.category,
      )
      .toList();
  result.sort((a, b) => a.detourMinutes.compareTo(b.detourMinutes));
  return result;
}
