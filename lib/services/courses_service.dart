// lib/services/courses_service.dart - Enhanced with default data
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
  static const String _hasDefaultDataKey = 'has_default_data';

  // 🔥 البيانات الافتراضية للعرض
  static final Map<String, dynamic> _defaultCoursesData = {
    'success': true,
    'data': {
      'myCourses': {
        'data': [
          {
            'id': 1,
            'name': 'Flutter & Dart Development',
            'description': 'Learn Flutter and Dart from scratch',
            'course_image': 'flutter_course.png',
            'course_level': 'Intermediate',
            'course_hours': 16,
            'lessons_number': 25,
            'students_count': 150,
            'price': 49.99,
            'discount': 20,
            'rating': 4.8,
            'status': 1,
            'created_at': '2024-01-01',
          },
          {
            'id': 2,
            'name': 'Advanced Networking',
            'description': 'Deep dive into computer networks',
            'course_image': 'network_course.png',
            'course_level': 'Advanced',
            'course_hours': 20,
            'lessons_number': 30,
            'students_count': 75,
            'price': 79.99,
            'discount': 15,
            'rating': 4.6,
            'status': 1,
            'created_at': '2024-01-01',
          }
        ]
      },
      'allCourses': {
        'data': [
          {
            'id': 3,
            'name': 'Data Science Fundamentals',
            'description': 'Introduction to data science and analytics',
            'course_image': 'data_science_course.png',
            'course_level': 'Beginner',
            'course_hours': 12,
            'lessons_number': 20,
            'students_count': 200,
            'price': 39.99,
            'discount': 0,
            'rating': 4.5,
            'status': 1,
            'created_at': '2024-01-01',
          },
          {
            'id': 4,
            'name': 'Web Development Bootcamp',
            'description': 'Full stack web development',
            'course_image': 'web_course.png',
            'course_level': 'Intermediate',
            'course_hours': 40,
            'lessons_number': 50,
            'students_count': 300,
            'price': 99.99,
            'discount': 25,
            'rating': 4.7,
            'status': 1,
            'created_at': '2024-01-01',
          },
          {
            'id': 5,
            'name': 'AI & Machine Learning',
            'description': 'Explore artificial intelligence concepts',
            'course_image': 'ai_course.png',
            'course_level': 'Advanced',
            'course_hours': 30,
            'lessons_number': 40,
            'students_count': 120,
            'price': 129.99,
            'discount': 30,
            'rating': 4.9,
            'status': 1,
            'created_at': '2024-01-01',
          }
        ]
      }
    }
  };

  // جلب كل الكورسات مع دعم offline محسن
  Future<Map<String, dynamic>> getAllCourses({int page = 1}) async {
    try {
      // 🔥 جرب الـ API الأول
      final response = await _apiService.request(
        'all-courses?page=$page',
        'GET',
      );

      print('✅ Courses loaded from API successfully');
      print('📊 All Courses: ${response['data']['allCourses']['data'].length}');
      print('📚 My Courses: ${response['data']['myCourses']['data'].length}');

      // حفظ البيانات للـ offline mode
      await _saveCourseDataToCache(response);
      return response;
    } catch (e) {
      print('❌ Error loading courses from API: $e');

      // 🔥 جرب البيانات المحفوظة
      final cachedData = await _loadCachedCourseData();
      if (cachedData != null) {
        print('📱 Using cached courses data (offline mode)');
        return {
          ...cachedData,
          'isOfflineMode': true,
          'message': 'Using cached data - some features may be limited'
        };
      }

      // 🔥 إذا مفيش cache، استخدم البيانات الافتراضية
      print('🎯 No cached data found, using default data for demo');
      await _saveDefaultData();
      return {
        ..._defaultCoursesData,
        'isOfflineMode': true,
        'isDefaultData': true,
        'message': 'Showing demo data - connect to internet for full experience'
      };
    }
  }

  // 🔥 حفظ البيانات الافتراضية
  Future<void> _saveDefaultData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasDefaultDataKey, true);
      await _saveCourseDataToCache(_defaultCoursesData);
      print('💾 Default data saved successfully');
    } catch (e) {
      print('❌ Error saving default data: $e');
    }
  }

  // 🔥 فحص إذا كان عندنا بيانات (أي نوع)
  Future<bool> hasAnyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // فحص وجود cache
      final hasCachedData =
          prefs.containsKey(_myCoursesKey) && prefs.containsKey(_allCoursesKey);

      // فحص وجود default data
      final hasDefaultData = prefs.getBool(_hasDefaultDataKey) ?? false;

      return hasCachedData || hasDefaultData;
    } catch (e) {
      return false;
    }
  }

  // 🔥 إعداد البيانات الأولية (يتم استدعاؤها في main.dart)
  Future<void> initializeDefaultData() async {
    final hasData = await hasAnyData();

    if (!hasData) {
      print('🚀 Initializing app with default course data');
      await _saveDefaultData();
    } else {
      print('✅ App already has course data');
    }
  }

  // باقي الدوال زي ما هي...
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

  Future<Map<String, dynamic>?> _loadCachedCourseData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final myCoursesJson = prefs.getString(_myCoursesKey);
      final allCoursesJson = prefs.getString(_allCoursesKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (myCoursesJson == null || allCoursesJson == null) {
        return null;
      }

      // 🔥 خلي البيانات تفضل شغالة حتى لو قديمة (للعرض بس)
      if (timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final ageHours = ((now - timestamp) / (1000 * 60 * 60)).round();

        if (ageHours > 168) {
          // أسبوع
          print('⚠️ Cached data is ${ageHours}h old but still usable');
        }
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

  Future<void> _clearCourseCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_myCoursesKey);
      await prefs.remove(_allCoursesKey);
      await prefs.remove(_cacheTimestampKey);
      // 🔥 مش نمسح الـ default data flag
      print('🧹 Courses cache cleared (keeping default data flag)');
    } catch (e) {
      print('❌ Error clearing courses cache: $e');
    }
  }

  // باقي الدوال
  Future<Map<String, dynamic>> getCourseDetails(int courseId) async {
    try {
      final response = await _apiService.request('courses/$courseId', 'GET');
      print('✅ Course details loaded for ID: $courseId');
      return response;
    } catch (e) {
      print('❌ Error loading course details: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> subscribeToCourse(int courseId) async {
    try {
      final response = await _apiService.request(
        'courses/$courseId/subscribe',
        'POST',
      );
      print('✅ Successfully subscribed to course ID: $courseId');
      await getAllCourses(); // إعادة تحميل
      return response;
    } catch (e) {
      print('❌ Error subscribing to course: $e');
      rethrow;
    }
  }

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
