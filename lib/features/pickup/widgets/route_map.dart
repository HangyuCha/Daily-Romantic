import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../data/models.dart';

/// 출발지 → 목적지 점선 경로와 가게 번호 핀을 그리는 간이 지도 (S2).
/// 실제 지도 SDK를 붙이기 전까지 사용하는 그림이다.
class RouteMap extends StatelessWidget {
  const RouteMap({super.key, required this.stores});

  /// 목록 순서대로 1, 2, 3... 번호가 붙는다.
  final List<Store> stores;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        height: 140,
        color: scheme.primaryContainer,
        child: CustomPaint(
          size: Size.infinite,
          painter: _RoutePainter(
            positions: [for (final s in stores) s.routePosition],
            routeColor: scheme.primary,
            destinationColor: scheme.onSurface,
            pinFill: scheme.surface,
          ),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({
    required this.positions,
    required this.routeColor,
    required this.destinationColor,
    required this.pinFill,
  });

  final List<double> positions;
  final Color routeColor;
  final Color destinationColor;
  final Color pinFill;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final route = Path()
      ..moveTo(w * 0.06, h * 0.8)
      ..cubicTo(w * 0.26, h * 0.73, w * 0.35, h * 0.27, w * 0.56, h * 0.4)
      ..cubicTo(w * 0.75, h * 0.5, w * 0.85, h * 0.2, w * 0.94, h * 0.19);

    final metric = route.computeMetrics().first;

    // 점선 경로
    final dash = Paint()
      ..color = routeColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (double d = 0; d < metric.length; d += 11) {
      canvas.drawPath(metric.extractPath(d, d + 6), dash);
    }

    // 출발지(핑크) · 목적지(검정)
    final start = metric.getTangentForOffset(0)!.position;
    final end = metric.getTangentForOffset(metric.length)!.position;
    canvas.drawCircle(start, 7, Paint()..color = routeColor);
    canvas.drawCircle(end, 7, Paint()..color = destinationColor);

    // 가게 핀
    for (var i = 0; i < positions.length; i++) {
      final center = metric
          .getTangentForOffset(metric.length * positions[i].clamp(0.0, 1.0))!
          .position;
      canvas.drawCircle(center, 11, Paint()..color = pinFill);
      canvas.drawCircle(
        center,
        11,
        Paint()
          ..color = routeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final label = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: destinationColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, center - Offset(label.width / 2, label.height / 2));
    }
  }

  @override
  bool shouldRepaint(_RoutePainter old) =>
      old.positions != positions || old.routeColor != routeColor;
}
