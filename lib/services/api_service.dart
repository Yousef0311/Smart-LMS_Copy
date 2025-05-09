// lib/services/api_service.dart
import 'dart:async'; // إضافة لاستخدام TimeoutException
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lms/config/app_config.dart';

class ApiService {
  // استخدام الرابط من ملف الإعدادات
  String get baseUrl => AppConfig.apiBaseUrl;

  // إنشاء headers العامة
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // دالة عامة للطلبات HTTP
  Future<dynamic> _request(String endpoint, String method,
      {Map<String, dynamic>? body,
      bool requiresAuth = true,
      bool useCache = true}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    // التحقق من وجود إنترنت والاستجابة للطلب
    try {
      http.Response response;

      switch (method) {
        case 'GET':
          response = await http
              .get(url, headers: headers)
              .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
          break;
        case 'POST':
          response = await http
              .post(url,
                  headers: headers,
                  body: body != null ? jsonEncode(body) : null)
              .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
          break;
        case 'PUT':
          response = await http
              .put(url,
                  headers: headers,
                  body: body != null ? jsonEncode(body) : null)
              .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
          break;
        case 'DELETE':
          response = await http
              .delete(url, headers: headers)
              .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
          break;
        default:
          throw Exception('Unsupported method: $method');
      }

      // تحليل استجابة API
      final data = jsonDecode(response.body);

      // التحقق من حالة الاستجابة
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // إذا كان ناجحًا ويجب تخزين البيانات مؤقتًا
        if (useCache && method == 'GET') {
          _cacheResponse(endpoint, data);
        }
        return data;
      } else {
        throw HttpException(data['message'] ??
            'Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // التحقق إذا كان الخطأ متعلق بالاتصال
      if (e is SocketException || e is TimeoutException) {
        // استخدام البيانات المخزنة مؤقتًا إذا كانت موجودة
        if (useCache && method == 'GET') {
          final cachedData = await _getCachedResponse(endpoint);
          if (cachedData != null) {
            return {
              ...cachedData,
              'isOfflineMode': true,
            };
          }
        }
      }
      // إعادة توجيه الخطأ
      throw e;
    }
  }

  // دوال لتخزين واسترجاع الاستجابات المخزنة مؤقتًا
  Future<void> _cacheResponse(String endpoint, dynamic data) async {
    if (!AppConfig.enableOfflineMode) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'cache_$endpoint';
    final now = DateTime.now().millisecondsSinceEpoch;

    await prefs.setString(
        key,
        jsonEncode({
          'data': data,
          'timestamp': now,
        }));
  }

  Future<dynamic> _getCachedResponse(String endpoint) async {
    if (!AppConfig.enableOfflineMode) return null;

    final prefs = await SharedPreferences.getInstance();
    final key = 'cache_$endpoint';
    final cachedJson = prefs.getString(key);

    if (cachedJson == null) return null;

    final cached = jsonDecode(cachedJson);
    final timestamp = cached['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    // التحقق من صلاحية البيانات المخزنة
    final cacheDurationMs = AppConfig.cacheDurationDays * 24 * 60 * 60 * 1000;
    if (now - timestamp > cacheDurationMs) {
      // البيانات قديمة، حذف التخزين المؤقت
      await prefs.remove(key);
      return null;
    }

    return cached['data'];
  }

  // دوال المصادقة

  // تسجيل الدخول
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final data = await _request(
        'login',
        'POST',
        body: {
          'email': email,
          'password': password,
          'guard': 'web',
        },
        requiresAuth: false,
        useCache: false,
      );

      // حفظ التوكن
      if (data['status'] == true &&
          data['data'] != null &&
          data['data']['token'] != null) {
        await saveToken(data['data']['token']);
        await saveUserDataLocally(data['data']);
      }

      return data;
    } catch (e) {
      // التحقق إذا كان هناك بيانات مستخدم محفوظة
      if (await hasLocalLoginData()) {
        final userData = await getLocalUserData();
        return {
          "status": true,
          "message": "Using saved login data",
          "data": userData,
          "isOfflineMode": true
        };
      }

      rethrow;
    }
  }

  // تسجيل مستخدم جديد - دالة معدلة
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final data = await _request(
        'register',
        'POST',
        body: userData,
        requiresAuth: false,
        useCache: false,
      );

      // تحقق من نجاح التسجيل وحفظ البيانات والتوكن إذا كان متاحًا
      if (data['status'] == true && data['data'] != null) {
        // إذا كان API أرجع توكن، نحفظه
        if (data['data']['token'] != null) {
          await saveToken(data['data']['token']);
          await saveUserDataLocally(data['data']);
        }
        // إذا كانت البيانات تحتوي على بيانات المستخدم دون توكن
        else if (data['data']['user'] != null) {
          await saveUserDataLocally({
            'user': data['data']['user'],
            'token': data['data']['token'] ?? ''
          });
        }
      }

      return data;
    } catch (e) {
      // تحسين رسائل الخطأ
      if (e is HttpException) {
        // إذا كان هناك رسالة خطأ محددة من الخادم
        throw Exception(e.message);
      } else if (e is SocketException) {
        // خطأ اتصال بالشبكة
        throw Exception('Network error. Please check your connection.');
      } else if (e is TimeoutException) {
        // انتهاء مهلة الطلب
        throw Exception('Request timeout. Please try again.');
      } else if (e is FormatException) {
        // خطأ في تنسيق البيانات
        throw Exception('Invalid response format. Please try again.');
      }

      // أي خطأ آخر
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

// تغيير كلمة المرور
  Future<Map<String, dynamic>> changePassword(String currentPassword,
      String newPassword, String newPasswordConfirmation) async {
    // للتصحيح
    print('Sending password change request to: profile/update-password');

    return await _request(
      'profile/update-password', // المسار الصحيح هو 'profile/update-password'
      'POST',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
    );
  }

// تسجيل الخروج
  Future<Map<String, dynamic>> logout() async {
    try {
      // للتصحيح
      print('Attempting to logout with correct endpoint: user-logout');

      // محاولة تسجيل الخروج من API باستخدام المسار الصحيح
      final result = await _request('user-logout', 'POST', useCache: false);
      print('Logout API response: $result');

      // حذف البيانات المحلية بغض النظر عن نتيجة API
      await clearLocalData();

      return result;
    } catch (e) {
      print('Logout API failed: $e');
      // حذف البيانات المحلية حتى في حالة فشل API
      await clearLocalData();

      // إرجاع استجابة وهمية للتسهيل
      return {"status": true, "message": "Logged out locally"};
    }
  }

  // الحصول على الملف الشخصي
  Future<Map<String, dynamic>> getProfile() async {
    return await _request('profile', 'GET');
  }

// تحديث الملف الشخصي
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    // للتصحيح
    print('Sending profile update request to: profile');
    print('Profile data: $profileData');

    return await _request(
      'profile', // المسار الصحيح هو 'profile'
      'POST', // أو 'PUT' حسب تنفيذ API
      body: profileData,
    );
  }
  // دوال إدارة التوكن والبيانات المحلية

  // حفظ التوكن
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // الحصول على التوكن المخزن
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // حفظ بيانات المستخدم محلياً
  Future<void> saveUserDataLocally(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
    await prefs.setBool('is_logged_in', true);
  }

  // التحقق إذا كان المستخدم سجل دخول مسبقاً
  Future<bool> hasLocalLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // استرجاع بيانات المستخدم المحفوظة
  Future<Map<String, dynamic>?> getLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // مسح جميع البيانات المحلية
  Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('is_logged_in');
  }
}
