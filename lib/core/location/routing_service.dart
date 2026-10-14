import 'dart:convert';

import 'package:http/http.dart' as http;

import 'geo.dart';

/// 도보 길찾기
abstract class RoutingService {
  /// 서버에 연결하지 못하면 직선 경로([WalkingRoute.isEstimated])를 돌려준다.
  Future<WalkingRoute> walkingRoute(LatLng from, LatLng to);
}

/// OSRM 도보 경로 (OpenStreetMap 독일 지부 공개 서버, 무료·키 없음).
/// 공개 서버라 느리거나 막힐 수 있다. 실서비스에서는 카카오·네이버 길찾기 API로 바꾼다.
class OsrmRoutingService implements RoutingService {
  OsrmRoutingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<WalkingRoute> walkingRoute(LatLng from, LatLng to) async {
    final coords =
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}';
    final uri = Uri.https(
      'routing.openstreetmap.de',
      '/routed-foot/route/v1/foot/$coords',
      {'overview': 'full', 'geometries': 'geojson'},
    );
    try {
      final res = await _client
          .get(
            uri,
            headers: {
              'User-Agent': 'DailyRomantic/1.0 (Flutter class project)',
            },
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || body['code'] != 'Ok') {
        return WalkingRoute.straight(from, to);
      }
      final route = (body['routes'] as List).first as Map<String, dynamic>;
      final coordinates =
          (route['geometry'] as Map<String, dynamic>)['coordinates'] as List;
      final points = [
        for (final c in coordinates.cast<List>())
          LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
      ];
      if (points.length < 2) return WalkingRoute.straight(from, to);
      final distance = (route['distance'] as num).toDouble();
      return WalkingRoute(
        points: points,
        distanceMeters: distance,
        // 서버 소요시간 대신 일정한 걷기 속도로 계산해 앱 안의 시간 표시를 맞춘다.
        durationSeconds: distance / WalkingRoute.walkingMetersPerMinute * 60,
      );
    } catch (_) {
      return WalkingRoute.straight(from, to);
    }
  }
}
