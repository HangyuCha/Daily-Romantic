import 'dart:math';

import 'package:flutter/widgets.dart';

import 'models.dart';

/// 주문 내역과 찜 목록. 지금은 앱 메모리에만 저장하고, 추후 Supabase로 옮긴다.
class PickupStore extends ChangeNotifier {
  PickupStore({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<PickupOrder> _orders = [];
  final Set<String> _favoriteStoreIds = {};

  /// 최신 주문이 앞에 온다.
  List<PickupOrder> get orders => List.unmodifiable(_orders.reversed);

  /// 아직 픽업 전이거나 막 픽업 시각이 지난 주문 (최신순)
  List<PickupOrder> activeOrders([DateTime? now]) {
    final t = now ?? DateTime.now();
    return orders.where((o) => o.isActiveAt(t)).toList();
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
