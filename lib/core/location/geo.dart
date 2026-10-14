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

/// 길 안내 한 단계 (예: 좌회전해서 신촌로9길 따라 180m)
class RouteStep {
  const RouteStep({
    required this.kind,
    required this.roadName,
    required this.distanceMeters,
    required this.location,
  });

  final StepKind kind;

  /// 이 단계에서 따라가는 길 이름. 이름 없는 골목이면 빈 문자열
  final String roadName;

  /// 이 단계에서 걷는 거리
  final double distanceMeters;

  /// 방향을 바꾸는 지점
  final LatLng location;

  String get instruction {
    final along = roadName.isEmpty ? '' : '$roadName 따라 ';
    return switch (kind) {
      StepKind.depart => '출발해서 $along${formatDistance(distanceMeters)} 이동',
      StepKind.arrive => '목적지 도착',
      StepKind.straight => '$along${formatDistance(distanceMeters)} 직진',
      _ => '${kind.label} 후 $along${formatDistance(distanceMeters)}',
    };
  }
}

enum StepKind {
  depart('출발'),
  straight('직진'),
  left('좌회전'),
  right('우회전'),
  slightLeft('왼쪽 방향'),
  slightRight('오른쪽 방향'),
  sharpLeft('왼쪽으로 크게 꺾기'),
  sharpRight('오른쪽으로 크게 꺾기'),
  uturn('유턴'),
  arrive('도착');

  const StepKind(this.label);
  final String label;

  /// OSRM의 maneuver type/modifier → 방향
  static StepKind fromOsrm(String type, String? modifier) {
    if (type == 'depart') return depart;
    if (type == 'arrive') return arrive;
    return switch (modifier) {
      'left' => left,
      'right' => right,
      'slight left' => slightLeft,
      'slight right' => slightRight,
      'sharp left' => sharpLeft,
      'sharp right' => sharpRight,
      'uturn' => uturn,
      _ => straight,
    };
  }
}

/// 350 → "350m", 1234 → "1.2km"
String formatDistance(double meters) => meters < 1000
    ? '${(meters / 10).round() * 10}m'
    : '${(meters / 1000).toStringAsFixed(1)}km';

/// 도보 경로
class WalkingRoute {
  WalkingRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.steps = const [],
    this.isEstimated = false,
  }) : assert(points.length >= 2);

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  /// 길 안내 (길찾기 서버에 연결하지 못했으면 비어 있음)
  final List<RouteStep> steps;

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
