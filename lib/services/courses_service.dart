// تحديث ملف lib/services/courses_service.dart

import '../models/course.dart';
import 'api_service.dart';

class CoursesService {
  final ApiService _apiService = ApiService();

  // جلب كل الكورسات (All Courses + My Courses)
  Future<Map<String, dynamic>> getAllCourses({int page = 1}) async {
    try {
      final response = await _apiService.request(
        'all-courses?page=$page',
        'GET',
      );

      print('✅ Courses loaded successfully');
      print('📊 All Courses: ${response['data']['allCourses']['data'].length}');
      print('📚 My Courses: ${response['data']['myCourses']['data'].length}');

      return response;
    } catch (e) {
      print('❌ Error loading courses: $e');
      rethrow;
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
