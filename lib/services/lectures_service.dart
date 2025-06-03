// lib/services/lectures_service.dart - Enhanced with default data
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lms/services/api_service.dart';

class LecturesService {
  final ApiService _apiService = ApiService();

  // Cache keys
  static const String _lecturesKey = 'cached_lectures';
  static const String _lecturesTimestampKey = 'lectures_cache_timestamp';
  static const String _hasDefaultLecturesKey = 'has_default_lectures';

  // 🔥 بيانات افتراضية للمحاضرات
  static final Map<String, dynamic> _defaultLecturesData = {
    'message': 'Demo lectures data',
    'data': [
      {
        'id': 1,
        'name': 'Flutter & Dart Development',
        'contents': [
          {
            'id': 1,
            'title': 'Introduction to Flutter',
            'description': 'Getting started with Flutter framework',
            'type': 'video',
            'duration': 45,
            'order': 1,
            'is_free': 1,
            'video_url': 'https://youtube.com/watch?v=demo1',
            'content_progress': [
              {'progress_percent': 100, 'is_completed': 1}
            ]
          },
          {
            'id': 2,
            'title': 'Dart Programming Basics',
            'description': 'Learning Dart programming language',
            'type': 'video',
            'duration': 60,
            'order': 2,
            'is_free': 1,
            'video_url': 'https://youtube.com/watch?v=demo2',
            'content_progress': [
              {'progress_percent': 75, 'is_completed': 0}
            ]
          },
          {
            'id': 3,
            'title': 'Flutter Widgets Deep Dive',
            'description': 'Understanding Flutter widgets',
            'type': 'video',
            'duration': 90,
            'order': 3,
            'is_free': 0,
            'video_url': 'https://youtube.com/watch?v=demo3',
            'content_progress': []
          }
        ]
      },
      {
        'id': 2,
        'name': 'Advanced Networking',
        'contents': [
          {
            'id': 4,
            'title': 'Network Fundamentals',
            'description': 'Basic networking concepts',
            'type': 'video',
            'duration': 50,
            'order': 1,
            'is_free': 1,
            'video_url': 'https://youtube.com/watch?v=demo4',
            'content_progress': [
              {'progress_percent': 100, 'is_completed': 1}
            ]
          },
          {
            'id': 5,
            'title': 'TCP/IP Protocol Suite',
            'description': 'Understanding TCP/IP protocols',
            'type': 'video',
            'duration': 70,
            'order': 2,
            'is_free': 1,
            'video_url': 'https://youtube.com/watch?v=demo5',
            'content_progress': [
              {'progress_percent': 30, 'is_completed': 0}
            ]
          },
          {
            'id': 6,
            'title': 'Network Security',
            'description': 'Security in computer networks',
            'type': 'video',
            'duration': 80,
            'order': 3,
            'is_free': 0,
            'video_url': 'https://youtube.com/watch?v=demo6',
            'content_progress': []
          }
        ]
      }
    ]
  };

  // جلب كل المحاضرات مع دعم offline محسن
  Future<Map<String, dynamic>> getAllLectures() async {
    try {
      // جرب الـ API الأول
      final response = await _apiService.request('lecture', 'GET');

      if (response['message'] != null && response['data'] != null) {
        print('✅ Lectures loaded from API successfully');
        print('📚 Courses with lectures: ${response['data'].length}');

        // حفظ البيانات للـ offline mode
        await _saveLecturesDataToCache(response);
        return response;
      }

      throw Exception('Invalid lectures response format');
    } catch (e) {
      print('❌ Error loading lectures from API: $e');

      // جرب البيانات المحفوظة
      final cachedData = await _loadCachedLecturesData();
      if (cachedData != null) {
        print('📱 Using cached lectures data (offline mode)');
        return {
          ...cachedData,
          'isOfflineMode': true,
          'message': 'Using cached data - progress may not sync until online'
        };
      }

      // 🔥 استخدم البيانات الافتراضية
      print('🎯 Using default lectures data for demo');
      await _saveDefaultLecturesData();
      return {
        ..._defaultLecturesData,
        'isOfflineMode': true,
        'isDefaultData': true,
        'message':
            'Showing demo lectures - connect to internet for real content'
      };
    }
  }

