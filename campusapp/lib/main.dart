import 'package:flutter/material.dart';
import 'package:campusapp/core/app_colors.dart';
import 'package:campusapp/pages/dashboard.dart';
import 'package:campusapp/pages/login_page.dart';
import 'package:campusapp/pages/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campusapp/services/cache_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await CacheService.init();

  await dotenv.load(fileName: ".env");

  // Initialize Firebase (Requires google-services.json in android/app)
  try {
    await Firebase.initializeApp();
    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission();
  } catch (e) {
    print("Firebase Initialization Error: $e");
  }

  await Supabase.initialize(
    url: dotenv.env['supabase_url'] ?? '',
    anonKey: dotenv.env['supabase_key'] ?? '',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.accentBorder,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
          surface: AppColors.cardGrey,
          onSurface: AppColors.textMain,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textMain),
          titleTextStyle: TextStyle(
            color: AppColors.textMain,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textMain),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
