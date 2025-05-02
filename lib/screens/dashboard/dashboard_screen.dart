
import 'package:flutter/material.dart';
import 'package:smart_lms/models/course.dart';
import 'package:smart_lms/screens/courses/courses_page.dart';
import 'package:smart_lms/screens/dashboard/components/course_details_page.dart';
import 'package:smart_lms/screens/lecture/lecture_page.dart';
import 'package:smart_lms/screens/profile/profile_page.dart';
import 'package:smart_lms/widgets/custom_appbar.dart';

import '../../widgets/transitions.dart';
import 'components/continue_watching_card.dart';
import 'components/course_card.dart';
import 'components/dashboard_card.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const DashboardScreen({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static bool _hasShownNotification = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!_hasShownNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📢 لديك محاضرة Flutter اليوم الساعة 5 مساءً!'),
            duration: Duration(seconds: 3),
          ),
        );
        _hasShownNotification = true;
      });
    }
  }

  final List<Course> courses = [
    Course(
        title: 'Machine Learning',
        imagePath: 'assets/images/machine_course.png',
        description: 'Intro to Machine Learning with Python',
        rating: 4.9,
        duration: '12h 30m',
        students: 30,
        level: 'Intermediate',
        price: 49.9,
        overview: 'Learn the basics of machine learning...'),
    Course(
        title: 'Cyber Security',
        imagePath: 'assets/images/security_course.png',
        description: 'Protect and secure systems from threats',
        rating: 4.7,
        duration: '10h 00m',
        students: 45,
        level: 'Beginner',
        price: 39.9,
        overview: 'An intro to modern cyber security practices...'),
    Course(
        title: 'Web Development',
        imagePath: 'assets/images/web_course.png',
        description: 'Full-stack web development course',
        rating: 4.8,
        duration: '15h 15m',
        students: 60,
        level: 'Advanced',
        price: 59.9,
        overview: 'Build professional websites and applications...'),
  ];

  // Lista de cursos para My Courses section
  final List<Map<String, String>> myCourses = [
    {'title': 'Data Science', 'short': 'DS'},
    {'title': 'UX Design', 'short': 'UX'},
    {'title': 'Flutter', 'short': 'FD'},
    {'title': 'AI Basics', 'short': 'AI'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final theme = Theme.of(context);
    final themeText = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppBar(
        isDarkMode: isDark,
        toggleTheme: widget.toggleTheme,
        showGreeting: true,
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search,
                      color: theme.inputDecorationTheme.hintStyle?.color),
                  hintText: 'Search',
                  hintStyle: theme.inputDecorationTheme.hintStyle,
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 22),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardCard(
                    title: 'Assignment',
                    subtitle: 'Task Progress',
                    value: 'Assignment',
                    status: '3 of 5 tasks left',
                    isPerformance: true,
                  ),
                  DashboardCard(
                    title: 'Performance',
                    subtitle: 'GRADE',
                    value: 'B+',
                    status: 'Good',
                    isPerformance: true,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text('My Courses',
                  style: themeText.titleMedium!.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: myCourses.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return CourseCard(
                      title: myCourses[index]['title']!,
                      short: myCourses[index]['short']!,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text('Continue Watching',
                  style: themeText.titleMedium!.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ContinueWatchingCard(
                      course: Course(
                          title: 'Computer Networking',
                          imagePath: 'assets/images/network_course.jpg',
                          description: 'Intro to networking',
                          rating: 4.5,
                          duration: '8h',
                          students: 25,
                          level: 'Beginner',
                          price: 29.9,
                          overview: 'Computer networking concepts...'),
                      clickable: false,
                    ),
                    ContinueWatchingCard(
                      course: Course(
                          title: 'Flutter',
                          imagePath: 'assets/images/flutter_course.png',
                          description: 'Learn to build Flutter apps',
                          rating: 4.6,
                          duration: '10h',
                          students: 40,
                          level: 'Intermediate',
                          price: 44.9,
                          overview: 'Master Flutter and Dart...'),
                      clickable: false,
                    ),
                    ContinueWatchingCard(
                      course: Course(
                          title: 'React Native',
                          imagePath: 'assets/images/react_course.png',
                          description: 'Cross-platform mobile dev',
                          rating: 4.7,
                          duration: '11h',
                          students: 35,
                          level: 'Intermediate',
                          price: 39.9,
                          overview: 'Build mobile apps with React Native...'),
                      clickable: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Recommended Courses',
                  style: themeText.titleMedium!.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: courses.map((course) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    CourseDetailsPage(course: course),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var fadeTween =
                                  Tween<double>(begin: 0.0, end: 1.0);
                              var scaleTween =
                                  Tween<double>(begin: 0.9, end: 1.0);
                              return FadeTransition(
                                opacity: animation.drive(fadeTween),
                                child: ScaleTransition(
                                  scale: animation.drive(scaleTween),
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: ContinueWatchingCard(
                        course: course,
                        clickable: true,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(
                page: CoursesPage(
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
          }
        },
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            //activeIcon: Icon(Icons.video_library_rounded),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            label: 'Lectures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
