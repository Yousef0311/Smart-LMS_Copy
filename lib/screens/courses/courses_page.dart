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

  // قوائم البيانات الأصلية
  List<Course> _myCourses = [];
  List<Course> _allCourses = [];

  // متغيرات البحث
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<Course> _filteredMyCourses = [];
  List<Course> _filteredAllCourses = [];

  // حالات التحميل
  bool _isLoadingMyCourses = true;
  bool _isLoadingAllCourses = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCoursesData();

    // استمع لتغييرات البحث
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterCourses();
    });
  }

  void _filterCourses() {
    if (_searchQuery.isEmpty) {
      _filteredMyCourses = _myCourses;
      _filteredAllCourses = _allCourses;
    } else {
      _filteredMyCourses = _myCourses
          .where((course) =>
              course.displayTitle.toLowerCase().contains(_searchQuery) ||
              course.displayDescription.toLowerCase().contains(_searchQuery) ||
              course.displayLevel.toLowerCase().contains(_searchQuery))
          .toList();

      _filteredAllCourses = _allCourses
          .where((course) =>
              course.displayTitle.toLowerCase().contains(_searchQuery) ||
              course.displayDescription.toLowerCase().contains(_searchQuery) ||
              course.displayLevel.toLowerCase().contains(_searchQuery))
          .toList();
    }
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

          // تحديث القوائم المفلترة
          _filterCourses();

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

  Widget _buildSearchBar() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: theme.inputDecorationTheme.hintStyle?.color,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          hintText: 'Search your course...'.tr(),
          hintStyle: theme.inputDecorationTheme.hintStyle,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      ),
    );
  }

  Widget _buildSearchResults() {
    final theme = Theme.of(context);
    final themeText = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    int totalResults = _filteredMyCourses.length + _filteredAllCourses.length;

    if (totalResults == 0) {
      return Container(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No courses found for "$_searchQuery"'.tr(),
                style: themeText.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Try different keywords or browse all courses'.tr(),
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: Icon(Icons.clear),
                    label: Text('Clear Search'.tr()),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                      Navigator.pushReplacement(
                        context,
                        FadePageRoute(
                          page: DashboardScreen(
                            toggleTheme: widget.toggleTheme,
                            isDarkMode: widget.isDarkMode,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.home),
                    label: Text('Go to Dashboard'.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عداد النتائج
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 20, color: Colors.teal),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Found $totalResults course${totalResults == 1 ? '' : 's'} for "$_searchQuery"',
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                },
                child: Text('Clear'.tr()),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // My Courses Results
        if (_filteredMyCourses.isNotEmpty) ...[
          _buildSectionHeader('My Courses'.tr(), _filteredMyCourses.length),
          SizedBox(height: 12),
          SizedBox(
            height: 310,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filteredMyCourses.length,
              itemBuilder: (context, index) {
                final course = _filteredMyCourses[index];
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
          ),
          SizedBox(height: 24),
        ],

        // All Courses Results
        if (_filteredAllCourses.isNotEmpty) ...[
          _buildSectionHeader('All Courses'.tr(), _filteredAllCourses.length),
          SizedBox(height: 12),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: screenWidth / (screenHeight / 1.4),
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredAllCourses.length,
            itemBuilder: (context, index) {
              final course = _filteredAllCourses[index];
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
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium!.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: Colors.teal,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
              // شريط البحث المحدث
              _buildSearchBar(),
              const SizedBox(height: 24),

              // إظهار نتائج البحث أو المحتوى العادي
              if (_searchQuery.isNotEmpty)
                _buildSearchResults()
              else ...[
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
