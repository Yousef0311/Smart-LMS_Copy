// lib/screens/courses/components/course_card.dart - نسخة مبسطة للصور المحلية
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_lms/config/app_config.dart';

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
            // 🔥 صورة الكورس - نسخة مبسطة للصور المحلية
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

  // 🔥 دالة مبسطة لبناء صورة الكورس
  Widget _buildCourseImage() {
    final localImagePath = AppConfig.fixImageUrl(image);
    print('🖼️ CourseCard - Loading local image: $localImagePath');

    return Image.asset(
      localImagePath,
      height: 100,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ CourseCard - Local image not found: $localImagePath');
        return _buildFallbackImage();
      },
    );
  }

  // صورة بديلة
  Widget _buildFallbackImage() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.withOpacity(0.3),
            Colors.teal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            color: Colors.teal,
            size: 32,
          ),
          SizedBox(height: 4),
          Text(
            'Course',
            style: TextStyle(
              fontSize: 12,
              color: Colors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
