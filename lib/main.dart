import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_lms/screens/splash_screen.dart';
import 'package:smart_lms/services/courses_service.dart';
import 'package:smart_lms/services/dashboard_service.dart';
import 'package:smart_lms/services/lectures_service.dart';
import 'package:smart_lms/themes/dark_theme.dart';
import 'package:smart_lms/themes/light_theme.dart';
import 'package:smart_lms/utils/connectivity_helper.dart';

import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // 🔥 إعداد البيئة تلقائياً
  _setupEnvironmentAutomatically();

  // التحقق من صحة الإعدادات
  if (!AppConfig.validateConfig()) {
    print('⚠️ خطأ في إعدادات التطبيق');
  }

  // 🔥 إعداد البيانات الأولية للـ offline mode
  await _initializeOfflineData();

  // إعداد مراقب الاتصال بالإنترنت
  ConnectivityHelper.setupGlobalConnectivityListener();
  print('📡 Connectivity monitoring started');

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: MyApp(),
    ),
  );
}

// 🔥 دالة جديدة لإعداد البيانات الأولية
Future<void> _initializeOfflineData() async {
  try {
    print('🚀 Initializing offline data...');

    // إنشاء instances من الـ services
    final coursesService = CoursesService();
    final dashboardService = DashboardService();
    final lecturesService = LecturesService();

    // إعداد البيانات الافتراضية (بدون انتظار)
    await Future.wait([
      coursesService.initializeDefaultData(),
      dashboardService.initializeDefaultAssignmentData(),
      lecturesService.initializeDefaultLecturesData(),
    ]);

    print('✅ Offline data initialization completed');
  } catch (e) {
    print('❌ Error initializing offline data: $e');
    // لا نوقف التطبيق، فقط نسجل الخطأ
  }
}

void _setupEnvironmentAutomatically() {
  if (kIsWeb) {
    AppConfig.setupForWeb();
    print('🌐 تم إعداد التطبيق للويب تلقائياً');
    print('🔗 API URL: ${AppConfig.apiBaseUrl}');
  } else {
    AppConfig.setupForMobile();
    print('📱 تم إعداد التطبيق للموبايل تلقائياً');
    print('📍 IP الموبايل المستخدم: 192.168.1.3');
    print('🔗 API URL: ${AppConfig.apiBaseUrl}');
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart LMS'.tr(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        isDarkMode: _isDarkMode,
        toggleTheme: _toggleTheme,
      ),
    );
  }
}
