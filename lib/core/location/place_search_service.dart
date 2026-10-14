import 'dart:convert';

import 'package:http/http.dart' as http;

import 'geo.dart';

/// 장소 이름 ↔ 좌표 변환
abstract class PlaceSearchService {
  /// [query]로 장소를 찾는다. [near] 주변 결과를 우선한다.
  Future<List<Place>> search(String query, {LatLng? near});

  /// 좌표의 짧은 이름 (예: 서교동). 못 찾으면 null
  Future<String?> nameOf(LatLng point);
}

/// OpenStreetMap Nominatim (무료, 키 없음).
/// 이용 규칙: 초당 1회 이하, 앱을 알리는 User-Agent 필수, 자동완성 용도 금지.
/// https://operations.osmfoundation.org/policies/nominatim/
class NominatimPlaceSearchService implements PlaceSearchService {
  NominatimPlaceSearchService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _host = 'nominatim.openstreetmap.org';
  static const _headers = {
    'User-Agent': 'DailyRomantic/1.0 (Flutter class project)',
  };

  @override
  Future<List<Place>> search(String query, {LatLng? near}) async {
    final params = {
      'q': query,
      'format': 'jsonv2',
      'limit': '5',
      'countrycodes': 'kr',
      'accept-language': 'ko',
      // 현재 위치 주변(약 ±10km)을 우선 검색
      if (near != null)
        'viewbox':
            '${near.longitude - 0.1},${near.latitude + 0.1},'
            '${near.longitude + 0.1},${near.latitude - 0.1}',
    };
    final res = await _client
        .get(Uri.https(_host, '/search', params), headers: _headers)
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return [];

    final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    final places = [
      for (final item in list.cast<Map<String, dynamic>>())
        Place(
          name: (item['name'] as String?)?.isNotEmpty == true
              ? item['name'] as String
              : query,
          address: _shortAddress(item['display_name'] as String?),
          point: LatLng(
            double.parse(item['lat'] as String),
            double.parse(item['lon'] as String),
          ),
        ),
    ];
    // 버스 정류장·출구 등 같은 이름·같은 동네 결과는 하나만 남긴다.
    final seen = <String>{};
    return [
      for (final p in places)
        if (seen.add('${p.name}|${p.address}')) p,
    ];
  }

  @override
  Future<String?> nameOf(LatLng point) async {
    final params = {
      'lat': '${point.latitude}',
      'lon': '${point.longitude}',
      'format': 'jsonv2',
      'accept-language': 'ko',
      'zoom': '17',
    };
    final res = await _client
        .get(Uri.https(_host, '/reverse', params), headers: _headers)
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return null;

    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final address = body['address'] as Map<String, dynamic>?;
    // 동 이름 + 도로/건물 이름 정도로 짧게 만든다.
    final parts = [
      address?['quarter'] ?? address?['suburb'],
      body['name'],
    ].whereType<String>().where((s) => s.isNotEmpty).toSet();
    return parts.isEmpty ? null : parts.join(' ');
  }

  /// "신촌, 30, 신촌역로, 대현동, 신촌동, 서대문구, 서울특별시, 03765, 대한민국"
  /// → "서울특별시 서대문구 신촌동"
  static String? _shortAddress(String? displayName) {
    if (displayName == null) return null;
    final parts = displayName
        .split(', ')
        .where((p) => p != '대한민국' && !RegExp(r'^\d+$').hasMatch(p))
        .toList();
    if (parts.length <= 3) return parts.reversed.join(' ');
    return parts.reversed.take(3).join(' ');
  }
}
