import 'package:latlong2/latlong.dart';

export 'package:latlong2/latlong.dart' show LatLng;

/// 이름이 붙은 위치 (출발지·목적지·가게)
class Place {
  const Place({required this.name, required this.point, this.address});

  final String name;
  final LatLng point;

  /// 검색 결과 목록에 함께 보여줄 주소
  final String? address;
}

/// 도보 경로
class WalkingRoute {
  WalkingRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.isEstimated = false,
  }) : assert(points.length >= 2);

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  /// 길찾기 서버에 연결하지 못해 직선으로 대신 그린 경로인지
  final bool isEstimated;

  static const _distance = Distance();

  /// 사람 걷는 속도 (분당 미터)
  static const walkingMetersPerMinute = 67.0;

  int get durationMinutes => (durationSeconds / 60).ceil();

  /// 경로를 따라 [fraction](0~1) 지점의 좌표
  LatLng pointAt(double fraction) {
    final target = _totalLength * fraction.clamp(0.0, 1.0);
    var walked = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final segment = _distance(points[i], points[i + 1]);
      if (walked + segment >= target && segment > 0) {
        final t = (target - walked) / segment;
        return LatLng(
          points[i].latitude +
              (points[i + 1].latitude - points[i].latitude) * t,
          points[i].longitude +
              (points[i + 1].longitude - points[i].longitude) * t,
        );
      }
      walked += segment;
    }
    return points.last;
  }

  /// 출발지에서 [fraction] 지점까지 걷는 시간(분)
  int minutesTo(double fraction) =>
      (distanceMeters * fraction.clamp(0.0, 1.0) / walkingMetersPerMinute)
          .ceil()
          .clamp(1, 999);

  late final double _totalLength = () {
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += _distance(points[i], points[i + 1]);
    }
    return total;
  }();

  /// 두 지점을 잇는 직선 경로 (길찾기 실패 시 대체용)
  factory WalkingRoute.straight(LatLng from, LatLng to) {
    final meters = _distance(from, to);
    return WalkingRoute(
      points: [from, to],
      distanceMeters: meters,
      durationSeconds: meters / walkingMetersPerMinute * 60,
      isEstimated: true,
    );
  }
}
