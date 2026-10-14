import 'package:daily_romantic/core/location/geo.dart';
import 'package:daily_romantic/core/location/location_service.dart';
import 'package:daily_romantic/core/location/map_services.dart';
import 'package:daily_romantic/core/location/place_search_service.dart';
import 'package:daily_romantic/core/location/routing_service.dart';

const hongdae = LatLng(37.5572, 126.9245);
const sinchon = LatLng(37.5598, 126.9424);

/// 네트워크·GPS 없이 도는 가짜 지도 서비스
MapServices fakeMapServices({
  LocationService? location,
  Map<String, List<Place>>? places,
}) => MapServices(
  location: location ?? FakeLocationService(),
  places: FakePlaceSearchService(
    places ??
        {
          '신촌역': [const Place(name: '신촌역', point: sinchon)],
        },
  ),
  routing: FakeRoutingService(),
  showTiles: false,
);

class FakeLocationService implements LocationService {
  FakeLocationService({this.failure});

  final LocationFailure? failure;

  @override
  Future<LatLng> currentPosition() async {
    if (failure != null) throw failure!;
    return hongdae;
  }
}

class FakePlaceSearchService implements PlaceSearchService {
  FakePlaceSearchService(this.results);

  final Map<String, List<Place>> results;

  @override
  Future<List<Place>> search(String query, {LatLng? near}) async =>
      results[query] ?? const [];

  @override
  Future<String?> nameOf(LatLng point) async => '서교동 양화로';
}

class FakeRoutingService implements RoutingService {
  @override
  Future<WalkingRoute> walkingRoute(LatLng from, LatLng to) async =>
      WalkingRoute(
        points: [from, LatLng(from.latitude, to.longitude), to],
        distanceMeters: 1608, // 67m/분 기준 24분
        durationSeconds: 24 * 60,
        steps: [
          RouteStep(
            kind: StepKind.depart,
            roadName: '양화로',
            distanceMeters: 1300,
            location: from,
          ),
          RouteStep(
            kind: StepKind.left,
            roadName: '신촌로9길',
            distanceMeters: 308,
            location: LatLng(from.latitude, to.longitude),
          ),
          RouteStep(
            kind: StepKind.arrive,
            roadName: '',
            distanceMeters: 0,
            location: to,
          ),
        ],
      );
}
