import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class SensorData {
  final double temperature;
  final double humidity;
  final int gasValue;
  final String smokeLevel;
  final String status;
  final int timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.gasValue,
    required this.smokeLevel,
    required this.status,
    required this.timestamp,
  });

  // Default / Safe values
  factory SensorData.initial() {
    return SensorData(
      temperature: 28.0,
      humidity: 60.0,
      gasValue: 400,
      smokeLevel: 'Rendah',
      status: 'Aman',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      gasValue: (json['gasValue'] ?? 0).toInt(),
      smokeLevel: json['smokeLevel'] ?? 'Rendah',
      status: json['status'] ?? 'Aman',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'gasValue': gasValue,
      'smokeLevel': smokeLevel,
      'status': status,
      'timestamp': timestamp,
    };
  }
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool get isFirebaseLive => Firebase.apps.isNotEmpty;

  // Stream of sensor data from Firebase or Mock
  Stream<SensorData> getSensorDataStream() {
    debugPrint("🔍 Firebase.apps count: ${Firebase.apps.length}");
    debugPrint("🔍 isFirebaseLive: $isFirebaseLive");
    if (isFirebaseLive) {
      try {
        // Listen to the latest entry in sensor/history, ordered by timestamp
        final query = FirebaseDatabase.instance
            .ref('sensor/history')
            .orderByChild('timestamp')
            .limitToLast(1);
        debugPrint("🔍 Listening to: sensor/history (limitToLast 1)");
        return query.onValue.map((event) {
          final snapshot = event.snapshot;
          debugPrint("📡 Firebase event received! exists=${snapshot.exists}");
          if (snapshot.exists && snapshot.value != null) {
            final rootMap = Map<String, dynamic>.from(snapshot.value as Map);
            // rootMap is {pushKey: {temperature: ..., humidity: ..., ...}}
            // Get the first (and only) entry
            final latestKey = rootMap.keys.first;
            final latestData = Map<String, dynamic>.from(rootMap[latestKey] as Map);
            debugPrint("📡 Latest data key=$latestKey: $latestData");
            return SensorData.fromJson(latestData);
          }
          return SensorData.initial();
        }).handleError((error) {
          debugPrint("❌ Error reading Firebase data: $error. Falling back to mock data.");
          return _getMockSensorDataStream();
        });
      } catch (e) {
        debugPrint("❌ Firebase failed to hook stream: $e. Falling back to mock data.");
        return _getMockSensorDataStream();
      }
    } else {
      debugPrint("⚠️ Firebase is not initialized. Using Mock Data Stream.");
      return _getMockSensorDataStream();
    }
  }

  // Stream of history data (last N entries) from Firebase
  Stream<List<SensorData>> getHistoryStream({int limit = 20}) {
    if (isFirebaseLive) {
      try {
        final query = FirebaseDatabase.instance
            .ref('sensor/history')
            .orderByChild('timestamp')
            .limitToLast(limit);
        return query.onValue.map((event) {
          final snapshot = event.snapshot;
          if (snapshot.exists && snapshot.value != null) {
            final rootMap = Map<String, dynamic>.from(snapshot.value as Map);
            final List<SensorData> history = [];
            rootMap.forEach((key, value) {
              final data = Map<String, dynamic>.from(value as Map);
              history.add(SensorData.fromJson(data));
            });
            // Sort by timestamp ascending
            history.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            debugPrint("📊 History loaded: ${history.length} entries");
            return history;
          }
          return <SensorData>[];
        }).handleError((error) {
          debugPrint("❌ Error reading history: $error");
          return <SensorData>[];
        });
      } catch (e) {
        debugPrint("❌ Failed to hook history stream: $e");
        return Stream.value(<SensorData>[]);
      }
    } else {
      return Stream.value(<SensorData>[]);
    }
  }

  // Generates changing realistic mock data for preview/development
  Stream<SensorData> _getMockSensorDataStream() {
    double temp = 28.0;
    double hum = 60.0;
    int gas = 400;
    int tick = 0;

    return Stream.periodic(const Duration(seconds: 4), (index) {
      tick = (tick + 1) % 40;

      // Create a cycle of states: Aman -> Asap Terdeteksi -> Potensi Kebakaran -> Aman
      if (tick < 15) {
        // AMAN State
        temp = 28.0 + (index % 5) * 0.4; // 28.0 - 29.6
        hum = 60.0 + (index % 5) * 1.2;  // 60.0 - 64.8
        gas = 350 + (index % 4) * 80;    // 350 - 590
      } else if (tick < 28) {
        // ASAP TERDETEKSI State
        temp = 30.0 + (index % 5) * 0.5; // 30.0 - 32.0
        hum = 65.0 + (index % 5) * 1.5;  // 65.0 - 71.0
        gas = 1200 + (index % 5) * 200;  // 1200 - 2000
      } else {
        // POTENSI KEBAKARAN State (High Gas + High Temp)
        temp = 36.0 + (index % 5) * 0.8; // 36.0 - 39.2
        hum = 55.0 - (index % 5) * 1.0;  // 55.0 - 51.0 (hot, dry)
        gas = 2500 + (index % 5) * 300;  // 2500 - 3700
      }

      // Determine smoke level and status based on variables
      String smokeLevel;
      String status;

      if (gas < 800) {
        smokeLevel = "Normal";
        status = "Aman";
      } else if (gas < 2000) {
        smokeLevel = "Sedang";
        status = "Asap Terdeteksi";
      } else {
        smokeLevel = "Tinggi";
        status = temp >= 35.0 ? "Potensi Kebakaran" : "Asap Terdeteksi";
      }

      // Handle custom text according to user request
      if (gas < 500) {
        smokeLevel = "Rendah";
      }

      return SensorData(
        temperature: double.parse(temp.toStringAsFixed(1)),
        humidity: double.parse(hum.toStringAsFixed(1)),
        gasValue: gas,
        smokeLevel: smokeLevel,
        status: status,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }).asBroadcastStream();
  }
}
