import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String image;
  final String title;
  final String details;
  final String students;
  final String price;
  final double rating;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.image,
    required this.title,
    required this.rating,
    required this.details,
    required this.students,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 4,
              spreadRadius: 1.5,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الكورس
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildCourseImage(),
            ),
            SizedBox(height: 8),

            // عنوان الكورس
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // التقييم
            Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.amber),
                Text(' ${rating.toStringAsFixed(1)}')
              ],
            ),

            // التفاصيل
            Text(
              details,
              style: TextStyle(color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // عدد الطلاب
            Text(
              students,
              style: TextStyle(color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            Spacer(),

            // السعر وزر العرض
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    price,
                    style: TextStyle(
                      color: price.toLowerCase().contains('free')
                          ? Colors.green
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'View More'.tr(),
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // بناء صورة الكورس
  Widget _buildCourseImage() {
    print('🖼️ Loading image: $image');

    // إذا كانت الصورة من API (تحتوي على http)
    if (image.startsWith('http')) {
      return Image.network(
        image,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Image failed to load: $image');
          print('Error: $error');
          return Container(
            height: 100,
            width: double.infinity,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: Colors.grey[600]),
                SizedBox(height: 4),
                Text(
                  'Image not available',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('✅ Image loaded successfully: $image');
            return child;
          }
          return Container(
            height: 100,
            width: double.infinity,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      // إذا كانت صورة محلية
      return Image.asset(
        image,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Local image not found: $image');
          return Container(
            height: 100,
            width: double.infinity,
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
