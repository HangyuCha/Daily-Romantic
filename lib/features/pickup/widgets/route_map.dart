import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../shared/widgets/app_map.dart';
import '../data/models.dart';

/// S2 경로 지도: 출발지(핑크 점) → 목적지(검정 점) 점선 도보 경로와 가게 번호 핀
class RouteMap extends StatelessWidget {
  const RouteMap({
    super.key,
    required this.query,
    required this.stores,
    this.onStoreTap,
  });

  final RouteQuery query;

  /// 목록 순서대로 1, 2, 3... 번호가 붙는다.
  final List<StoreOnRoute> stores;
  final ValueChanged<StoreOnRoute>? onStoreTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final route = query.route;

    return AppMap(
      points: route.points,
      layers: [
        PolylineLayer(
          polylines: [
            Polyline(
              points: route.points,
              color: scheme.primary,
              strokeWidth: 4,
              pattern: route.isEstimated
                  ? const StrokePattern.dotted()
                  : StrokePattern.dashed(segments: const [10, 7]),
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: query.origin.point,
              width: 18,
              height: 18,
              child: MapDot(color: scheme.primary),
            ),
            Marker(
              point: query.destination.point,
              width: 18,
              height: 18,
              child: const MapDot(color: Color(0xFF2B2226)),
            ),
            for (final (i, s) in stores.indexed)
              Marker(
                point: s.point,
                width: 30,
                height: 30,
                child: GestureDetector(
                  onTap: onStoreTap == null ? null : () => onStoreTap!(s),
                  child: Semantics(
                    label: '${i + 1}번 ${s.store.name}',
                    button: onStoreTap != null,
                    child: MapPin(label: '${i + 1}'),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
