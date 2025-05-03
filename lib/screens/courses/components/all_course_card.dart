import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AllCourseCard extends StatelessWidget {
  final String image, title;

  AllCourseCard({required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // بدّل الأبيض بكده
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
          AnimatedOpacity(
            opacity: 1,
            duration: Duration(milliseconds: 500),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                image,
                height: 100, // Increase the size
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.star, size: 14, color: Colors.amber),
              Text(
                ' 4.6',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              )
            ],
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Free'.tr(),
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          // Add a 'View More' button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                // Add the action you want to perform when the button is pressed
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.teal, // Correct property for background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('View More'.tr(),
                  style: TextStyle(fontSize: 12, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
