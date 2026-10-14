import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_map.dart';
import '../data/models.dart';

/// 경로 지도에 올리는 레이어: 흰 테두리 경로선 + 출발/도착 + 가게 번호 핀.
/// S2 미리보기와 전체 화면 지도가 함께 쓴다.
List<Widget> routeLayers(
  BuildContext context, {
  required RouteQuery query,
  required List<StoreOnRoute> stores,
  ValueChanged<StoreOnRoute>? onStoreTap,
}) {
  final scheme = Theme.of(context).colorScheme;
  return [
    PolylineLayer(polylines: [routePolyline(query.route, scheme.primary)]),
    MarkerLayer(
      markers: [
        for (final (i, s) in stores.indexed)
          Marker(
            point: s.point,
            width: 32,
            height: 32,
            child: GestureDetector(
              onTap: onStoreTap == null ? null : () => onStoreTap(s),
              child: Semantics(
                label: '${i + 1}번 ${s.store.name}',
                button: onStoreTap != null,
                child: MapPin(label: '${i + 1}'),
              ),
            ),
          ),
        // 출발·도착은 가게 핀보다 위에 보이도록 마지막에 그린다.
        Marker(
          point: query.origin.point,
          width: MapLabelPin.width,
          height: MapLabelPin.height,
          child: MapLabelPin(label: '출발', color: scheme.primary),
        ),
        Marker(
          point: query.destination.point,
          width: MapLabelPin.width,
          height: MapLabelPin.height,
          child: const MapLabelPin(label: '도착', color: Color(0xFF2B2226)),
        ),
      ],
    ),
  ];
}

/// S2 경로 미리보기. 스크롤과 겹치지 않게 지도 조작은 막고, 누르면 전체 화면 지도를 연다.
class RoutePreviewMap extends StatelessWidget {
  const RoutePreviewMap({
    super.key,
    required this.query,
    required this.stores,
    required this.onOpenFullMap,
  });

  final RouteQuery query;
  final List<StoreOnRoute> stores;
  final VoidCallback onOpenFullMap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '지도 크게 보기',
      child: GestureDetector(
        onTap: onOpenFullMap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: SizedBox(
            height: 240,
            child: Stack(
              children: [
                AbsorbPointer(
                  child: AppMap(
                    interactive: false,
                    points: query.route.points,
                    padding: const EdgeInsets.fromLTRB(48, 48, 48, 32),
                    layers: routeLayers(context, query: query, stores: stores),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_full_rounded,
                          size: 14,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '크게 보기 · 길 안내',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
