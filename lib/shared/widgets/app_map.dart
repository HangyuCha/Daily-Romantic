import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../core/location/geo.dart';
import '../../core/location/map_services.dart';

/// OpenStreetMap 지도. [points]가 모두 보이도록 자동으로 확대·이동한다.
/// 경로·핀이 잘 보이도록 배경 지도는 흐린 회색으로 낮춰서 그린다.
class AppMap extends StatelessWidget {
  const AppMap({
    super.key,
    required this.points,
    required this.layers,
    this.controller,
    this.interactive = true,
    this.padding = const EdgeInsets.all(40),
    this.maxZoom = 17,
    this.overlays = const [],
  });

  final List<LatLng> points;

  /// 지도 위에 그릴 선·마커 레이어
  final List<Widget> layers;

  /// 지도 위에 고정으로 띄울 버튼 등 (지도와 함께 움직이지 않음)
  final List<Widget> overlays;
  final MapController? controller;

  /// false면 손가락으로 움직일 수 없는 미리보기 지도
  final bool interactive;
  final EdgeInsets padding;
  final double maxZoom;

  @override
  Widget build(BuildContext context) {
    final services = MapScope.of(context);
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCameraFit: points.length < 2
            ? null
            : CameraFit.coordinates(
                coordinates: points,
                padding: padding,
                maxZoom: maxZoom,
              ),
        initialCenter: points.first,
        initialZoom: 16,
        minZoom: 11,
        maxZoom: 19,
        backgroundColor: const Color(0xFFF2EFEC),
        interactionOptions: InteractionOptions(
          flags: interactive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.none,
        ),
      ),
      children: [
        if (services.showTiles)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.dailyromantic.daily_romantic',
            tileBuilder: (context, tile, _) =>
                ColorFiltered(colorFilter: _fadedMap, child: tile),
          ),
        ...layers,
        ...overlays,
        // OpenStreetMap 이용 조건: 출처 표시 (ⓘ 버튼을 누르면 펼쳐짐)
        if (services.showTiles)
          const RichAttributionWidget(
            showFlutterMapAttribution: false,
            attributions: [TextSourceAttribution('OpenStreetMap contributors')],
          ),
      ],
    );
  }

  /// 채도를 거의 빼고(15%만 남김) 밝게 만들어 배경을 흐리게 한다.
  static final _fadedMap = () {
    const s = 0.15; // 남길 채도
    const a = 0.72; // 원래 색 비율 (나머지는 흰색으로 섞음)
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    List<double> row(double r, double g, double b) => [
      a * r,
      a * g,
      a * b,
      0,
      (1 - a) * 255,
    ];
    return ColorFilter.matrix([
      ...row(lr * (1 - s) + s, lg * (1 - s), lb * (1 - s)),
      ...row(lr * (1 - s), lg * (1 - s) + s, lb * (1 - s)),
      ...row(lr * (1 - s), lg * (1 - s), lb * (1 - s) + s),
      0,
      0,
      0,
      1,
      0,
    ]);
  }();
}

/// 경로 선: 흰 테두리를 두른 굵은 선 (내비게이션 앱 스타일)
Polyline routePolyline(WalkingRoute route, Color color) => Polyline(
  points: route.points,
  color: color,
  strokeWidth: 6,
  borderColor: Colors.white,
  borderStrokeWidth: 3,
  pattern: route.isEstimated
      ? StrokePattern.dashed(segments: const [8, 8])
      : const StrokePattern.solid(),
);

/// '출발'·'도착' 같은 글자가 들어간 말풍선 핀
class MapLabelPin extends StatelessWidget {
  const MapLabelPin({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  /// Marker 크기
  static const width = 52.0;
  static const height = 30.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// 흰 바탕 원 안에 글자(번호·이모지)가 들어간 핀
class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.label, this.size = 28});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: scheme.primary, width: 2.5),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF2B2226),
        ),
      ),
    );
  }
}

/// 지도 위 둥근 사각 버튼 (확대·축소·전체 보기)
class MapButton extends StatelessWidget {
  const MapButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: scheme.onSurface),
      ),
    );
  }
}
