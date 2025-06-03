// lib/services/dashboard_service.dart - Enhanced with default data
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

  // 🔥 بيانات افتراضية للـ assignments
  static final Map<String, dynamic> _defaultAssignmentStats = {
    'total_assignments': 8,
    'submitted_assignments': 5,
    'not_submitted_assignments': 3,
    'completion_rate': 62.5,
    'grade': 'B-',
    'status': 'Good Progress',
    'pending_text': '3 of 8 tasks left',
    'isDefaultData': true,
  };

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

  // جلب كورسات Continue Watching
  Future<List<Course>> getContinueWatchingCourses() async {
    try {
      final myCourses = await getMyCourses();
      final continueWatching = myCourses.take(3).toList();
      print('👀 Continue Watching: ${continueWatching.length}');
      return continueWatching;
    } catch (e) {
      print('❌ Error loading continue watching: $e');
      return [];
    }
  }

  // جلب الكورسات الموصى بها
  Future<List<Course>> getRecommendedCourses() async {
    try {
      final allCourses = await _coursesService.getAvailableCourses();
      final recommended = allCourses.take(3).toList();
      print('⭐ Recommended Courses: ${recommended.length}');
      return recommended;
    } catch (e) {
      print('❌ Error loading recommended courses: $e');
      return [];
    }
  }

  // 🔥 جلب بيانات الـ Assignments مع دعم offline محسن
  Future<Map<String, dynamic>> getAssignmentStats() async {
    try {
      // جرب الـ API الأول
      final response = await _apiService.request('assignment/', 'GET');

      if (response['success'] == true && response['data'] != null) {
        final assignmentData = response['data'] as List;
        final stats = _calculateAssignmentStats(assignmentData);

        // حفظ البيانات للـ offline mode
        await _saveAssignmentStatsToCache(stats);
        print('📊 Assignment Stats from API: $stats');
        return stats;
      }

      throw Exception('Invalid assignment data format');
    } catch (e) {
      print('❌ Error loading assignment stats from API: $e');

      // 🔥 جرب البيانات المحفوظة
      final cachedStats = await _loadCachedAssignmentStats();
      if (cachedStats != null) {
        print('📱 Using cached assignment stats (offline mode)');
        return {
          ...cachedStats,
          'isOfflineMode': true,
        };
      }

      // 🔥 استخدم البيانات الافتراضية
      print('🎯 Using default assignment stats for demo');
      await _saveAssignmentStatsToCache(_defaultAssignmentStats);
      return {
        ..._defaultAssignmentStats,
        'isOfflineMode': true,
        'message': 'Showing demo data - connect to internet for real stats'
      };
    }
  }

  // 🔥 حساب إحصائيات المهام
  Map<String, dynamic> _calculateAssignmentStats(List assignmentData) {
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

    double completionRate = totalAssignments > 0
        ? (submittedAssignments / totalAssignments) * 100
        : 0.0;

    String grade = _calculateGrade(completionRate);
    String status = _getGradeStatus(completionRate);

    return {
      'total_assignments': totalAssignments,
      'submitted_assignments': submittedAssignments,
      'not_submitted_assignments': notSubmittedAssignments,
      'completion_rate': completionRate,
      'grade': grade,
      'status': status,
      'pending_text':
          '$notSubmittedAssignments of $totalAssignments tasks left',
    };
  }

  // 🔥 إعداد البيانات الأولية للـ assignments
  Future<void> initializeDefaultAssignmentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasData = prefs.containsKey(_assignmentStatsKey);

      if (!hasData) {
        print('🚀 Initializing app with default assignment data');
        await _saveAssignmentStatsToCache(_defaultAssignmentStats);
      } else {
        print('✅ App already has assignment data');
      }
    } catch (e) {
      print('❌ Error initializing assignment data: $e');
    }
  }

  // باقي الدوال كما هي...
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

  Future<Map<String, dynamic>?> _loadCachedAssignmentStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final statsJson = prefs.getString(_assignmentStatsKey);
      final timestamp = prefs.getInt(_assignmentTimestampKey);

      if (statsJson == null) {
        return null;
      }

      // 🔥 خلي البيانات تشتغل حتى لو قديمة (للعرض)
      if (timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final ageHours = ((now - timestamp) / (1000 * 60 * 60)).round();

        if (ageHours > 72) {
          // 3 أيام
          print('⚠️ Assignment stats are ${ageHours}h old but still usable');
        }
      }

      return jsonDecode(statsJson);
    } catch (e) {
      print('❌ Error loading cached assignment stats: $e');
      return null;
    }
  }

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

  String _getGradeStatus(double completionRate) {
    if (completionRate >= 80) return 'Excellent';
    if (completionRate >= 70) return 'Good';
    if (completionRate >= 60) return 'Average';
    if (completionRate >= 50) return 'Fair';
    return 'Needs Improvement';
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
