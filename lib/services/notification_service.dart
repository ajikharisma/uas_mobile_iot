import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_service.dart';

// Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🔔 [BG] FCM message: ${message.notification?.title}");
}

class NotificationData {
  final String title;
  final String message;
  final DateTime time;
  final String level; // 'danger', 'warning', 'info', 'success'

  NotificationData({
    required this.title,
    required this.message,
    required this.time,
    required this.level,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final List<NotificationData> _notifications = [];
  final _controller = StreamController<List<NotificationData>>.broadcast();
  StreamSubscription<SensorData>? _sensorSub;
  String _lastStatus = 'Aman';
  int _notifId = 0;
  String? _fcmToken;

  Stream<List<NotificationData>> get notificationStream => _controller.stream;
  List<NotificationData> get notifications => List.unmodifiable(_notifications);
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    // ─── Local Notifications Setup ───
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // Request notification permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // ─── FCM Setup ───
    await _setupFCM();

    debugPrint("🔔 NotificationService initialized");

    // Add initial notification
    _addNotification(
      title: 'Sistem Terhubung',
      message: 'Smart Room Monitor aktif dan memantau kondisi ruangan.',
      level: 'success',
    );

    // Start listening to sensor data for local trigger
    _startListening();
  }

  Future<void> _setupFCM() async {
    try {
      // Request permission
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint("🔔 FCM permission: ${settings.authorizationStatus}");

      // Get FCM token
      _fcmToken = await messaging.getToken();
      debugPrint("🔑 FCM Token: $_fcmToken");

      // Listen for token refresh
      messaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        debugPrint("🔑 FCM Token refreshed: $token");
      });

      // Background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Foreground FCM messages → show as local notification + add to history
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("🔔 [FG] FCM: ${message.notification?.title}");
        final title = message.notification?.title ?? 'Notifikasi';
        final body = message.notification?.body ?? '';
        final level = message.data['level'] ?? 'info';

        _showNotification(title: title, message: body, level: level);
      });

      // When user taps notification to open app
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("🔔 FCM opened app: ${message.notification?.title}");
      });
    } catch (e) {
      debugPrint("⚠️ FCM setup failed (non-critical): $e");
    }
  }

  void _startListening() {
    _sensorSub = FirebaseService().getSensorDataStream().listen((data) {
      // Only trigger on status CHANGE
      if (data.status != _lastStatus) {
        final previousStatus = _lastStatus;
        _lastStatus = data.status;

        if (data.status == 'Potensi Kebakaran') {
          _showNotification(
            title: '🔥 Potensi Kebakaran!',
            message: 'BAHAYA! Suhu ${data.temperature}°C, Gas ${data.gasValue}. Segera periksa ruangan!',
            level: 'danger',
          );
        } else if (data.status == 'Asap Terdeteksi') {
          _showNotification(
            title: '⚠️ Asap Terdeteksi',
            message: 'Kadar asap meningkat (${data.smokeLevel}). Kelembaban ${data.humidity}%, Suhu ${data.temperature}°C.',
            level: 'warning',
          );
        } else if (data.status == 'Aman' && previousStatus != 'Aman') {
          _addNotification(
            title: 'Kondisi Kembali Aman',
            message: 'Suhu ${data.temperature}°C, Kelembaban ${data.humidity}%. Kondisi ruangan sudah stabil.',
            level: 'info',
          );
        }
      }
    });
  }

  Future<void> _showNotification({
    required String title,
    required String message,
    required String level,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'sensor_alerts',
      'Sensor Alerts',
      channelDescription: 'Notifikasi peringatan sensor ruangan',
      importance: level == 'danger' ? Importance.max : Importance.high,
      priority: level == 'danger' ? Priority.max : Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(message),
    );

    await _plugin.show(
      _notifId++,
      title,
      message,
      NotificationDetails(android: androidDetails),
    );

    _addNotification(title: title, message: message, level: level);
  }

  void _addNotification({
    required String title,
    required String message,
    required String level,
  }) {
    _notifications.insert(
      0,
      NotificationData(title: title, message: message, time: DateTime.now(), level: level),
    );
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }
    _controller.add(List.unmodifiable(_notifications));
    debugPrint("🔔 Notification added: $title");
  }

  void clearAll() {
    _notifications.clear();
    _controller.add([]);
    _plugin.cancelAll();
  }

  void dispose() {
    _sensorSub?.cancel();
    _controller.close();
  }
}
