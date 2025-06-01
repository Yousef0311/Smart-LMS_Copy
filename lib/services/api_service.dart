// lib/services/api_service.dart
import 'dart:async'; // إضافة لاستخدام TimeoutException
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lms/config/app_config.dart';
import 'package:smart_lms/services/secure_storage_service.dart';

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
      final token = await SecureStorageService.getToken(); // 🔴 التغيير هنا
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // دالة عامة للطلبات HTTP - مُحدثة لتدعم PATCH
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
        case 'PATCH': // 🔴 إضافة جديدة
          response = await http
              .patch(url,
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
        // معالجة الأخطاء بناءً على status code
        if (response.statusCode == 401) {
          await SecureStorageService
              .clearAuthData(); // أو clearLocalData لو عندك
          throw Exception('انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى.');
        } else if (response.statusCode == 404) {
          throw Exception('المورد غير موجود');
        } else if (response.statusCode == 500) {
          throw Exception('خطأ في الخادم، حاول لاحقًا');
        } else {
          throw Exception(data['message'] ?? 'حدث خطأ غير متوقع');
        }
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
        await SecureStorageService.saveToken(data['data']['token']);
        await SecureStorageService.saveUserData(data['data']);
        await SecureStorageService.setLoginStatus(true);
      }

      return data;
    } catch (e) {
      // التحقق إذا كان هناك بيانات مستخدم محفوظة
      if (await SecureStorageService.isLoggedIn()) {
        final userData = await SecureStorageService.getUserData();
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
          await SecureStorageService.saveToken(data['data']['token']);
          await SecureStorageService.saveUserData(data['data']);
          await SecureStorageService.setLoginStatus(true);
        } else if (data['data']['user'] != null) {
          await SecureStorageService.saveUserData({
            'user': data['data']['user'],
            'token': data['data']['token'] ?? ''
          });
          await SecureStorageService.setLoginStatus(true);
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
      await SecureStorageService.clearAuthData();

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

  // 🔴 تحديث الملف الشخصي - الدالة المُحدثة والذكية
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    print('Sending profile update request...');
    print('Profile data: $profileData');

    // جرب الطرق المختلفة للتحديث
    try {
      // الطريقة الأولى: PUT method
      print('Trying PUT method to: profile');
      return await _request(
        'profile',
        'PUT',
        body: profileData,
      );
    } catch (e) {
      print('PUT failed: $e');

      try {
        // الطريقة الثانية: POST إلى endpoint مختلف
        print('Trying POST method to: profile/update');
        return await _request(
          'profile/update',
          'POST',
          body: profileData,
        );
      } catch (e2) {
        print('POST to profile/update failed: $e2');

        try {
          // الطريقة الثالثة: PATCH method
          print('Trying PATCH method to: profile');
          return await _request(
            'profile',
            'PATCH',
            body: profileData,
          );
        } catch (e3) {
          print('PATCH failed: $e3');

          // إذا فشلت كل الطرق، احفظ البيانات محلياً
          print('All methods failed, saving data locally');

          // حفظ البيانات محلياً كحل مؤقت
          await _saveProfileDataLocally(profileData);

          return {
            "status": true,
            "message":
                "Profile updated locally (Backend route needs configuration)",
            "data": profileData
          };
        }
      }
    }
  }

  // 🔴 دالة مساعدة لحفظ البيانات محلياً
  Future<void> _saveProfileDataLocally(Map<String, dynamic> profileData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // الحصول على البيانات الحالية
      final currentUserData = await getLocalUserData();

      if (currentUserData != null && currentUserData['user'] != null) {
        // تحديث بيانات المستخدم
        final updatedUser = {
          ...currentUserData['user'],
          ...profileData,
        };

        final updatedData = {
          ...currentUserData,
          'user': updatedUser,
        };

        // حفظ البيانات المحدثة
        await prefs.setString('user_data', jsonEncode(updatedData));
        print('Profile data saved locally successfully');
      }
    } catch (e) {
      print('Error saving profile data locally: $e');
    }
  }

  // دوال إدارة التوكن والبيانات المحلية

  Future<String?> getToken() async {
    return await SecureStorageService.getToken();
  }

  Future<bool> hasLocalLoginData() async {
    return await SecureStorageService.isLoggedIn();
  }

  Future<Map<String, dynamic>?> getLocalUserData() async {
    return await SecureStorageService.getUserData();
  }

  Future<void> clearLocalData() async {
    await SecureStorageService.clearAll();
  }

// دالة جديدة للتحقق من حالة المصادقة
  Future<Map<String, dynamic>> getAuthStatus() async {
    return await SecureStorageService.getStorageStatus();
  }

  // دالة عامة للوصول من الخارج
  Future<dynamic> request(String endpoint, String method,
      {Map<String, dynamic>? body,
      bool requiresAuth = true,
      bool useCache = true}) async {
    return await _request(endpoint, method,
        body: body, requiresAuth: requiresAuth, useCache: useCache);
  }
}