  // 🔥 حفظ البيانات الافتراضية للمحاضرات
  Future<void> _saveDefaultLecturesData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasDefaultLecturesKey, true);
      await _saveLecturesDataToCache(_defaultLecturesData);
      print('💾 Default lectures data saved successfully');
    } catch (e) {
      print('❌ Error saving default lectures data: $e');
    }
  }

  // 🔥 إعداد البيانات الأولية للمحاضرات
  Future<void> initializeDefaultLecturesData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasData = prefs.containsKey(_lecturesKey);

      if (!hasData) {
        print('🚀 Initializing app with default lectures data');
        await _saveDefaultLecturesData();
      } else {
        print('✅ App already has lectures data');
      }
    } catch (e) {
      print('❌ Error initializing lectures data: $e');
    }
  }

  // باقي الدوال...
  Future<void> _saveLecturesDataToCache(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(_lecturesKey, jsonEncode(data));
      await prefs.setInt(_lecturesTimestampKey, timestamp);

      print('💾 Lectures data cached successfully');
    } catch (e) {
      print('❌ Error caching lectures data: $e');
    }
  }

  Future<Map<String, dynamic>?> _loadCachedLecturesData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final lecturesJson = prefs.getString(_lecturesKey);
      final timestamp = prefs.getInt(_lecturesTimestampKey);

      if (lecturesJson == null) {
        return null;
      }

      // 🔥 خلي البيانات تشتغل حتى لو قديمة
      if (timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final ageHours = ((now - timestamp) / (1000 * 60 * 60)).round();

        if (ageHours > 168) {
          // أسبوع
          print('⚠️ Lectures data is ${ageHours}h old but still usable');
        }
      }

      return jsonDecode(lecturesJson);
    } catch (e) {
      print('❌ Error loading cached lectures data: $e');
      return null;
    }
  }

  // تحديث progress المحاضرة
  Future<Map<String, dynamic>> updateLectureProgress({
    required int courseContentId,
    required int progress,
  }) async {
    try {
      final response = await _apiService.request(
        'lecture/create-progress',
        'POST',
        body: {
          'course_content_id': courseContentId,
          'progress': progress,
        },
      );

      print('✅ Progress updated: ${response['message']}');
      return response;
    } catch (e) {
      print('❌ Error updating progress (will queue for later): $e');

      // حفظ التحديث في queue للمزامنة لاحقاً
      await _queueProgressUpdate(courseContentId, progress);

      return {
        'status': true,
        'message': 'Progress saved locally - will sync when online',
        'isOfflineMode': true
      };
    }
  }

  Future<void> _queueProgressUpdate(int courseContentId, int progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueKey = 'progress_queue';

      final queueJson = prefs.getString(queueKey) ?? '[]';
      final List<dynamic> queue = jsonDecode(queueJson);

      queue.add({
        'course_content_id': courseContentId,
        'progress': progress,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      await prefs.setString(queueKey, jsonEncode(queue));
      print('📝 Progress update queued for later sync');
    } catch (e) {
      print('❌ Error queuing progress update: $e');
    }
  }

  Future<void> syncPendingUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueKey = 'progress_queue';
      final queueJson = prefs.getString(queueKey);

      if (queueJson == null) return;

      final List<dynamic> queue = jsonDecode(queueJson);

      for (final update in queue) {
        try {
          await _apiService.request(
            'lecture/create-progress',
            'POST',
            body: {
              'course_content_id': update['course_content_id'],
              'progress': update['progress'],
            },
          );
          print(
              '✅ Synced progress update for content ${update['course_content_id']}');
        } catch (e) {
          print('❌ Failed to sync progress update: $e');
        }
      }

      await prefs.remove(queueKey);
      print('🔄 All pending updates synced');
    } catch (e) {
      print('❌ Error syncing pending updates: $e');
    }
  }

  // تحويل البيانات من API إلى شكل مناسب للعرض
  Map<String, dynamic> processLecturesData(Map<String, dynamic> apiResponse) {
    final List<dynamic> coursesData = apiResponse['data'] as List;

    List<String> courseNames = [];
    List<Map<String, dynamic>> allLectures = [];

    for (var courseData in coursesData) {
      String courseName = courseData['name'] ?? 'Unknown Course';
      courseNames.add(courseName);

      List<dynamic> contents = courseData['contents'] ?? [];

      for (var content in contents) {
        String status = _determineStatus(content);

        Map<String, dynamic> lecture = {
          'id': content['id'],
          'title': content['title'] ?? 'Unknown Lecture',
          'course': courseName,
          'courseId': courseData['id'],
          'type': content['type'] ?? 'video',
          'description': content['description'] ?? '',
          'duration': content['duration'] ?? 0,
          'order': content['order'] ?? 1,
          'isFree': content['is_free'] == 1,
          'videoUrl': content['video_url'],
          'status': status,
          'progress': _getProgress(content),
          'date': _generateDate(content['order']),
          'time': _generateTime(content['order']),
          'number': content['order'].toString(),
        };

        allLectures.add(lecture);
      }
    }

    return {
      'courses': courseNames,
      'lectures': allLectures,
      'coursesData': coursesData,
    };
  }

  String _determineStatus(Map<String, dynamic> content) {
    List<dynamic> progressList = content['content_progress'] ?? [];

    if (progressList.isEmpty) {
      return 'upcoming';
    }

    var progress = progressList.first;
    bool isCompleted = progress['is_completed'] == 1;
    int progressPercent = progress['progress_percent'] ?? 0;

    if (isCompleted) {
      return 'attended';
    } else if (progressPercent > 70) {
      return 'attended';
    } else if (progressPercent > 0) {
      return 'upcoming';
    } else {
      return 'upcoming';
    }
  }

  double _getProgress(Map<String, dynamic> content) {
    List<dynamic> progressList = content['content_progress'] ?? [];

    if (progressList.isEmpty) {
      return 0.0;
    }

    var progress = progressList.first;
    int progressPercent = progress['progress_percent'] ?? 0;
    return progressPercent / 100.0;
  }

  String _generateDate(int order) {
    DateTime now = DateTime.now();
    DateTime lectureDate = now.subtract(Duration(days: (10 - order).abs()));
    return '${lectureDate.day.toString().padLeft(2, '0')}/${lectureDate.month.toString().padLeft(2, '0')}/${lectureDate.year}';
  }

  String _generateTime(int order) {
    List<String> times = ['08:00', '10:00', '12:00', '14:00', '16:00'];
    return times[order % times.length];
  }

  Map<String, double> calculateProgressPerCourse(
      List<Map<String, dynamic>> lectures) {
    Map<String, int> totalLectures = {};
    Map<String, int> attendedLectures = {};

    for (var lecture in lectures) {
      String course = lecture['course'];
      totalLectures[course] = (totalLectures[course] ?? 0) + 1;
      if (lecture['status'] == 'attended') {
        attendedLectures[course] = (attendedLectures[course] ?? 0) + 1;
      }
    }

    Map<String, double> progressMap = {};
    totalLectures.forEach((course, total) {
      int attended = attendedLectures[course] ?? 0;
      progressMap[course] = total > 0 ? attended / total : 0.0;
    });

    return progressMap;
  }
}
