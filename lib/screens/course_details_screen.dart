import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String courseTitle;

  const CourseDetailsScreen({super.key, required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(courseTitle)),
      body: Center(
        child: Text('تفاصيل الكورس: $courseTitle'.tr()),
      ),
    );
  }
}
