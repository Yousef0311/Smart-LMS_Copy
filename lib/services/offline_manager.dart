// lib/services/offline_manager.dart - إدارة شاملة للـ offline mode
import 'dart:convert'; // 🔥 إضافة الـ import المطلوب
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lms/services/courses_service.dart';
import 'package:smart_lms/services/dashboard_service.dart';
import 'package:smart_lms/services/lectures_service.dart';

class OfflineManager {
  static final OfflineManager _instance = OfflineManager._internal();
  factory OfflineManager() => _instance;
  OfflineManager._internal();

  // Services
  final LecturesService _lecturesService = LecturesService();
  final CoursesService _coursesService = CoursesService();
  final DashboardService _dashboardService = DashboardService();

  // Connectivity
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  bool _hasBeenOffline = false;

  // Cache status keys
  static const String _cacheStatusKey = 'offline_cache_status';
  static const String _lastSyncKey = 'last_sync_timestamp';

  /// 🔍 فحص حالة الاتصال بالإنترنت
  Future<bool> checkConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      // 🔥 الحل: التعامل مع List بدل ConnectivityResult واحد
      if (connectivityResults.contains(ConnectivityResult.none) ||
          connectivityResults.isEmpty) {
        _isOnline = false;
        _hasBeenOffline = true;
        print('📵 No internet connection detected');
        return false;
      }

      // فحص فعلي للاتصال بالسيرفر
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final wasOffline = !_isOnline;
        _isOnline = true;

        // إذا كان offline وعاد online، نزامن البيانات
        if (wasOffline || _hasBeenOffline) {
          print('🔄 Internet connection restored - syncing data...');
          await syncWhenBackOnline();
          _hasBeenOffline = false;
        }

