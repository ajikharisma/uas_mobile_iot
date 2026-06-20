import 'package:flutter/material.dart';
import 'chart_screen.dart';
import 'alert_screen.dart';
import '../widgets/sensor_card.dart';
import '../widgets/smoke_level_gauge.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeBody(),
          ChartScreen(),
          AlertScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF94A3B8).withAlpha((0.12 * 255).toInt()),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(1, Icons.insights_rounded, Icons.insights_outlined, 'Grafik'),
                _buildNavItem(2, Icons.notifications_rounded, Icons.notifications_outlined, 'Alert'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3B82F6).withAlpha((0.1 * 255).toInt()) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  late Stream<SensorData> _sensorStream;

  @override
  void initState() {
    super.initState();
    _sensorStream = FirebaseService().getSensorDataStream();
  }

  Widget _buildHeroCard(SensorData data) {
    final bool isLive = FirebaseService().isFirebaseLive;
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 6) {
      greeting = 'Selamat Malam';
    } else if (hour < 11) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    final List<String> dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dateStr = '${dayNames[now.weekday - 1]}, ${now.day} ${monthNames[now.month - 1]} ${now.year}';

    // Status info
    Color accentColor;
    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;
    List<Color> gradientColors;

    switch (data.status) {
      case 'Asap Terdeteksi':
        accentColor = const Color(0xFFF59E0B);
        statusIcon = Icons.warning_amber_rounded;
        statusTitle = 'Asap Terdeteksi';
        statusSubtitle = 'Waspada, terdeteksi kenaikan kadar asap!';
        gradientColors = [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
        break;
      case 'Potensi Kebakaran':
        accentColor = const Color(0xFFEF4444);
        statusIcon = Icons.campaign_rounded;
        statusTitle = 'Potensi Kebakaran!';
        statusSubtitle = 'BAHAYA! Segera periksa ruangan Anda!';
        gradientColors = [const Color(0xFFEF4444), const Color(0xFFF87171)];
        break;
      case 'Aman':
      default:
        accentColor = const Color(0xFF22C55E);
        statusIcon = Icons.verified_rounded;
        statusTitle = 'Sistem Aman';
        statusSubtitle = 'Kondisi lingkungan ruangan terpantau kondusif.';
        gradientColors = [const Color(0xFF22C55E), const Color(0xFF4ADE80)];
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withAlpha((0.1 * 255).toInt()),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top: Greeting + Date + Live badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isLive
                        ? const Color(0xFF22C55E).withAlpha((0.1 * 255).toInt())
                        : const Color(0xFFF59E0B).withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLive
                          ? const Color(0xFF22C55E).withAlpha((0.3 * 255).toInt())
                          : const Color(0xFFF59E0B).withAlpha((0.3 * 255).toInt()),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isLive ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isLive ? 'Live' : 'Demo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isLive ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Divider(height: 1, color: const Color(0xFFF1F5F9)),
          // Bottom: Status
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentColor.withAlpha((0.04 * 255).toInt()),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withAlpha((0.25 * 255).toInt()),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(statusIcon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusSubtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorData>(
      stream: _sensorStream,
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
                  'Memuat data sensor...',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Color(0xFFEF4444)),
            ),
          );
        }

        final data = snapshot.data ?? SensorData.initial();

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeroCard(data),
                const SizedBox(height: 24),
                _buildSectionTitle('PEMBACAAN SENSOR'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SensorCard(
                        icon: Icons.thermostat_rounded,
                        iconGradient: const [Color(0xFFEF4444), Color(0xFFF97316)],
                        label: 'Suhu',
                        sensorName: 'DHT22',
                        value: data.temperature.toString(),
                        unit: '°C',
                        subtitle: data.temperature > 35.0 ? 'Suhu Tinggi!' : 'Normal',
                        subtitleColor: data.temperature > 35.0
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF22C55E),
                        progress: (data.temperature / 50).clamp(0.0, 1.0),
                        progressColor: data.temperature > 35.0
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 12),
                      SensorCard(
                        icon: Icons.water_drop_rounded,
                        iconGradient: const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                        label: 'Kelembaban',
                        sensorName: 'DHT22',
                        value: data.humidity.toString(),
                        unit: '%',
                        subtitle: data.humidity > 80.0 ? 'Lembab Tinggi' : 'Normal',
                        subtitleColor: data.humidity > 80.0
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF22C55E),
                        progress: (data.humidity / 100).clamp(0.0, 1.0),
                        progressColor: data.humidity > 80.0
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF06B6D4),
                      ),
                      const SizedBox(height: 12),
                      SmokeLevelGauge(smokeLevel: data.smokeLevel),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}