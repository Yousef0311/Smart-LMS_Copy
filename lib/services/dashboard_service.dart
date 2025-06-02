// lib/services/dashboard_service.dart - Enhanced with offline support
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lms/models/course.dart';
import 'package:smart_lms/services/api_service.dart';
import 'package:smart_lms/services/courses_service.dart';

class DashboardService {
  final CoursesService _coursesService = CoursesService();
  final ApiService _apiService = ApiService();

  // Cache keys
  static const String _assignmentStatsKey = 'cached_assignment_stats';
  static const String _assignmentTimestampKey = 'assignment_cache_timestamp';

  // جلب الكورسات المشترك فيها للـ Dashboard
  Future<List<Course>> getMyCourses() async {
    try {
      final myCourses = await _coursesService.getMyCourses();
      print('📚 Dashboard My Courses: ${myCourses.length}');
      return myCourses;
    } catch (e) {
      print('❌ Error loading my courses for dashboard: $e');
      return [];
    }
  }

  // جلب كورسات Continue Watching (نفس My Courses بس أول 3)
  Future<List<Course>> getContinueWatchingCourses() async {
    try {
      final myCourses = await getMyCourses();
      // ناخد أول 3 كورسات أو كلهم لو أقل من 3
      final continueWatching = myCourses.take(3).toList();
      print('👀 Continue Watching: ${continueWatching.length}');
      return continueWatching;
    } catch (e) {
      print('❌ Error loading continue watching: $e');
      return [];
    }
  }

  // جلب الكورسات الموصى بها (من All Courses)
  Future<List<Course>> getRecommendedCourses() async {
    try {
      final allCourses = await _coursesService.getAvailableCourses();
      // ناخد أول 3 كورسات من الـ available courses
      final recommended = allCourses.take(3).toList();
      print('⭐ Recommended Courses: ${recommended.length}');
      return recommended;
    } catch (e) {
      print('❌ Error loading recommended courses: $e');
      return [];
    }
  }

  // جلب بيانات الـ Assignments مع دعم offline
  Future<Map<String, dynamic>> getAssignmentStats() async {
    try {
      final response = await _apiService.request('assignment/', 'GET');

      if (response['success'] == true && response['data'] != null) {
        final assignmentData = response['data'] as List;

        // حساب الإحصائيات
        int totalAssignments = 0;
        int submittedAssignments = 0;
        int notSubmittedAssignments = 0;

        for (var courseData in assignmentData) {
          final assignments = courseData['assignments'] as List;
          for (var assignment in assignments) {
            totalAssignments++;
            if (assignment['status'] == 'submitted') {
              submittedAssignments++;
            } else {
              notSubmittedAssignments++;
            }
          }
        }

        // حساب النسبة المئوية
        double completionRate = totalAssignments > 0
            ? (submittedAssignments / totalAssignments) * 100
            : 0.0;

        // تحديد الـ grade والـ status بناءً على النسبة
        String grade = _calculateGrade(completionRate);
        String status = _getGradeStatus(completionRate);

        final stats = {
          'total_assignments': totalAssignments,
          'submitted_assignments': submittedAssignments,
          'not_submitted_assignments': notSubmittedAssignments,
          'completion_rate': completionRate,
          'grade': grade,
          'status': status,
          'pending_text':
              '$notSubmittedAssignments of $totalAssignments tasks left',
        };

        // 🔥 حفظ البيانات للـ offline mode
        await _saveAssignmentStatsToCache(stats);

        print('📊 Assignment Stats: $stats');
        return stats;
      }

      throw Exception('Invalid assignment data format');
    } catch (e) {
      print('❌ Error loading assignment stats from API: $e');

      // 🔥 محاولة تحميل البيانات من Cache
      final cachedStats = await _loadCachedAssignmentStats();
      if (cachedStats != null) {
        print('📱 Using cached assignment stats (offline mode)');
        return {
          ...cachedStats,
          'isOfflineMode': true,
        };
      }

      // إرجاع بيانات افتراضية في حالة عدم وجود cache
      return _getDefaultAssignmentStats();
    }
  }

  // حفظ إحصائيات المهام للـ cache
  Future<void> _saveAssignmentStatsToCache(Map<String, dynamic> stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(_assignmentStatsKey, jsonEncode(stats));
      await prefs.setInt(_assignmentTimestampKey, timestamp);

      print('💾 Assignment stats cached successfully');
    } catch (e) {
      print('❌ Error caching assignment stats: $e');
    }
  }

  // تحميل إحصائيات المهام من Cache
  Future<Map<String, dynamic>?> _loadCachedAssignmentStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final statsJson = prefs.getString(_assignmentStatsKey);
      final timestamp = prefs.getInt(_assignmentTimestampKey);

      if (statsJson == null || timestamp == null) {
        return null;
      }

      // التحقق من صلاحية البيانات (3 أيام للـ assignments)
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheDuration = 3 * 24 * 60 * 60 * 1000;

      if (now - timestamp > cacheDuration) {
        print('📅 Cached assignment stats expired');
        await _clearAssignmentStatsCache();
        return null;
      }

      return jsonDecode(statsJson);
    } catch (e) {
      print('❌ Error loading cached assignment stats: $e');
      return null;
    }
  }

  // مسح cache إحصائيات المهام
  Future<void> _clearAssignmentStatsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_assignmentStatsKey);
      await prefs.remove(_assignmentTimestampKey);
      print('🧹 Assignment stats cache cleared');
    } catch (e) {
      print('❌ Error clearing assignment stats cache: $e');
    }
  }

  // حساب الدرجة بناءً على نسبة الإنجاز
  String _calculateGrade(double completionRate) {
    if (completionRate >= 90) return 'A+';
    if (completionRate >= 85) return 'A';
    if (completionRate >= 80) return 'A-';
    if (completionRate >= 75) return 'B+';
    if (completionRate >= 70) return 'B';
    if (completionRate >= 65) return 'B-';
    if (completionRate >= 60) return 'C+';
    if (completionRate >= 55) return 'C';
    if (completionRate >= 50) return 'C-';
    return 'D';
  }

  // تحديد حالة الدرجة
  String _getGradeStatus(double completionRate) {
    if (completionRate >= 80) return 'Excellent';
    if (completionRate >= 70) return 'Good';
    if (completionRate >= 60) return 'Average';
    if (completionRate >= 50) return 'Fair';
    return 'Needs Improvement';
  }

  // بيانات افتراضية في حالة فشل التحميل
  Map<String, dynamic> _getDefaultAssignmentStats() {
    return {
      'total_assignments': 5,
      'submitted_assignments': 2,
      'not_submitted_assignments': 3,
      'completion_rate': 40.0,
      'grade': 'C-',
      'status': 'Fair',
      'pending_text': '3 of 5 tasks left',
      'isOfflineMode': true,
    };
  }

  // جلب كل بيانات الـ Dashboard مرة واحدة
  Future<Map<String, dynamic>> getAllDashboardData() async {
    try {
      final results = await Future.wait([
        getMyCourses(),
        getContinueWatchingCourses(),
        getRecommendedCourses(),
        getAssignmentStats(),
      ]);

      return {
        'myCourses': results[0] as List<Course>,
        'continueWatching': results[1] as List<Course>,
        'recommended': results[2] as List<Course>,
        'assignmentStats': results[3] as Map<String, dynamic>,
      };
    } catch (e) {
      print('❌ Error loading all dashboard data: $e');
      rethrow;
    }
  }
}
