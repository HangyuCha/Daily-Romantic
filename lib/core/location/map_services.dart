import 'package:flutter/widgets.dart';

import 'location_service.dart';
import 'place_search_service.dart';
import 'routing_service.dart';

/// 지도·위치 관련 서비스 묶음. 테스트에서는 가짜 구현으로 바꿔 끼운다.
class MapServices {
  const MapServices({
    required this.location,
    required this.places,
    required this.routing,
    this.showTiles = true,
  });

  factory MapServices.live() => MapServices(
    location: GeolocatorLocationService(),
    places: NominatimPlaceSearchService(),
    routing: OsrmRoutingService(),
  );

  final LocationService location;
  final PlaceSearchService places;
  final RoutingService routing;

  /// 지도 배경(타일)을 불러올지. 네트워크가 없는 테스트에서는 끈다.
  final bool showTiles;
}

/// 위젯 트리 어디서든 MapScope.of(context)로 꺼내 쓴다.
class MapScope extends InheritedWidget {
  const MapScope({super.key, required this.services, required super.child});

  final MapServices services;

  static MapServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MapScope>()!.services;

  @override
  bool updateShouldNotify(MapScope old) => old.services != services;
}
