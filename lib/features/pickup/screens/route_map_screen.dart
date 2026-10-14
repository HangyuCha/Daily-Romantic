import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/location/geo.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_map.dart';
import '../data/models.dart';
import '../widgets/route_map.dart';

/// 전체 화면 경로 지도 + 길 안내.
/// 가게 핀을 누르면 그 가게를 결과로 돌려주고 닫힌다.
class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key, required this.query, required this.stores});

  final RouteQuery query;
  final List<StoreOnRoute> stores;

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final _map = MapController();

  /// 아래 길 안내 시트가 가리는 만큼 지도 아래쪽 여백
  static const _sheetPadding = EdgeInsets.fromLTRB(56, 150, 76, 270);

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  void _zoomBy(double delta) {
    final camera = _map.camera;
    _map.move(camera.center, (camera.zoom + delta).clamp(11, 19));
  }

  void _showWholeRoute() => _map.fitCamera(
    CameraFit.coordinates(
      coordinates: widget.query.route.points,
      padding: _sheetPadding,
      maxZoom: 17,
    ),
  );

  void _focus(LatLng point) => _map.move(point, 18);

  @override
  Widget build(BuildContext context) {
    final query = widget.query;
    final route = query.route;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          AppMap(
            controller: _map,
            points: route.points,
            padding: _sheetPadding,
            layers: routeLayers(
              context,
              query: query,
              stores: widget.stores,
              onStoreTap: (s) => Navigator.of(context).pop(s),
            ),
          ),
          // 상단: 뒤로 + 경로 요약
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MapButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: '뒤로',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _SummaryCard(query: query)),
                ],
              ),
            ),
          ),
          // 오른쪽: 확대·축소·전체 보기
          Positioned(
            right: 12,
            top: MediaQuery.paddingOf(context).top + 130,
            child: Column(
              children: [
                MapButton(
                  icon: Icons.add_rounded,
                  tooltip: '확대',
                  onPressed: () => _zoomBy(1),
                ),
                const SizedBox(height: AppSpacing.sm),
                MapButton(
                  icon: Icons.remove_rounded,
                  tooltip: '축소',
                  onPressed: () => _zoomBy(-1),
                ),
                const SizedBox(height: AppSpacing.sm),
                MapButton(
                  icon: Icons.route_rounded,
                  tooltip: '경로 전체 보기',
                  onPressed: _showWholeRoute,
                ),
              ],
            ),
          ),
          // 아래: 길 안내 시트
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.12,
            maxChildSize: 0.75,
            snap: true,
            builder: (context, scroll) => DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 12),
                ],
              ),
              child: ListView(
                controller: scroll,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  10,
                  AppSpacing.screenPadding,
                  MediaQuery.paddingOf(context).bottom + AppSpacing.md,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('길 안내', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    '도보 ${route.durationMinutes}분 · '
                    '${formatDistance(route.distanceMeters)} · 단계를 누르면 지도가 이동해요',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (route.steps.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Text(
                        '길찾기 서버에 연결하지 못해 길 안내가 없어요.\n'
                        '지도의 직선은 대략적인 방향이에요.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  for (final (i, step) in route.steps.indexed)
                    _StepTile(
                      step: step,
                      isLast: i == route.steps.length - 1,
                      onTap: () => _focus(step.location),
                    ),
                  if (widget.stores.isNotEmpty) ...[
                    const Divider(height: AppSpacing.xl),
                    Text('경로 위 가게', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    for (final (i, s) in widget.stores.indexed)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: MapPin(label: '${i + 1}'),
                        title: Text(s.store.name),
                        subtitle: Text('도보 ${s.walkMinutes}분 · ${s.store.tag}'),
                        trailing: IconButton(
                          tooltip: '지도에서 보기',
                          onPressed: () => _focus(s.point),
                          icon: const Icon(Icons.my_location_rounded),
                        ),
                        onTap: () => Navigator.of(context).pop(s),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.query});

  final RouteQuery query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Widget row(Color color, String label, String name) => Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return Material(
      color: scheme.surface,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            row(scheme.primary, '출발', query.origin.name),
            const SizedBox(height: 6),
            row(const Color(0xFF2B2226), '도착', query.destination.name),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.isLast,
    required this.onTap,
  });

  final RouteStep step;
  final bool isLast;
  final VoidCallback onTap;

  static IconData _icon(StepKind kind) => switch (kind) {
    StepKind.depart => Icons.trip_origin_rounded,
    StepKind.arrive => Icons.flag_rounded,
    StepKind.left => Icons.turn_left_rounded,
    StepKind.right => Icons.turn_right_rounded,
    StepKind.slightLeft => Icons.turn_slight_left_rounded,
    StepKind.slightRight => Icons.turn_slight_right_rounded,
    StepKind.sharpLeft => Icons.turn_sharp_left_rounded,
    StepKind.sharpRight => Icons.turn_sharp_right_rounded,
    StepKind.uturn => Icons.u_turn_left_rounded,
    StepKind.straight => Icons.straight_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 단계 사이를 잇는 세로선
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: step.kind == StepKind.arrive
                          ? const Color(0xFF2B2226)
                          : scheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _icon(step.kind),
                      size: 18,
                      color: step.kind == StepKind.arrive
                          ? Colors.white
                          : scheme.primary,
                    ),
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2, color: scheme.outline)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Text(
                  step.instruction,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
