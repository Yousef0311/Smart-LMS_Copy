// lib/services/dashboard_service.dart
import 'package:smart_lms/models/course.dart';
import 'package:smart_lms/services/api_service.dart';
import 'package:smart_lms/services/courses_service.dart';

class DashboardService {
  final CoursesService _coursesService = CoursesService();
  final ApiService _apiService = ApiService();

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

  // جلب بيانات الـ Assignments
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

        print('📊 Assignment Stats: $stats');
        return stats;
      }

      throw Exception('Invalid assignment data format');
    } catch (e) {
      print('❌ Error loading assignment stats: $e');
      // إرجاع بيانات افتراضية في حالة الخطأ
      return _getDefaultAssignmentStats();
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
