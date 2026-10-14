import 'dart:math';

import 'package:flutter/widgets.dart';

import 'models.dart';

/// 주문 내역·주문 상태·찜 목록. 지금은 앱 메모리에만 저장하고, 추후 Supabase로 옮긴다.
class PickupStore extends ChangeNotifier {
  PickupStore({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<PickupOrder> _orders = [];
  final Set<String> _favoriteStoreIds = {};

  /// 주문 코드별로 직접 바꾼 준비 단계 (가게 앱이 생기기 전 시연용)
  final Map<String, PickupStage> _manualStages = {};

  /// 주문 코드별 픽업 완료 시각
  final Map<String, DateTime> _completedAt = {};

  /// 최신 주문이 앞에 온다.
  List<PickupOrder> get orders => List.unmodifiable(_orders.reversed);

  /// 픽업 완료 전인 주문 (최신순)
  List<PickupOrder> activeOrders([DateTime? now]) {
    final t = now ?? DateTime.now();
    return orders.where((o) => !isCompleted(o) && o.isActiveAt(t)).toList();
  }

  /// 시간 흐름으로 추정한 단계와 직접 바꾼 단계 중 더 앞선 단계
  PickupStage stageOf(PickupOrder order, [DateTime? now]) {
    final byTime = order.stageAt(now ?? DateTime.now());
    final manual = _manualStages[order.code];
    if (manual == null || manual.index < byTime.index) return byTime;
    return manual;
  }

  bool isCompleted(PickupOrder order) => _completedAt.containsKey(order.code);

  DateTime? completedAt(PickupOrder order) => _completedAt[order.code];

  /// 가게 쪽 상태를 한 단계 넘긴다 (시연용). 이미 픽업 가능이면 그대로.
  void advanceStage(PickupOrder order) {
    final current = stageOf(order);
    if (current == PickupStage.ready) return;
    _manualStages[order.code] = PickupStage.values[current.index + 1];
    notifyListeners();
  }

  /// 손님이 픽업을 마쳤다.
  void completeOrder(PickupOrder order) {
    _completedAt[order.code] = DateTime.now();
    _manualStages[order.code] = PickupStage.ready;
    notifyListeners();
  }

  /// 로그아웃·계정 변경 시 다른 사람의 주문이 보이지 않도록 비운다.
  void reset() {
    _orders.clear();
    _favoriteStoreIds.clear();
    _manualStages.clear();
    _completedAt.clear();
    notifyListeners();
  }

  bool isFavorite(Store store) => _favoriteStoreIds.contains(store.id);

  Set<String> get favoriteStoreIds => Set.unmodifiable(_favoriteStoreIds);

  void toggleFavorite(Store store) {
    if (!_favoriteStoreIds.remove(store.id)) _favoriteStoreIds.add(store.id);
    notifyListeners();
  }

  PickupOrder placeOrder(
    Cart cart, {
    required int pickupInMinutes,
    required PaymentMethod paymentMethod,
  }) {
    final now = DateTime.now();
    final order = PickupOrder(
      code: _newCode(),
      store: cart.store,
      items: Map.unmodifiable(cart.quantities),
      message: cart.message,
      total: cart.total,
      itemCount: cart.itemCount,
      createdAt: now,
      pickupAt: now.add(Duration(minutes: pickupInMinutes)),
      paymentMethod: paymentMethod,
      storePoint: cart.storePoint,
    );
    _orders.add(order);
    notifyListeners();
    return order;
  }

  /// 예: A-2741
  String _newCode() {
    final letter = String.fromCharCode(65 + _random.nextInt(26));
    final number = (1000 + _random.nextInt(9000)).toString();
    return '$letter-$number';
  }
}

/// 위젯 트리 어디서든 PickupScope.of(context)로 꺼내 쓴다.
class PickupScope extends InheritedNotifier<PickupStore> {
  const PickupScope({
    super.key,
    required PickupStore store,
    required super.child,
  }) : super(notifier: store);

  static PickupStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PickupScope>()!.notifier!;
}
