// lib/config/app_config.dart - تحديث IP الموبايل

enum Environment { development, staging, production }

enum DeviceType { web, emulator, physicalDevice }

class AppConfig {
  static Environment currentEnvironment = Environment.development;
  static DeviceType currentDevice = DeviceType.web;

  // عنوان API الذي سيستخدم حسب البيئة ونوع الجهاز
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return _getDevelopmentUrl();
      case Environment.staging:
        return 'https://staging.your-app-domain.com/api';
      case Environment.production:
        return 'https://api.your-app-domain.com/api';
    }
  }

  // دالة للحصول على رابط Development حسب نوع الجهاز
  static String _getDevelopmentUrl() {
    switch (currentDevice) {
      case DeviceType.web:
        return 'http://127.0.0.1:8000/api';
      case DeviceType.emulator:
        return 'http://10.0.2.2:8000/api';
      case DeviceType.physicalDevice:
        return 'http://192.168.1.3:8000/api'; // 🔥 الـ IP الصحيح للموبايل
    }
  }

  // 🔥 دالة جديدة للصور المحلية - مؤقتة
  static String fixImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'assets/images/default_course.png';
    }

    print('🔧 AppConfig - Original URL: $imageUrl');

    // استخراج اسم الصورة من الرابط
    String imageName = _extractImageName(imageUrl);
    String localPath = 'assets/images/$imageName';

    print('🔧 AppConfig - Using local image: $localPath');
    return localPath;
  }

  // استخراج اسم الصورة من الرابط
  static String _extractImageName(String url) {
    // إزالة كل شيء قبل اسم الملف
    if (url.contains('/')) {
      return url.split('/').last;
    }
    return url;
  }

  // إعدادات إضافية
  static bool get isProduction => currentEnvironment == Environment.production;
  static bool get isDevelopment =>
      currentEnvironment == Environment.development;
  static bool get useHttps => currentEnvironment != Environment.development;

  // دوال للتحكم في البيئة ونوع الجهاز
  static void setEnvironment(Environment env) {
    currentEnvironment = env;
    printCurrentConfig();
  }

  static void setDeviceType(DeviceType device) {
    currentDevice = device;
    printCurrentConfig();
  }

  // إعداد سريع للتطوير
  static void setupForWeb() {
    setEnvironment(Environment.development);
    setDeviceType(DeviceType.web);
  }

  static void setupForMobile() {
    setEnvironment(Environment.development);
    setDeviceType(DeviceType.physicalDevice);
  }

  static void setupForEmulator() {
    setEnvironment(Environment.development);
    setDeviceType(DeviceType.emulator);
  }

  // إعداد للإنتاج
  static void setupForProduction() {
    setEnvironment(Environment.production);
  }

  // إعدادات التطبيق الأخرى
  static const String appName = "Smart LMS";
  static const String appVersion = "1.0.0";
  static const int apiTimeoutSeconds = 30;
  static const bool enableOfflineMode = true;
  static const int cacheDurationDays = 7;

  // دالة مساعدة لطباعة معلومات الإعدادات الحالية
  static void printCurrentConfig() {
    print('╔════════════════════════════════════╗');
    print('║        Smart LMS Configuration     ║');
    print('╠════════════════════════════════════╣');
    print('║ Environment: $currentEnvironment');
    print('║ Device Type: $currentDevice');
    print('║ API Base URL: $apiBaseUrl');
    print('║ Using Local Images: TRUE');
    print('║ Offline Mode: $enableOfflineMode');
    print('║ Use HTTPS: $useHttps');
    print('╚════════════════════════════════════╝');
  }

  // دالة للتحقق من صحة الإعدادات
  static bool validateConfig() {
    try {
      final apiUrl = apiBaseUrl;
      print('✅ Configuration is valid.');
      print('✅ API URL: $apiUrl');
      print('✅ Using local images from assets/');
      return true;
    } catch (e) {
      print('❌ Configuration error: $e');
      return false;
    }
  }
}
/*
//class AppConfig {
  //static const String apiBaseUrl = '127.0.0.1:8000/api';
  // 'http://10.0.2.2:8000/api'; // غيره حسب بيئة العمل
  //final String baseUrl = 'http://10.0.2.2:8000/api'; // للإيموليتور
  // final String baseUrl = 'http://127.0.0.1:8000/api'; // للويب
  // final String baseUrl = 'http://192.168.1.x:8000/api'; // للأجهزة الحقيقية (استبدل X بالرقم الصحيح)
}
*/
