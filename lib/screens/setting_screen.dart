import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notifSuhu = true;
  bool _notifHumid = true;
  bool _notifAsap = true;
  double _suhuThreshold = 35;
  double _humidThreshold = 80;

  @override
  Widget build(BuildContext context) {
    final bool isFirebaseLive = FirebaseService().isFirebaseLive;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Konfigurasi perangkat dan notifikasi',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            _sectionLabel('PERANGKAT & SERVER'),
            _buildSettingsGroup([
              _infoTile(Icons.memory_rounded, 'Device', 'ESP32 DevKit V1'),
              _divider(),
              _infoTile(Icons.sensors_rounded, 'Sensor', 'DHT22 + MQ-2'),
              _divider(),
              _infoTile(
                Icons.cloud_rounded,
                'Backend',
                isFirebaseLive ? 'Firebase Live ✓' : 'Demo Mode',
                valueColor: isFirebaseLive ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
              ),
              _divider(),
              _infoTile(
                Icons.sync_rounded,
                'Sinkronisasi',
                isFirebaseLive ? 'Real-time' : 'Simulasi',
              ),
            ]),
            
            const SizedBox(height: 24),
            _sectionLabel('THRESHOLD ALARM'),
            _buildSettingsGroup([
              _sliderTile(
                icon: Icons.thermostat_rounded,
                label: 'Batas Suhu',
                value: _suhuThreshold,
                min: 25,
                max: 50,
                unit: '°C',
                activeColor: const Color(0xFFEF4444),
                onChanged: (v) => setState(() => _suhuThreshold = v),
              ),
              _divider(),
              _sliderTile(
                icon: Icons.water_drop_rounded,
                label: 'Batas Kelembaban',
                value: _humidThreshold,
                min: 50,
                max: 100,
                unit: '%',
                activeColor: const Color(0xFF3B82F6),
                onChanged: (v) => setState(() => _humidThreshold = v),
              ),
            ]),
            
            const SizedBox(height: 24),
            _sectionLabel('NOTIFIKASI'),
            _buildSettingsGroup([
              _switchTile(Icons.thermostat_rounded, 'Alert Suhu', _notifSuhu,
                  (v) => setState(() => _notifSuhu = v)),
              _divider(),
              _switchTile(Icons.water_drop_rounded, 'Alert Kelembaban', _notifHumid,
                  (v) => setState(() => _notifHumid = v)),
              _divider(),
              _switchTile(Icons.local_fire_department_rounded, 'Alert Asap & Kebakaran', _notifAsap,
                  (v) => setState(() => _notifAsap = v)),
            ]),
            
            if (!isFirebaseLive) ...[
              const SizedBox(height: 24),
              _sectionLabel('PANDUAN KONEKSI'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B).withAlpha((0.25 * 255).toInt())),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF94A3B8).withAlpha((0.06 * 255).toInt()),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Langkah Koneksi Firebase',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._buildSteps([
                      'Buat proyek di console.firebase.google.com',
                      'Tambahkan app Android & unduh google-services.json',
                      'Letakkan google-services.json ke /android/app/',
                      'Nyalakan ESP32 untuk mengirim data real-time!',
                    ]),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            _sectionLabel('TENTANG'),
            _buildSettingsGroup([
              _infoTile(Icons.info_outline_rounded, 'Versi App', '1.0.0'),
              _divider(),
              _infoTile(Icons.group_rounded, 'Developer', 'Kelompok IoT'),
            ]),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSteps(List<String> steps) {
    return steps.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${entry.key + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                entry.value,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withAlpha((0.06 * 255).toInt()),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: const Color(0xFFF1F5F9),
      indent: 52,
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _infoTile(IconData icon, String label, String value, {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
            ),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    color: valueColor ?? const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _switchTile(IconData icon, String label, bool value, ValueChanged<bool> onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF3B82F6),
            ),
          ],
        ),
      );

  Widget _sliderTile({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: activeColor.withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${value.toInt()}$unit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: activeColor,
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                activeTrackColor: activeColor,
                inactiveTrackColor: const Color(0xFFF1F5F9),
                thumbColor: activeColor,
                overlayColor: activeColor.withAlpha((0.1 * 255).toInt()),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      );
}