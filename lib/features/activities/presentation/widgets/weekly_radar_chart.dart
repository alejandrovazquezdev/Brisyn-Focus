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
        child: Center(
          child: Text(
            'No activities yet',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
      );
    }

    final categories = progressData.values.toList();
    final count = categories.length;
    
    // For single category, show a different view
    if (count == 1) {
      return _SingleCategoryView(
        progress: categories.first,
        size: size,
        isDark: isDark,
      );
    }
    
    // Ensure minimum 3 points for a proper radar chart
    final effectiveCount = count < 3 ? 3 : count;
    final angleStep = (2 * math.pi) / effectiveCount;
    final radius = size / 2 - 55; // Leave space for labels
    final labelRadius = radius + 40;

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
          clipBehavior: Clip.none,
          children: List.generate(count, (index) {
            final progress = categories[index];
            final angle = -math.pi / 2 + (index * angleStep);

            final x = size / 2 + labelRadius * math.cos(angle);
            final y = size / 2 + labelRadius * math.sin(angle);

            return Positioned(
              left: x - 32,
              top: y - 28,
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

/// Special view for when there's only 1 category
class _SingleCategoryView extends StatelessWidget {
  final WeeklyProgress progress;
  final double size;
  final bool isDark;

  const _SingleCategoryView({
    required this.progress,
    required this.size,
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
    final theme = Theme.of(context);
    final color = Color(progress.category.colorValue);
    final statusColor = _getStatusColor();
    final percentage = (progress.percentage * 100).round();

    return SizedBox(
      width: size,
      height: size * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size * 0.5,
                height: size * 0.5,
                child: CircularProgressIndicator(
                  value: progress.percentage.clamp(0.0, 1.0),
                  strokeWidth: 12,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SvgPicture.asset(
                      getIconAsset(progress.category.icon),
                      width: 32,
                      height: 32,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Category name and progress
          Text(
            progress.category.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${progress.completedDays}/${progress.goalDays} days this week',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
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