        return true;
      }

      _isOnline = false;
      _hasBeenOffline = true;
      return false;
    } catch (e) {
      print('❌ Error checking connectivity: $e');
      _isOnline = false;
      _hasBeenOffline = true;
      return false;
    }
  }

  /// 📱 التحقق من وجود بيانات محفوظة للـ offline mode
  Future<bool> hasOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // فحص وجود البيانات الأساسية
      final hasCourses = prefs.containsKey('cached_my_courses') &&
          prefs.containsKey('cached_all_courses');
      final hasLectures = prefs.containsKey('cached_lectures');
      final hasAssignments = prefs.containsKey('cached_assignment_stats');

      print('📊 Offline data status:');
      print('   • Courses: ${hasCourses ? "✅" : "❌"}');
      print('   • Lectures: ${hasLectures ? "✅" : "❌"}');
      print('   • Assignments: ${hasAssignments ? "✅" : "❌"}');

      return hasCourses || hasLectures || hasAssignments;
    } catch (e) {
      print('❌ Error checking offline data: $e');
      return false;
    }
  }

  /// 🔄 مزامنة البيانات عند العودة للاتصال
  Future<void> syncWhenBackOnline() async {
    try {
      print('🔄 Starting sync process...');

      // مزامنة تحديثات التقدم المعلقة
      await _lecturesService.syncPendingUpdates();

      // تحديث البيانات من السيرفر
      await Future.wait([
        _refreshCoursesData(),
        _refreshLecturesData(),
        _refreshDashboardData(),
      ]);

      // تحديث وقت آخر مزامنة
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);

      print('✅ Sync completed successfully');
    } catch (e) {
      print('❌ Error during sync: $e');
    }
  }

  /// 📚 تحديث بيانات الكورسات
  Future<void> _refreshCoursesData() async {
    try {
      await _coursesService.getAllCourses();
      print('✅ Courses data refreshed');
    } catch (e) {
      print('❌ Error refreshing courses: $e');
    }
  }

  /// 📖 تحديث بيانات المحاضرات
  Future<void> _refreshLecturesData() async {
    try {
      await _lecturesService.getAllLectures();
      print('✅ Lectures data refreshed');
    } catch (e) {
      print('❌ Error refreshing lectures: $e');
    }
  }

  /// 📊 تحديث بيانات Dashboard
  Future<void> _refreshDashboardData() async {
    try {
      await _dashboardService.getAssignmentStats();
      print('✅ Dashboard data refreshed');
    } catch (e) {
      print('❌ Error refreshing dashboard: $e');
    }
  }

  /// 🧹 مسح جميع البيانات المؤقتة
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final keysToRemove = [
        'cached_my_courses',
        'cached_all_courses',
        'courses_cache_timestamp',
        'cached_lectures',
        'lectures_cache_timestamp',
        'cached_assignment_stats',
        'assignment_cache_timestamp',
        'progress_queue',
        _cacheStatusKey,
        _lastSyncKey,
      ];

      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      print('🧹 All cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// 📊 الحصول على إحصائيات Cache
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final coursesTimestamp = prefs.getInt('courses_cache_timestamp');
      final lecturesTimestamp = prefs.getInt('lectures_cache_timestamp');
      final assignmentTimestamp = prefs.getInt('assignment_cache_timestamp');
      final lastSync = prefs.getInt(_lastSyncKey);

      final now = DateTime.now().millisecondsSinceEpoch;

      return {
        'is_online': _isOnline,
        'has_offline_data': await hasOfflineData(),
        'cache_info': {
          'courses': {
            'exists': coursesTimestamp != null,
            'age_hours': coursesTimestamp != null
                ? ((now - coursesTimestamp) / (1000 * 60 * 60)).round()
                : null,
          },
          'lectures': {
            'exists': lecturesTimestamp != null,
            'age_hours': lecturesTimestamp != null
                ? ((now - lecturesTimestamp) / (1000 * 60 * 60)).round()
                : null,
          },
          'assignments': {
            'exists': assignmentTimestamp != null,
            'age_hours': assignmentTimestamp != null
                ? ((now - assignmentTimestamp) / (1000 * 60 * 60)).round()
                : null,
          },
        },
        'last_sync': lastSync != null
            ? DateTime.fromMillisecondsSinceEpoch(lastSync).toString()
            : 'Never',
        'pending_updates': await _hasPendingUpdates(),
      };
    } catch (e) {
      print('❌ Error getting cache stats: $e');
      return {'error': e.toString()};
    }
  }

  /// 🔍 فحص وجود تحديثات معلقة
  Future<bool> _hasPendingUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString('progress_queue');

      if (queueJson == null) return false;

      final List<dynamic> queue = jsonDecode(queueJson);
      return queue.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 🎯 فرض تحديث البيانات (حتى لو كانت موجودة)
  Future<void> forceRefreshAllData() async {
    try {
      print('🔄 Force refreshing all data...');

      // مسح Cache أولاً
      await clearAllCache();

      // تحديث البيانات
      if (_isOnline) {
        await syncWhenBackOnline();
      } else {
        print('❌ Cannot force refresh - no internet connection');
        throw Exception('No internet connection available');
      }
    } catch (e) {
      print('❌ Error force refreshing data: $e');
      rethrow;
    }
  }

  /// 📱 إعداد الـ Connectivity Listener
  void setupConnectivityListener() {
    // 🔥 الحل: التعامل مع List<ConnectivityResult> بدل ConnectivityResult واحد
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      checkConnectivity();
    });
  }

  /// 🔍 فحص شامل لحالة النظام
  Future<Map<String, dynamic>> getSystemStatus() async {
    final cacheStats = await getCacheStats();
    final isOnline = await checkConnectivity();

    return {
      'connectivity': {
        'is_online': isOnline,
        'has_been_offline': _hasBeenOffline,
      },
      'cache': cacheStats,
      'recommendations': await _getRecommendations(isOnline, cacheStats),
    };
  }

  /// 💡 توصيات للمستخدم
  Future<List<String>> _getRecommendations(
      bool isOnline, Map<String, dynamic> cacheStats) async {
    final recommendations = <String>[];

    if (!isOnline) {
      recommendations.add('📵 You are offline. Some features may be limited.');

      if (cacheStats['has_offline_data'] == true) {
        recommendations.add('✅ Cached data is available for viewing.');
      } else {
        recommendations.add(
            '❌ No cached data available. Connect to internet to load content.');
      }
    } else {
      if (_hasBeenOffline) {
        recommendations.add('🔄 Syncing data after being offline...');
      }

      final cacheInfo = cacheStats['cache_info'] as Map<String, dynamic>? ?? {};

      // فحص عمر البيانات
      cacheInfo.forEach((key, value) {
        final ageHours = value['age_hours'] as int?;
        if (ageHours != null && ageHours > 24) {
          recommendations
              .add('⏰ $key data is ${ageHours}h old. Consider refreshing.');
        }
      });

      if (cacheStats['pending_updates'] == true) {
        recommendations
            .add('📤 You have pending progress updates that will be synced.');
      }
    }

    return recommendations;
  }

  /// Getters
  bool get isOnline => _isOnline;
  bool get hasBeenOffline => _hasBeenOffline;
}
