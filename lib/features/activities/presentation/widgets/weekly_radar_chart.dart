import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/models/activity_category.dart';
import '../providers/activities_providers.dart';

/// Radar/Spider chart for weekly activity progress
class WeeklyRadarChart extends StatelessWidget {
  final Map<String, WeeklyProgress> progressData;
  final double size;

  const WeeklyRadarChart({
    super.key,
    required this.progressData,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (progressData.isEmpty) {
      return SizedBox(
        height: size,
        child: const Center(
          child: Text('No activities yet'),
        ),
      );
    }

    final categories = progressData.values.toList();
    final count = categories.length;
    final angleStep = (2 * math.pi) / count;
    final radius = size / 2 - 60; // Leave space for labels

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarChartPainter(
          categories: categories,
          isDark: isDark,
          accentColor: theme.colorScheme.primary,
        ),
        child: Stack(
          children: List.generate(count, (index) {
            final progress = categories[index];
            final angle = -math.pi / 2 + (index * angleStep);
            final labelRadius = radius + 45;

            final x = size / 2 + labelRadius * math.cos(angle);
            final y = size / 2 + labelRadius * math.sin(angle);

            return Positioned(
              left: x - 35,
              top: y - 25,
              child: _CategoryLabel(
                progress: progress,
                isDark: isDark,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  final WeeklyProgress progress;
  final bool isDark;

  const _CategoryLabel({
    required this.progress,
    required this.isDark,
  });

  Color _getStatusColor() {
    switch (progress.status) {
      case ProgressStatus.complete:
        return const Color(0xFF4ECDC4);
      case ProgressStatus.partial:
        return const Color(0xFFFFD93D);
      case ProgressStatus.behind:
        return const Color(0xFFFF6B6B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon with background
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Color(progress.category.colorValue).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(
              getIconAsset(progress.category.icon),
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                Color(progress.category.colorValue),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Score badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(progress.percentage * 100).round()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
              ),
            ),
          ],
        ),
        // Name
        Text(
          progress.category.name,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        // Progress
        Text(
          '${progress.completedDays}/${progress.goalDays}',
          style: TextStyle(
            fontSize: 9,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      ],
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<WeeklyProgress> categories;
  final bool isDark;
  final Color accentColor;

  _RadarChartPainter({
    required this.categories,
    required this.isDark,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 60;
    final count = categories.length;
    final angleStep = (2 * math.pi) / count;

    // Draw background circles
    _drawBackgroundCircles(canvas, center, radius);

    // Draw axis lines
    _drawAxisLines(canvas, center, radius, count, angleStep);

    // Draw data polygon
    _drawDataPolygon(canvas, center, radius, count, angleStep);

    // Draw data points
    _drawDataPoints(canvas, center, radius, count, angleStep);
  }

  void _drawBackgroundCircles(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw 4 concentric circles
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), paint);
    }
  }

  void _drawAxisLines(
    Canvas canvas,
    Offset center,
    double radius,
    int count,
    double angleStep,
  ) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < count; i++) {
      final angle = -math.pi / 2 + (i * angleStep);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  void _drawDataPolygon(
    Canvas canvas,
    Offset center,
    double radius,
    int count,
    double angleStep,
  ) {
    if (categories.isEmpty) return;

    final path = Path();
    final fillPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < count; i++) {
      final progress = categories[i];
      final value = progress.percentage.clamp(0.0, 1.0);
      final angle = -math.pi / 2 + (i * angleStep);
      final pointRadius = radius * value;

      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawDataPoints(
    Canvas canvas,
    Offset center,
    double radius,
    int count,
    double angleStep,
  ) {
    for (int i = 0; i < count; i++) {
      final progress = categories[i];
      final value = progress.percentage.clamp(0.0, 1.0);
      final angle = -math.pi / 2 + (i * angleStep);
      final pointRadius = radius * value;

      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);

      // Point color based on status
      Color pointColor;
      switch (progress.status) {
        case ProgressStatus.complete:
          pointColor = const Color(0xFF4ECDC4);
          break;
        case ProgressStatus.partial:
          pointColor = const Color(0xFFFFD93D);
          break;
        case ProgressStatus.behind:
          pointColor = const Color(0xFFFF6B6B);
          break;
      }

      final pointPaint = Paint()
        ..color = pointColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(_RadarChartPainter oldDelegate) {
    return oldDelegate.categories != categories || oldDelegate.isDark != isDark;
  }
}
