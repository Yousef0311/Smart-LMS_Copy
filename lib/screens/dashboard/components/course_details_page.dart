import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🔥 أضف دي للـ Clipboard
import 'package:smart_lms/config/app_config.dart';
import 'package:smart_lms/models/course.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsPage extends StatelessWidget {
  final Course course;
  final bool isEnrolled; // هل الطالب مشترك في الكورس أم لا

  const CourseDetailsPage({
    super.key,
    required this.course,
    this.isEnrolled = false, // افتراضي false للكورسات من Recommended
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    // تحديد حالة الاشتراك بناءً على المعامل أو بيانات الكورس
    final bool userIsEnrolled = isEnrolled || course.isEnrolled;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Course Details'.tr(), style: textTheme.titleLarge),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 صورة الكورس المحلية
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildCourseImage(),
            ),
            const SizedBox(height: 20),

            /// شارة الاشتراك (إذا كان مشترك)
            if (userIsEnrolled) _buildEnrollmentBadge(),

            /// العنوان والوصف
            Text(
              course.displayTitle,
              style: textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              course.displayDescription,
              style: textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[300] : Colors.black54,
              ),
            ),
            const SizedBox(height: 20),

            /// السطر الأول من المعلومات
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 5),
                Text('${course.rating}'.tr(), style: textTheme.bodyMedium),
                const Spacer(),
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 5),
                Text(course.displayDuration, style: textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),

            /// السطر الثاني من المعلومات
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 5),
                Text('${course.displayStudents}+ Students'.tr(),
                    style: textTheme.bodyMedium),
                const Spacer(),
                const Icon(Icons.school, size: 20),
                const SizedBox(width: 5),
                Text(course.displayLevel, style: textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),

            /// السعر (يظهر دايماً)
            Row(
              children: [
                Text(
                  course.finalPrice == 0.0
                      ? 'Free'
                      : '\$${course.finalPrice.toStringAsFixed(0)}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: course.isFree ? Colors.green : theme.primaryColor,
                    fontSize: 22,
                  ),
                ),
                if (course.hasDiscount) ...[
                  const SizedBox(width: 12),
                  Text(
                    '\$${course.price.toStringAsFixed(0)}',
                    style: textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${course.discount!.toInt()}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            /// رسالة للكورسات غير المشترك فيها
            if (!userIsEnrolled)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You need to enroll in this course to access the content.'
                            .tr(),
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            /// زرار بدء الكورس (فقط للمشتركين)
            if (userIsEnrolled) _buildStartCourseButton(context, theme),

            const SizedBox(height: 24),

            /// نظرة عامة
            Text(
              'Overview',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              course.overview,
              style: textTheme.bodyMedium?.copyWith(height: 1.5),
            ),

            /// معلومات إضافية للكورسات المشترك فيها
            if (userIsEnrolled) ...[
              const SizedBox(height: 24),
              _buildCourseProgressSection(textTheme),
            ],
          ],
        ),
      ),
    );
  }

  /// شارة تبين إن الطالب مشترك في الكورس
  Widget _buildEnrollmentBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 6),
          Text(
            'Enrolled'.tr(),
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// زرار بدء الكورس (فقط للمشتركين)
  Widget _buildStartCourseButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _startCourse(context),
        icon: const Icon(Icons.play_arrow),
        label: Text('Start Course'.tr()),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// قسم تقدم الطالب في الكورس
  Widget _buildCourseProgressSection(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress'.tr(),
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // شريط التقدم (مؤقت - يمكن ربطه بالـ API لاحقاً)
          LinearProgressIndicator(
            value: 0.3, // 30% مكتمل
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
          const SizedBox(height: 8),
          Text(
            '30% Complete • 3 of 10 lessons'.tr(),
            style: textTheme.bodySmall?.copyWith(color: Colors.teal),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              _buildProgressStat('Lessons', '3/10'),
              const SizedBox(width: 24),
              _buildProgressStat('Time Spent', '2h 15m'),
              const SizedBox(width: 24),
              _buildProgressStat('Assignments', '1/3'),
            ],
          ),
        ],
      ),
    );
  }

  /// إحصائيات التقدم
  Widget _buildProgressStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.teal,
          ),
        ),
        Text(
          label.tr(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// بدء الكورس (فتح لينك يوتيوب) - 🔥 محسن
  Future<void> _startCourse(BuildContext context) async {
    final String? youtubeUrl = _getCourseYoutubeUrl();

    if (youtubeUrl != null) {
      print('🔗 Trying to open YouTube URL: $youtubeUrl');

      try {
        final Uri url = Uri.parse(youtubeUrl);

        // جرب فتح في تطبيق يوتيوب الأول
        bool launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          print('❌ Failed to launch in external app, trying in app...');

          // إذا فشل، جرب فتح في المتصفح داخل التطبيق
          launched = await launchUrl(
            url,
            mode: LaunchMode.inAppWebView,
          );
        }

        if (!launched) {
          print('❌ Failed to launch in app, trying platform default...');

          // إذا فشل، جرب الطريقة الافتراضية
          launched = await launchUrl(url);
        }

        if (!launched) {
          throw Exception('Could not launch YouTube URL');
        } else {
          print('✅ YouTube URL launched successfully');
        }
      } catch (e) {
        print('❌ Error launching YouTube: $e');
        _showYouTubeErrorDialog(context, youtubeUrl);
      }
    } else {
      _showInfoDialog(context, 'Course content will be available soon'.tr());
    }
  }

  /// 🔥 دالة جديدة - معالجة أخطاء اليوتيوب
  void _showYouTubeErrorDialog(BuildContext context, String youtubeUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('YouTube Error'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cannot open YouTube automatically.'.tr()),
            SizedBox(height: 12),
            Text('Video URL:'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            SelectableText(
              youtubeUrl,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 12),
            Text('Please copy the link and open it manually in YouTube.'.tr()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              // نسخ الرابط
              await _copyToClipboard(context, youtubeUrl);
              Navigator.pop(context);
            },
            child: Text('Copy Link'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // جرب فتح في المتصفح العادي
              await _openInBrowser(context, youtubeUrl);
            },
            child: Text('Open in Browser'.tr()),
          ),
        ],
      ),
    );
  }

  /// 🔥 دالة جديدة - نسخ الرابط
  Future<void> _copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link copied to clipboard!'.tr()),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error copying to clipboard: $e');
    }
  }

  /// 🔥 دالة جديدة - فتح في المتصفح
  Future<void> _openInBrowser(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      _showErrorDialog(context, 'Cannot open browser'.tr());
    }
  }

  /// الحصول على لينك يوتيوب للكورس - 🔥 محسن
  String? _getCourseYoutubeUrl() {
    final courseTitle = course.displayTitle.toLowerCase();

    // معالجة أسماء مختلفة للكورسات
    if (courseTitle.contains('flutter') || courseTitle.contains('dart')) {
      return 'https://youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG';
    } else if (courseTitle.contains('data science') ||
        courseTitle.contains('machine learning')) {
      return 'https://youtube.com/playlist?list=PLjxrf2q8roU1bHBSX7aTUvWQh8_FnF4wY';
    } else if (courseTitle.contains('ux') ||
        courseTitle.contains('design') ||
        courseTitle.contains('web')) {
      return 'https://youtube.com/playlist?list=PLjxrf2q8roU2vBiDaHe1pv8q9a0UKs8D0';
    } else if (courseTitle.contains('ai') ||
        courseTitle.contains('artificial intelligence')) {
      return 'https://youtube.com/playlist?list=PLjxrf2q8roU0nD0EAIjgJUW0xUkZS0TiB';
    } else if (courseTitle.contains('advanced') &&
        courseTitle.contains('network')) {
      return 'https://youtube.com/playlist?list=PLjxrf2q8roU3FnfQlpHlbHW-UFtSKkQKM';
    } else if (courseTitle.contains('database')) {
      // 🔥 إصلاح لينك الـ Database - playlist بدل فيديو واحد
      return 'https://youtube.com/playlist?list=PLDoPjvoNmBAz6DT8SzQ1CODJTH-NIA7R9';
    } else if (courseTitle.contains('operating') &&
        courseTitle.contains('system')) {
      return 'https://youtube.com/playlist?list=PLBlnK6fEyqRiVhbXDGLXDk_OQAeuVcp2O';
    } else if (courseTitle.contains('computer') &&
        courseTitle.contains('network')) {
      return 'https://youtube.com/playlist?list=PLBlnK6fEyqRgMCUAG0XRw78UA8qnv6jEx';
    }

    // لينك عام للبرمجة
    return 'https://youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG';
  }

  /// رسالة خطأ
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'.tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'.tr()),
          ),
        ],
      ),
    );
  }

  /// رسالة معلومات
  void _showInfoDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Info'.tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'.tr()),
          ),
        ],
      ),
    );
  }

  /// 🔥 دالة بناء صورة الكورس المحلية
  Widget _buildCourseImage() {
    final localImagePath = AppConfig.fixImageUrl(course.displayImage);
    print('🖼️ CourseDetails - Loading local image: $localImagePath');

    return Image.asset(
      localImagePath,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ CourseDetails - Local image not found: $localImagePath');
        return _buildFallbackImage();
      },
    );
  }

  /// صورة بديلة في حالة عدم وجود الصورة
  Widget _buildFallbackImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.withOpacity(0.3),
            Colors.teal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            color: Colors.teal,
            size: 64,
          ),
          SizedBox(height: 8),
          Text(
            'Course Details',
            style: TextStyle(
              fontSize: 16,
              color: Colors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
