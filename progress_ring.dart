import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A soft, animated circular progress ring. Used for both the home
/// screen's "day completion" indicator and the result screen's score.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress, // 0.0 - 1.0
    required this.centerLabel,
    this.centerSubLabel,
    this.size = 160,
    this.strokeWidth = 14,
    this.ringColor = AppColors.rosePink,
  });

  final double progress;
  final String centerLabel;
  final String? centerSubLabel;
  final double size;
  final double strokeWidth;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  progress: value,
                  strokeWidth: strokeWidth,
                  trackColor: AppColors.softBlush,
                  ringColor: ringColor,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerLabel,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkText,
                        ),
                  ),
                  if (centerSubLabel != null)
                    Text(
                      centerSubLabel!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                          ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.ringColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color ringColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final ringPaint = Paint()
      ..shader = SweepGradient(
        colors: [ringColor.withValues(alpha: 0.6), ringColor],
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweep = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.ringColor != ringColor;
}
