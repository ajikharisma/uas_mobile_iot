import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  try {
    await Firebase.initializeApp();
    debugPrint("✅ Firebase initialized successfully (default).");
  } catch (e) {
    debugPrint("Default Firebase init failed: $e");
    debugPrint("Trying explicit FirebaseOptions...");
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyABY4emCf5xPZJFoNKF6-I9DQVoFEU-45U',
          appId: '1:548204797589:android:a4b0aac03943e1d14b859c',
          messagingSenderId: '548204797589',
          projectId: 'miot-miniproject-firedetection',
          databaseURL: 'https://miot-miniproject-firedetection-default-rtdb.asia-southeast1.firebasedatabase.app',
          storageBucket: 'miot-miniproject-firedetection.firebasestorage.app',
        ),
      );
      debugPrint("✅ Firebase initialized successfully (explicit options).");
    } catch (e2) {
      debugPrint("❌ Firebase initialization completely failed: $e2. Using Demo Mode.");
    }
  }
  // Initialize notification service
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    return MaterialApp(
      title: 'Smart Room Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        textTheme: baseTextTheme.copyWith(
          headlineLarge: baseTextTheme.headlineLarge?.copyWith(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            color: const Color(0xFF334155),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}