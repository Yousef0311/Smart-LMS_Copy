import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_lms/models/course.dart';
import 'package:smart_lms/screens/courses/components/course_card.dart';
import 'package:smart_lms/screens/dashboard/components/course_details_page.dart';
import 'package:smart_lms/screens/dashboard/dashboard_screen.dart';
import 'package:smart_lms/screens/lecture/lecture_page.dart';
import 'package:smart_lms/screens/profile/profile_page.dart';
import 'package:smart_lms/services/courses_service.dart';

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

  // خدمة الكورسات
  final CoursesService _coursesService = CoursesService();

  // قوائم البيانات
  List<Course> _myCourses = [];
  List<Course> _allCourses = [];

  // حالات التحميل
  bool _isLoadingMyCourses = true;
  bool _isLoadingAllCourses = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCoursesData();
  }

  // تحميل بيانات الكورسات
  Future<void> _loadCoursesData() async {
    try {
      print('🔄 Loading courses data...');

      // تحميل كل البيانات من API
      final response = await _coursesService.getAllCourses();

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          // تحويل My Courses من JSON إلى Course objects
          _myCourses = (response['data']['myCourses']['data'] as List)
              .map((courseJson) => Course.fromApi(courseJson))
              .toList();

          // تحويل All Courses من JSON إلى Course objects
          _allCourses = (response['data']['allCourses']['data'] as List)
              .map((courseJson) => Course.fromApi(courseJson))
              .toList();

          _isLoadingMyCourses = false;
          _isLoadingAllCourses = false;
          _hasError = false;
        });

        print('✅ Courses loaded successfully');
        print('📚 My Courses: ${_myCourses.length}');
        print('📖 All Courses: ${_allCourses.length}');
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('❌ Error loading courses: $e');
      setState(() {
        _isLoadingMyCourses = false;
        _isLoadingAllCourses = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  // إعادة تحميل البيانات
  Future<void> _refreshData() async {
    setState(() {
      _isLoadingMyCourses = true;
      _isLoadingAllCourses = true;
      _hasError = false;
    });
    await _loadCoursesData();
  }

  // التنقل إلى تفاصيل الكورس
  void _navigateToCourseDetails(Course course) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CourseDetailsPage(course: course),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
          var scaleTween = Tween<double>(begin: 0.9, end: 1.0);
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
  }

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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط البحث
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
                  onChanged: (value) {
                    // TODO: تطبيق البحث لاحقاً
                  },
                ),
              ),
              const SizedBox(height: 24),

              // My Courses Section
              Text('My Courses'.tr(),
                  style: themeText.titleMedium!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 12),

              // My Courses Content
              _buildMyCoursesSection(),

              const SizedBox(height: 24),

              // All Courses Section
              Text('All Courses'.tr(),
                  style: themeText.titleMedium!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 12),

              // All Courses Content
              _buildAllCoursesSection(screenWidth, screenHeight),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // قسم My Courses
  Widget _buildMyCoursesSection() {
    if (_isLoadingMyCourses) {
      return Container(
        height: 310,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return Container(
        height: 310,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 8),
              Text('Error loading courses'.tr()),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _refreshData,
                child: Text('Retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    if (_myCourses.isEmpty) {
      return Container(
        height: 310,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No enrolled courses yet'.tr()),
              SizedBox(height: 8),
              Text('Browse available courses below'.tr(),
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 310,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _myCourses.length,
        itemBuilder: (context, index) {
          final course = _myCourses[index];
          return CourseCard(
            image: course.displayImage,
            title: course.displayTitle,
            rating: course.rating,
            details:
                '${course.displayLevel} • ${course.lessonsNumber ?? 0} lessons • ${course.displayDuration}',
            students: '${course.displayStudents} students',
            price: course.isFree
                ? 'Free'
                : '\$${course.finalPrice.toStringAsFixed(0)}',
            onTap: () => _navigateToCourseDetails(course),
          );
        },
      ),
    );
  }

  // قسم All Courses
  Widget _buildAllCoursesSection(double screenWidth, double screenHeight) {
    if (_isLoadingAllCourses) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: screenWidth / (screenHeight / 1.4),
        children: List.generate(
          4,
          (index) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 8),
              Text('Error loading courses'.tr()),
              ElevatedButton(
                onPressed: _refreshData,
                child: Text('Retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    if (_allCourses.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.library_books_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No courses available'.tr()),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: screenWidth / (screenHeight / 1.4),
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _allCourses.length,
      itemBuilder: (context, index) {
        final course = _allCourses[index];
        return AllCourseCard(
          title: course.displayTitle,
          image: course.displayImage,
          rating: course.rating,
          price: course.isFree
              ? 'Free'
              : '\$${course.finalPrice.toStringAsFixed(0)}',
          onTap: () => _navigateToCourseDetails(course),
        );
      },
    );
  }

  // الشريط السفلي
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
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
    );
  }
}
