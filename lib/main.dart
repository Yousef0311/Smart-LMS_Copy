import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart'; // 🔴 اضيف ده
import 'package:flutter/material.dart';
import 'package:smart_lms/screens/splash_screen.dart';
import 'package:smart_lms/themes/dark_theme.dart';
import 'package:smart_lms/themes/light_theme.dart';

import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // 🔴 امسح السطر ده:
  // AppConfig.setEnvironment(Environment.development);

  // 🔴 واستبدله بده:
  _setupEnvironmentAutomatically();

  // 🔴 اضيف ده للتحقق:
  if (!AppConfig.validateConfig()) {
    print('⚠️ خطأ في إعدادات التطبيق');
  }

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

// 🔴 اضيف الدالة دي في الآخر
void _setupEnvironmentAutomatically() {
  if (kIsWeb) {
    // إذا كان يعمل على الويب
    AppConfig.setupForWeb();
    print('🌐 تم إعداد التطبيق للويب تلقائياً');
    print('🔗 API URL: ${AppConfig.apiBaseUrl}');
  } else {
    // إذا كان يعمل على موبايل
    AppConfig
        .setupForMobile(); // 🔥 هيستدعي setupForMobile ويستخدم 192.168.1.19
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
