import 'package:geolocator/geolocator.dart';

import 'geo.dart';

/// 화면에 그대로 보여줄 수 있는 한국어 메시지를 담은 위치 오류
class LocationFailure implements Exception {
  const LocationFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// 현재 위치(GPS)
abstract class LocationService {
  Future<LatLng> currentPosition();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<LatLng> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure('휴대폰의 위치 서비스를 켜 주세요.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure('위치 권한을 허용하면 현재 위치를 쓸 수 있어요.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure('설정 앱에서 위치 권한을 허용해 주세요.');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      // 실내 등에서 새 위치를 못 잡으면 마지막으로 알려진 위치라도 쓴다.
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return LatLng(last.latitude, last.longitude);
      throw const LocationFailure('현재 위치를 찾지 못했어요. 잠시 후 다시 시도해 주세요.');
    }
  }
}
