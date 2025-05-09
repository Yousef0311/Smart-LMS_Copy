enum Environment { development, staging, production }

class AppConfig {
  static Environment currentEnvironment = Environment.development;

  // عنوان API الذي سيستخدم حسب البيئة
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return 'http://127.0.0.1:8000/api'; // محلي (استخدم IP اللابتوب الخاص بك)
      //final String baseUrl = 'http://10.0.2.2:8000/api'; // للإيموليتور
      // final String baseUrl = 'http://127.0.0.1:8000/api'; // للويب
      // final String baseUrl = 'http://192.168.1.4:8000/api'; // للأجهزة الحقيقية (استبدل X بالرقم الصحيح)
      case Environment.staging:
        return 'https://staging.your-app-domain.com/api'; // سيرفر تجريبي
      case Environment.production:
        return 'https://api.your-app-domain.com/api'; // سيرفر إنتاج
    }
  }

  // إعدادات إضافية
  static bool get isProduction => currentEnvironment == Environment.production;
  static bool get useHttps => currentEnvironment != Environment.development;

  // تغيير البيئة برمجياً
  static void setEnvironment(Environment env) {
    currentEnvironment = env;
  }

  // إعدادات التطبيق الأخرى
  static const String appName = "Smart LMS";
  static const String appVersion = "1.0.0";

  // أقصى وقت للانتظار للاستجابة من API (بالثواني)
  static const int apiTimeoutSeconds = 30;

  // سلوك التخزين المؤقت
  static const bool enableOfflineMode = true;
  static const int cacheDurationDays = 7; // مدة الاحتفاظ بالبيانات المخزنة
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
