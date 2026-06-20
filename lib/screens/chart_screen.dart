import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late Stream<List<SensorData>> _historyStream;

  @override
  void initState() {
    super.initState();
    _historyStream = FirebaseService().getHistoryStream(limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<SensorData>>(
        stream: _historyStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF3B82F6),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat riwayat...',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final history = snapshot.data ?? [];
          final tempPoints = history.map((d) => d.temperature).toList();
          final humidPoints = history.map((d) => d.humidity).toList();
          final gasPoints = history.map((d) => d.gasValue.toDouble()).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Grafik Riwayat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  history.isEmpty
                      ? 'Belum ada data riwayat'
                      : '${history.length} data terakhir dari sensor',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                if (history.isEmpty)
                  _buildEmptyState()
                else ...[
                  _ChartCard(
                    title: 'Suhu',
                    sensorInfo: 'DHT22',
                    icon: Icons.thermostat_rounded,
                    gradientColors: const [Color(0xFFEF4444), Color(0xFFF97316)],
                    color: const Color(0xFFEF4444),
                    points: tempPoints,
                    unit: '°C',
                  ),
                  const SizedBox(height: 12),
                  _ChartCard(
                    title: 'Kelembaban',
                    sensorInfo: 'DHT22',
                    icon: Icons.water_drop_rounded,
                    gradientColors: const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                    color: const Color(0xFF3B82F6),
                    points: humidPoints,
                    unit: '%',
                  ),
                  const SizedBox(height: 12),
                  _ChartCard(
                    title: 'Gas Value',
                    sensorInfo: 'MQ-2',
                    icon: Icons.cloud_rounded,
                    gradientColors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    color: const Color(0xFFF59E0B),
                    points: gasPoints,
                    unit: '',
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
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
        children: [
          Icon(Icons.show_chart_rounded, size: 48, color: const Color(0xFF94A3B8).withAlpha((0.4 * 255).toInt())),
          const SizedBox(height: 12),
          const Text(
            'Belum ada data riwayat',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Data akan muncul setelah sensor mengirim data',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String sensorInfo;
  final IconData icon;
  final List<Color> gradientColors;
  final Color color;
  final List<double> points;
  final String unit;

  const _ChartCard({
    required this.title,
    required this.sensorInfo,
    required this.icon,
    required this.gradientColors,
    required this.color,
    required this.points,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final latest = points.last;

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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Sensor $sensorInfo',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                latest % 1 == 0
                    ? '${latest.toInt()}$unit'
                    : '${latest.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: CustomPaint(
              painter: _LinePainter(points: points, color: color),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMinMaxChip('Min', minVal, unit),
              _buildMinMaxChip('Avg', points.reduce((a, b) => a + b) / points.length, unit),
              _buildMinMaxChip('Max', maxVal, unit),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinMaxChip(String label, double value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)}$unit',
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _LinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal).clamp(1.0, double.infinity);

    double x(int i) => i * size.width / (points.length - 1);
    double y(double v) => size.height - ((v - minVal) / range) * size.height * 0.8 - size.height * 0.1;

    // Draw smooth curve using cubic bezier
    final path = Path();
    final fillPath = Path();

    fillPath.moveTo(x(0), size.height);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(x(i), y(points[i]));
        fillPath.lineTo(x(i), y(points[i]));
      } else {
        final prevX = x(i - 1);
        final prevY = y(points[i - 1]);
        final curX = x(i);
        final curY = y(points[i]);
        final midX = (prevX + curX) / 2;

        path.cubicTo(midX, prevY, midX, curY, curX, curY);
        fillPath.cubicTo(midX, prevY, midX, curY, curX, curY);
      }
    }
    fillPath.lineTo(x(points.length - 1), size.height);
    fillPath.close();

    // Gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withAlpha((0.15 * 255).toInt()),
        color.withAlpha((0.02 * 255).toInt()),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Latest point glow
    final lastI = points.length - 1;
    canvas.drawCircle(
      Offset(x(lastI), y(points[lastI])),
      6,
      Paint()..color = color.withAlpha((0.2 * 255).toInt()),
    );
    canvas.drawCircle(
      Offset(x(lastI), y(points[lastI])),
      4,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(x(lastI), y(points[lastI])),
      3,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}