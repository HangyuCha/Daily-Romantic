import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../core/location/geo.dart';
import '../../core/location/map_services.dart';
import '../../core/theme/app_spacing.dart';

/// OpenStreetMap 지도. [points]가 모두 보이도록 자동으로 확대·이동한다.
/// 지도 위에 그릴 선·마커는 [layers]로 넘긴다.
class AppMap extends StatelessWidget {
  const AppMap({
    super.key,
    required this.points,
    required this.layers,
    this.height = 220,
    this.maxZoom = 17,
  });

  final List<LatLng> points;
  final List<Widget> layers;
  final double height;
  final double maxZoom;

  @override
  Widget build(BuildContext context) {
    final services = MapScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        height: height,
        color: scheme.primaryContainer,
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: points.length == 1
                ? null
                : CameraFit.coordinates(
                    coordinates: points,
                    padding: const EdgeInsets.all(36),
                    maxZoom: maxZoom,
                  ),
            initialCenter: points.first,
            initialZoom: 16,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            if (services.showTiles)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.dailyromantic.daily_romantic',
              ),
            ...layers,
            // OpenStreetMap 이용 조건: 출처 표시 필수
            if (services.showTiles)
              const SimpleAttributionWidget(
                source: Text('OpenStreetMap contributors'),
              ),
          ],
        ),
      ),
    );
  }
}

/// 동그란 위치 점 (출발지·목적지·내 위치)
class MapDot extends StatelessWidget {
  const MapDot({super.key, required this.color, this.size = 16});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
    );
  }
}

/// 흰 바탕 원 안에 글자(번호·이모지)가 들어간 핀
class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.label, this.size = 30});

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
        border: Border.all(color: scheme.primary, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF2B2226),
        ),
      ),
    );
  }
}
