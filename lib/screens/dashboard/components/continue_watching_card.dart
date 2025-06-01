// lib/screens/dashboard/components/continue_watching_card.dart
import 'package:flutter/material.dart';
import 'package:smart_lms/config/app_config.dart';
import 'package:smart_lms/models/course.dart';
import 'package:smart_lms/screens/dashboard/components/course_details_page.dart';

class ContinueWatchingCard extends StatelessWidget {
  final Course course;
  final bool clickable;

  const ContinueWatchingCard({
    super.key,
    required this.course,
    this.clickable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: clickable
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailsPage(course: course),
                ),
              );
            }
          : null,
      child: Container(
        width: 140,
        height: 180,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: _buildCourseImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                course.displayTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 دالة بناء صورة الكورس المحلية
  Widget _buildCourseImage() {
    final imageUrl = course.displayImage;
    final localImagePath = AppConfig.fixImageUrl(imageUrl);

    print(
        '🖼️ ContinueWatching - Loading local image for ${course.displayTitle}: $localImagePath');

    return Image.asset(
      localImagePath,
      height: 120,
      width: 140,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ ContinueWatching - Local image not found: $localImagePath');
        return _buildFallbackImage();
      },
    );
  }

  // صورة بديلة جميلة
  Widget _buildFallbackImage() {
    return Container(
      height: 120,
      width: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.withOpacity(0.3),
            Colors.teal.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            color: Colors.teal,
            size: 32,
          ),
          SizedBox(height: 4),
          Text(
            'Continue',
            style: TextStyle(
              fontSize: 10,
              color: Colors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
