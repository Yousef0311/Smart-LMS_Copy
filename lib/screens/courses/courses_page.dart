import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_lms/screens/courses/components/course_card.dart';
import 'package:smart_lms/screens/dashboard/dashboard_screen.dart';
import 'package:smart_lms/screens/lecture/lecture_page.dart';
import 'package:smart_lms/screens/profile/profile_page.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/transitions.dart';
import 'components/all_course_card.dart';

class CoursesPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const CoursesPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode;
    final themeText = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppBar(
        context: context,
        isDarkMode: isDark,
        toggleTheme: widget.toggleTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search,
                      color: theme.inputDecorationTheme.hintStyle?.color),
                  hintText: 'Search your course...'.tr(),
                  hintStyle: theme.inputDecorationTheme.hintStyle,
                  border: InputBorder.none,
                ),
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            ),
            const SizedBox(height: 24),
            Text('My Courses'.tr(),
                style: themeText.titleMedium!.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            SizedBox(
              height: 310,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  CourseCard(
                    image: 'assets/images/web_course.png',
                    title: 'Back-End Course'.tr(),
                    rating: 4.6,
                    details: 'Beginner • 12 lessons • 2 h 50m'.tr(),
                    students: '1.6k students',
                    price: 'Free',
                  ),
                  CourseCard(
                    image: 'assets/images/network_course.jpg',
                    title: 'Computer Networking'.tr(),
                    rating: 4.6,
                    details: 'Beginner • 18 lessons • 3 h 45m',
                    students: '2.3k students',
                    price: '\$35',
                  ),
                  CourseCard(
                    image: 'assets/images/web_course.png',
                    title: 'Front-End Course'.tr(),
                    rating: 4.6,
                    details: 'Beginner • 12 lessons • 2 h 50m',
                    students: '1.6k students',
                    price: 'Free',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('All Courses'.tr(),
                style: themeText.titleMedium!.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: screenWidth / (screenHeight / 1.4),
              padding: EdgeInsets.zero,
              children: [
                AllCourseCard(
                    title: 'AI Course'.tr(),
                    image: 'assets/images/machine_course.png'),
                AllCourseCard(
                    title: 'Flutter & Dart'.tr(),
                    image: 'assets/images/flutter_course.png'),
                AllCourseCard(
                    title: 'Data Science'.tr(),
                    image: 'assets/images/react_course.png'),
                AllCourseCard(
                    title: 'Cyber Security'.tr(),
                    image: 'assets/images/security_course.png'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(
                page: DashboardScreen(
                  toggleTheme: widget.toggleTheme,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(
                page: ProfilePage(
                  toggleTheme: widget.toggleTheme,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(
                page: LecturesPage(
                  toggleTheme: widget.toggleTheme,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
            );
          }
        },
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Dashboard'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library_rounded),
            label: 'Courses'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            label: 'Lectures'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile'.tr(),
          ),
        ],
      ),
    );
  }
}
