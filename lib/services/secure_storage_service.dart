// lib/services/secure_storage_service.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // مفاتيح التخزين
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _loginStatusKey = 'is_logged_in';
  static const String _biometricKey = 'biometric_enabled';

  // ═══════════════════════════════════════════════════════════
  // 🔑 إدارة التوكن
  // ═══════════════════════════════════════════════════════════

  /// حفظ توكن المصادقة
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
      print('✅ Token saved securely');
    } catch (e) {
      print('❌ Error saving token: $e');
      throw Exception('Failed to save authentication token');
    }
  }

  /// الحصول على توكن المصادقة
  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _authTokenKey);
      if (token != null) {
        print('✅ Token retrieved successfully');
      }
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  /// حذف توكن المصادقة
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _authTokenKey);
      print('✅ Token deleted successfully');
    } catch (e) {
      print('❌ Error deleting token: $e');
    }
  }

  /// التحقق من وجود توكن صالح
  static Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════
  // 👤 إدارة بيانات المستخدم
  // ═══════════════════════════════════════════════════════════

  /// حفظ بيانات المستخدم
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      await _storage.write(key: _userDataKey, value: jsonString);
      print('✅ User data saved securely');
    } catch (e) {
      print('❌ Error saving user data: $e');
      throw Exception('Failed to save user data');
    }
  }

  /// الحصول على بيانات المستخدم
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = await _storage.read(key: _userDataKey);
      if (jsonString != null) {
        final userData = jsonDecode(jsonString) as Map<String, dynamic>;
        print('✅ User data retrieved successfully');
        return userData;
      }
      return null;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  /// حذف بيانات المستخدم
  static Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: _userDataKey);
      print('✅ User data deleted successfully');
    } catch (e) {
      print('❌ Error deleting user data: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔄 إدارة Refresh Token
  // ═══════════════════════════════════════════════════════════

  /// حفظ Refresh Token
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      print('✅ Refresh token saved securely');
    } catch (e) {
      print('❌ Error saving refresh token: $e');
    }
  }

  /// الحصول على Refresh Token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      print('❌ Error getting refresh token: $e');
      return null;
    }
  }

  /// حذف Refresh Token
  static Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
      print('✅ Refresh token deleted successfully');
    } catch (e) {
      print('❌ Error deleting refresh token: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📱 إدارة حالة تسجيل الدخول
  // ═══════════════════════════════════════════════════════════

  /// تعيين حالة تسجيل الدخول
  static Future<void> setLoginStatus(bool isLoggedIn) async {
    try {
      await _storage.write(key: _loginStatusKey, value: isLoggedIn.toString());
      print('✅ Login status set to: $isLoggedIn');
    } catch (e) {
      print('❌ Error setting login status: $e');
    }
  }

  /// التحقق من حالة تسجيل الدخول
  static Future<bool> isLoggedIn() async {
    try {
      final status = await _storage.read(key: _loginStatusKey);
      return status == 'true';
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔐 إدارة البيومتريك
  // ═══════════════════════════════════════════════════════════

  /// تفعيل/إلغاء البيومتريك
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(key: _biometricKey, value: enabled.toString());
      print('✅ Biometric setting updated: $enabled');
    } catch (e) {
      print('❌ Error setting biometric: $e');
    }
  }

  /// التحقق من تفعيل البيومتريك
  static Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _storage.read(key: _biometricKey);
      return enabled == 'true';
    } catch (e) {
      print('❌ Error checking biometric: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🧹 إدارة عامة
  // ═══════════════════════════════════════════════════════════

  /// حذف كل البيانات المحفوظة (تسجيل خروج كامل)
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      print('✅ All secure data cleared successfully');
    } catch (e) {
      print('❌ Error clearing all data: $e');
    }
  }

  /// حذف بيانات المصادقة فقط (logout جزئي)
  static Future<void> clearAuthData() async {
    try {
      await Future.wait([
        deleteToken(),
        deleteRefreshToken(),
        setLoginStatus(false),
      ]);
      print('✅ Auth data cleared successfully');
    } catch (e) {
      print('❌ Error clearing auth data: $e');
    }
  }

  /// الحصول على كل المفاتيح المحفوظة (للـ debugging)
  static Future<Map<String, String>> getAllKeys() async {
    try {
      final allData = await _storage.readAll();
      print('🔍 All stored keys: ${allData.keys.toList()}');
      return allData;
    } catch (e) {
      print('❌ Error getting all keys: $e');
      return {};
    }
  }

  /// التحقق من حالة التخزين
  static Future<Map<String, dynamic>> getStorageStatus() async {
    try {
      final hasToken = await hasValidToken();
      final isUserLoggedIn = await isLoggedIn();
      final hasBiometric = await isBiometricEnabled();
      final userData = await getUserData();

      final status = {
        'has_valid_token': hasToken,
        'is_logged_in': isUserLoggedIn,
        'biometric_enabled': hasBiometric,
        'has_user_data': userData != null,
        'user_name': userData?['user']?['name'] ?? 'Unknown',
        'user_email': userData?['user']?['email'] ?? 'Unknown',
      };

      print('📊 Storage Status: $status');
      return status;
    } catch (e) {
      print('❌ Error getting storage status: $e');
      return {'error': e.toString()};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔧 دوال مساعدة للـ Migration
  // ═══════════════════════════════════════════════════════════

  /// نقل البيانات من SharedPreferences إلى SecureStorage
  static Future<void> migrateFromSharedPreferences() async {
    // يمكن تطبيق هذه الدالة لاحقاً إذا كنت محتاج migration
    print('📦 Migration feature - ready for implementation');
  }
}
