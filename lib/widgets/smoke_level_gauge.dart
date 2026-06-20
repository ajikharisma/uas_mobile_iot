import 'package:flutter/material.dart';
import 'dart:math' as math;

class SmokeLevelGauge extends StatelessWidget {
  final String smokeLevel;

  const SmokeLevelGauge({
    super.key,
    required this.smokeLevel,
  });

  Color _getStatusColor() {
    switch (smokeLevel) {
      case 'Rendah':
        return const Color(0xFF22C55E);
      case 'Normal':
        return const Color(0xFF06B6D4);
      case 'Sedang':
        return const Color(0xFFF59E0B);
      case 'Tinggi':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color _getBgStatusColor() {
    switch (smokeLevel) {
      case 'Rendah':
        return const Color(0xFFF0FDF4);
      case 'Normal':
        return const Color(0xFFECFDF5);
      case 'Sedang':
        return const Color(0xFFFFFBEB);
      case 'Tinggi':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  double _getPointerAngle() {
    switch (smokeLevel) {
      case 'Rendah':
        return math.pi + (math.pi / 8);
      case 'Normal':
        return math.pi + (3 * math.pi / 8);
      case 'Sedang':
        return math.pi + (5 * math.pi / 8);
      case 'Tinggi':
        return math.pi + (7 * math.pi / 8);
      default:
        return math.pi + (math.pi / 8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final bgStatusColor = _getBgStatusColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withAlpha((0.08 * 255).toInt()),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withAlpha((0.25 * 255).toInt()),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.cloud_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tingkat Asap',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Sensor MQ-2',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: bgStatusColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withAlpha((0.3 * 255).toInt()),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      smokeLevel == 'Tinggi' || smokeLevel == 'Sedang'
                          ? 'Waspada!'
                          : 'Aman',
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 240,
              height: 130,
              child: CustomPaint(
                painter: _SmokeGaugePainter(
                  needleAngle: _getPointerAngle(),
                  activeColor: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLevelIndicator('Rendah', const Color(0xFF22C55E), smokeLevel == 'Rendah'),
              const SizedBox(width: 8),
              _buildLevelIndicator('Normal', const Color(0xFF06B6D4), smokeLevel == 'Normal'),
              const SizedBox(width: 8),
              _buildLevelIndicator('Sedang', const Color(0xFFF59E0B), smokeLevel == 'Sedang'),
              const SizedBox(width: 8),
              _buildLevelIndicator('Tinggi', const Color(0xFFEF4444), smokeLevel == 'Tinggi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelIndicator(String label, Color color, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withAlpha((0.1 * 255).toInt()) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color.withAlpha((0.4 * 255).toInt()) : const Color(0xFFE2E8F0),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? color : color.withAlpha((0.3 * 255).toInt()),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? color : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmokeGaugePainter extends CustomPainter {
  final double needleAngle;
  final Color activeColor;

  _SmokeGaugePainter({
    required this.needleAngle,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 10;
    final radius = size.width / 2 - 10;
    final strokeWidth = 12.0;

    final Rect rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Background track
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFF1F5F9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Segment 1: Rendah (Green)
    canvas.drawArc(
      rect, math.pi, math.pi / 4, false,
      Paint()
        ..color = const Color(0xFF22C55E).withAlpha((0.3 * 255).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    // Segment 2: Normal (Cyan)
    canvas.drawArc(
      rect, math.pi + (math.pi / 4), math.pi / 4, false,
      Paint()
        ..color = const Color(0xFF06B6D4).withAlpha((0.3 * 255).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    // Segment 3: Sedang (Orange)
    canvas.drawArc(
      rect, math.pi + (math.pi / 2), math.pi / 4, false,
      Paint()
        ..color = const Color(0xFFF59E0B).withAlpha((0.3 * 255).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    // Segment 4: Tinggi (Red)
    canvas.drawArc(
      rect, math.pi + (3 * math.pi / 4), math.pi / 4, false,
      Paint()
        ..color = const Color(0xFFEF4444).withAlpha((0.3 * 255).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Active highlight
    final sweepAngle = (needleAngle - math.pi).clamp(0.0, math.pi);
    canvas.drawArc(
      rect, math.pi, sweepAngle, false,
      Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Needle center dot
    canvas.drawCircle(Offset(cx, cy), 7, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy), 7, Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);
    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = activeColor);

    // Needle line
    final needleLength = radius - 18;
    final targetX = cx + needleLength * math.cos(needleAngle);
    final targetY = cy + needleLength * math.sin(needleAngle);

    canvas.drawLine(
      Offset(cx, cy),
      Offset(targetX, targetY),
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
