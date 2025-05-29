import 'package:flutter/material.dart';
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

  Widget _buildCourseImage() {
    // استخدام displayImage من Course model اللي بيدعم network و local images
    final imageUrl = course.displayImage;

    print('🖼️ Loading image for ${course.displayTitle}: $imageUrl');

    // إذا كانت الصورة من API (تحتوي على http)
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: 120,
        width: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Network image failed to load: $imageUrl');
          print('Error: $error');
          // في حالة فشل تحميل الصورة من النت، استخدم الصورة المحلية
          return Image.asset(
            course.imagePath,
            height: 120,
            width: 140,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // إذا فشلت الصورة المحلية أيضاً، اعرض placeholder
              return Container(
                height: 120,
                width: 140,
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, color: Colors.grey[600]),
                    SizedBox(height: 4),
                    Text(
                      'No Image',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('✅ Network image loaded successfully: $imageUrl');
            return child;
          }
          return Container(
            height: 120,
            width: 140,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else {
      // إذا كانت صورة محلية
      return Image.asset(
        imageUrl,
        height: 120,
        width: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Local image not found: $imageUrl');
          return Container(
            height: 120,
            width: 140,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: Colors.grey[600]),
                SizedBox(height: 4),
                Text(
                  'Image not found',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
