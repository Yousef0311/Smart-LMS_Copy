// lib/services/lectures_service.dart
import 'package:smart_lms/services/api_service.dart';

class LecturesService {
  final ApiService _apiService = ApiService();

  // جلب كل المحاضرات للمستخدم
  Future<Map<String, dynamic>> getAllLectures() async {
    try {
      final response = await _apiService.request('lecture', 'GET');

      if (response['message'] != null && response['data'] != null) {
        print('✅ Lectures loaded successfully');
        print('📚 Courses with lectures: ${response['data'].length}');
        return response;
      }

      throw Exception('Invalid lectures response format');
    } catch (e) {
      print('❌ Error loading lectures: $e');
      rethrow;
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
      print('❌ Error updating progress: $e');
      rethrow;
    }
  }

  // تحويل البيانات من API إلى شكل مناسب للعرض
  Map<String, dynamic> processLecturesData(Map<String, dynamic> apiResponse) {
    final List<dynamic> coursesData = apiResponse['data'] as List;

    // استخراج قائمة الكورسات
    List<String> courseNames = [];
    List<Map<String, dynamic>> allLectures = [];

    for (var courseData in coursesData) {
      String courseName = courseData['name'] ?? 'Unknown Course';
      courseNames.add(courseName);

      // تحويل محتويات الكورس إلى محاضرات
      List<dynamic> contents = courseData['contents'] ?? [];

      for (var content in contents) {
        // تحديد حالة المحاضرة
        String status = _determineStatus(content);

        // إنشاء محاضرة
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
          'date': _generateDate(content['order']), // تاريخ وهمي مؤقت
          'time': _generateTime(content['order']), // وقت وهمي مؤقت
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

  // تحديد حالة المحاضرة بناءً على التقدم
  String _determineStatus(Map<String, dynamic> content) {
    List<dynamic> progressList = content['content_progress'] ?? [];

    if (progressList.isEmpty) {
      return 'upcoming'; // لم يبدأ بعد
    }

    var progress = progressList.first;
    bool isCompleted = progress['is_completed'] == 1;
    int progressPercent = progress['progress_percent'] ?? 0;

    if (isCompleted) {
      return 'attended'; // مكتمل
    } else if (progressPercent > 70) {
      return 'attended'; // تقريباً مكتمل
    } else if (progressPercent > 0) {
      return 'upcoming'; // بدأ لكن لم يكتمل
    } else {
      // فحص إذا كان التاريخ فات (logic مؤقت)
      return 'upcoming';
    }
  }

  // الحصول على نسبة التقدم
  double _getProgress(Map<String, dynamic> content) {
    List<dynamic> progressList = content['content_progress'] ?? [];

    if (progressList.isEmpty) {
      return 0.0;
    }

    var progress = progressList.first;
    int progressPercent = progress['progress_percent'] ?? 0;
    return progressPercent / 100.0;
  }

  // إنتاج تاريخ وهمي (مؤقت - يمكن تحسينه لاحقاً)
  String _generateDate(int order) {
    DateTime now = DateTime.now();
    DateTime lectureDate = now.subtract(Duration(days: (10 - order).abs()));
    return '${lectureDate.day.toString().padLeft(2, '0')}/${lectureDate.month.toString().padLeft(2, '0')}/${lectureDate.year}';
  }

  // إنتاج وقت وهمي (مؤقت)
  String _generateTime(int order) {
    List<String> times = ['08:00', '10:00', '12:00', '14:00', '16:00'];
    return times[order % times.length];
  }

  // حساب التقدم لكل كورس
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
