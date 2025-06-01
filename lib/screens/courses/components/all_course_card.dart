// lib/screens/courses/components/all_course_card.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_lms/config/app_config.dart';

class AllCourseCard extends StatelessWidget {
  final String image;
  final String title;
  final String price;
  final double rating;
  final VoidCallback? onTap;

  const AllCourseCard({
    super.key,
    required this.image,
    required this.title,
    required this.rating,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
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
            // 🔥 صورة الكورس - محلية
            AnimatedOpacity(
              opacity: 1,
              duration: Duration(milliseconds: 500),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: _buildCourseImage(),
              ),
            ),

            // عنوان الكورس
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // التقييم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  Text(
                    ' ${rating.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 4),

            // السعر
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                price,
                style: TextStyle(
                  color: price.toLowerCase().contains('free')
                      ? Colors.green
                      : Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 8),

            // زر View More
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'View More'.tr(),
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // 🔥 دالة بناء صورة الكورس المحلية
  Widget _buildCourseImage() {
    final localImagePath = AppConfig.fixImageUrl(image);
    print('🖼️ AllCourseCard - Loading local image: $localImagePath');

    return Image.asset(
      localImagePath,
      height: 100,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ AllCourseCard - Local image not found: $localImagePath');
        return _buildFallbackImage();
      },
    );
  }

  // صورة بديلة جميلة
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
