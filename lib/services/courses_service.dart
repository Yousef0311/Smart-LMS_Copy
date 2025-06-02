// lib/services/courses_service.dart - Enhanced with offline support
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/course.dart';
import 'api_service.dart';

class CoursesService {
  final ApiService _apiService = ApiService();

  // Cache keys
  static const String _myCoursesKey = 'cached_my_courses';
  static const String _allCoursesKey = 'cached_all_courses';
  static const String _cacheTimestampKey = 'courses_cache_timestamp';

  // جلب كل الكورسات (All Courses + My Courses) مع دعم offline
  Future<Map<String, dynamic>> getAllCourses({int page = 1}) async {
    try {
      final response = await _apiService.request(
        'all-courses?page=$page',
        'GET',
      );

      print('✅ Courses loaded successfully');
      print('📊 All Courses: ${response['data']['allCourses']['data'].length}');
      print('📚 My Courses: ${response['data']['myCourses']['data'].length}');

      // 🔥 حفظ البيانات للـ offline mode
      await _saveCourseDataToCache(response);

      return response;
    } catch (e) {
      print('❌ Error loading courses from API: $e');

      // 🔥 محاولة تحميل البيانات من Cache
      final cachedData = await _loadCachedCourseData();
      if (cachedData != null) {
        print('📱 Using cached courses data (offline mode)');
        return {
          ...cachedData,
          'isOfflineMode': true,
          'message': 'Using cached data - some features may be limited'
        };
      }

      rethrow;
    }
  }

  // حفظ بيانات الكورسات للـ cache
  Future<void> _saveCourseDataToCache(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(
          _myCoursesKey, jsonEncode(data['data']['myCourses']));
      await prefs.setString(
          _allCoursesKey, jsonEncode(data['data']['allCourses']));
      await prefs.setInt(_cacheTimestampKey, timestamp);

      print('💾 Courses data cached successfully');
    } catch (e) {
      print('❌ Error caching courses data: $e');
    }
  }

  // تحميل بيانات الكورسات من Cache
  Future<Map<String, dynamic>?> _loadCachedCourseData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // التحقق من وجود البيانات
      final myCoursesJson = prefs.getString(_myCoursesKey);
      final allCoursesJson = prefs.getString(_allCoursesKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (myCoursesJson == null ||
          allCoursesJson == null ||
          timestamp == null) {
        return null;
      }

      // التحقق من صلاحية البيانات (7 أيام)
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheDuration = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds

      if (now - timestamp > cacheDuration) {
        print('📅 Cached courses data is expired');
        await _clearCourseCache();
        return null;
      }

      return {
        'success': true,
        'data': {
          'myCourses': jsonDecode(myCoursesJson),
          'allCourses': jsonDecode(allCoursesJson),
        }
      };
    } catch (e) {
      print('❌ Error loading cached courses data: $e');
      return null;
    }
  }

  // مسح cache الكورسات
  Future<void> _clearCourseCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_myCoursesKey);
      await prefs.remove(_allCoursesKey);
      await prefs.remove(_cacheTimestampKey);
      print('🧹 Courses cache cleared');
    } catch (e) {
      print('❌ Error clearing courses cache: $e');
    }
  }

  // جلب تفاصيل كورس محدد
  Future<Map<String, dynamic>> getCourseDetails(int courseId) async {
    try {
      final response = await _apiService.request(
        'courses/$courseId',
        'GET',
      );

      print('✅ Course details loaded for ID: $courseId');
      return response;
    } catch (e) {
      print('❌ Error loading course details: $e');
      rethrow;
    }
  }

  // الاشتراك في كورس
  Future<Map<String, dynamic>> subscribeToCourse(int courseId) async {
    try {
      final response = await _apiService.request(
        'courses/$courseId/subscribe',
        'POST',
      );

      print('✅ Successfully subscribed to course ID: $courseId');

      // 🔥 إعادة تحميل البيانات بعد الاشتراك
      await getAllCourses();

      return response;
    } catch (e) {
      print('❌ Error subscribing to course: $e');
      rethrow;
    }
  }

  // جلب كورس مشترك فيه
  Future<Map<String, dynamic>> getEnrolledCourse(int courseId) async {
    try {
      final response = await _apiService.request(
        'courses/$courseId/enrolled',
        'GET',
      );

      print('✅ Enrolled course loaded for ID: $courseId');
      return response;
    } catch (e) {
      print('❌ Error loading enrolled course: $e');
      rethrow;
    }
  }

  // جلب My Courses فقط وتحويلها لـ Course objects
  Future<List<Course>> getMyCourses() async {
    try {
      final response = await getAllCourses();
      final myCoursesData = response['data']['myCourses']['data'] as List;

      return myCoursesData
          .map((courseJson) => Course.fromApi(courseJson))
          .toList();
    } catch (e) {
      print('❌ Error loading my courses: $e');
      return [];
    }
  }

  // جلب All Courses فقط وتحويلها لـ Course objects
  Future<List<Course>> getAvailableCourses() async {
    try {
      final response = await getAllCourses();
      final allCoursesData = response['data']['allCourses']['data'] as List;

      return allCoursesData
          .map((courseJson) => Course.fromApi(courseJson))
          .toList();
    } catch (e) {
      print('❌ Error loading available courses: $e');
      return [];
    }
  }
}
