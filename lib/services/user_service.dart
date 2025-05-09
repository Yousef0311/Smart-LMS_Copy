// lib/services/user_service.dart
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // تسجيل الدخول
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _apiService.login(email, password);
  }

  // تسجيل مستخدم جديد
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await _apiService.register(userData);
  }

  // الحصول على بيانات البروفايل
  Future<Map<String, dynamic>> getProfile() async {
    return await _apiService.getProfile();
  }

// تغيير كلمة المرور
  Future<Map<String, dynamic>> changePassword(String currentPassword,
      String newPassword, String newPasswordConfirmation) async {
    return await _apiService.changePassword(
        currentPassword, newPassword, newPasswordConfirmation);
  }

  // تسجيل الخروج
  Future<Map<String, dynamic>> logout() async {
    return await _apiService.logout();
  }

  // الحصول على بيانات المستخدم الحالي
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    return await _apiService.getProfile();
  }

  // تحديث بيانات المستخدم
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    return await _apiService.updateProfile(profileData);
  }

  // التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }

  // الحصول على بيانات المستخدم المحفوظة محلياً
  Future<Map<String, dynamic>?> getLocalUserData() async {
    return await _apiService.getLocalUserData();
  }

  // التحقق إذا كان المستخدم في وضع عدم الاتصال
  Future<bool> isInOfflineMode() async {
    // المستخدم في وضع عدم الاتصال إذا كان لديه بيانات محلية ولا يوجد اتصال بالإنترنت
    try {
      await _apiService.getProfile();
      return false; // إذا نجح الطلب، فالمستخدم متصل
    } catch (e) {
      final hasLocalData = await _apiService.hasLocalLoginData();
      return hasLocalData; // في وضع عدم الاتصال فقط إذا كان لديه بيانات محلية
    }
  }
}
