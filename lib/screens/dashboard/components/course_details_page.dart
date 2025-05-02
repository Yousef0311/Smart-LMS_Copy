
import 'package:flutter/material.dart';
import 'package:smart_lms/models/course.dart';

class CourseDetailsPage extends StatelessWidget {
  final Course course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Course Details', style: textTheme.titleLarge),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// صورة الكورس
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(course.imagePath),
            ),
            const SizedBox(height: 20),

            /// العنوان والوصف
            Text(
              course.title,
              style: textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              course.description,
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
                Text('${course.rating}', style: textTheme.bodyMedium),
                const Spacer(),
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 5),
                Text(course.duration, style: textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),

            /// السطر الثاني من المعلومات
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 5),
                Text('${course.students}+ Students',
                    style: textTheme.bodyMedium),
                const Spacer(),
                const Icon(Icons.school, size: 20),
                const SizedBox(width: 5),
                Text(course.level, style: textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),

            /// السعر
            Text(
              course.price == 0.0 ? 'Free' : '\$${course.price}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 16),

            /// زرار بدء الكورس
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Course'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
