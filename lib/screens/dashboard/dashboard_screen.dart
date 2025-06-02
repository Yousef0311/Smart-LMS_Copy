import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_lms/models/course.dart';
import 'package:smart_lms/screens/courses/courses_page.dart';
import 'package:smart_lms/screens/dashboard/components/course_details_page.dart';
import 'package:smart_lms/screens/lecture/lecture_page.dart';
import 'package:smart_lms/screens/profile/profile_page.dart';
import 'package:smart_lms/services/dashboard_service.dart';
import 'package:smart_lms/services/user_service.dart';
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
  String? _userName;

  // Services
  final UserService _userService = UserService();
  final DashboardService _dashboardService = DashboardService();

  // Data
  List<Course> _myCourses = [];
  List<Course> _continueWatching = [];
  List<Course> _recommended = [];
  Map<String, dynamic> _assignmentStats = {};

  // Search variables
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<Course> _filteredMyCourses = [];
  List<Course> _filteredContinueWatching = [];
  List<Course> _filteredRecommended = [];

  // Loading states
  bool _isLoadingUserData = true;
  bool _isLoadingDashboard = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDashboardData();
    _showNotificationIfNeeded();

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
      _filteredContinueWatching = _continueWatching;
      _filteredRecommended = _recommended;
    } else {
      _filteredMyCourses = _myCourses
          .where((course) =>
              course.displayTitle.toLowerCase().contains(_searchQuery) ||
              course.displayDescription.toLowerCase().contains(_searchQuery) ||
              course.displayLevel.toLowerCase().contains(_searchQuery))
          .toList();

      _filteredContinueWatching = _continueWatching
          .where((course) =>
              course.displayTitle.toLowerCase().contains(_searchQuery) ||
              course.displayDescription.toLowerCase().contains(_searchQuery) ||
              course.displayLevel.toLowerCase().contains(_searchQuery))
          .toList();

      _filteredRecommended = _recommended
          .where((course) =>
              course.displayTitle.toLowerCase().contains(_searchQuery) ||
              course.displayDescription.toLowerCase().contains(_searchQuery) ||
              course.displayLevel.toLowerCase().contains(_searchQuery))
          .toList();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _userService.getLocalUserData();
      if (userData != null && userData['user'] != null) {
        setState(() {
          _userName = userData['user']['name'];
          _isLoadingUserData = false;
        });
      }

      final profileData = await _userService.getProfile();
      if (profileData['user'] != null) {
        setState(() {
          _userName = profileData['user']['name'];
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoadingDashboard = true;
        _hasError = false;
      });

      final dashboardData = await _dashboardService.getAllDashboardData();

      setState(() {
        _myCourses = dashboardData['myCourses'] as List<Course>;
        _continueWatching = dashboardData['continueWatching'] as List<Course>;
        _recommended = dashboardData['recommended'] as List<Course>;
        _assignmentStats =
            dashboardData['assignmentStats'] as Map<String, dynamic>;

        // تحديث القوائم المفلترة
        _filterCourses();

        _isLoadingDashboard = false;
        _hasError = false;
      });

      print('✅ Dashboard data loaded successfully');
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      setState(() {
        _isLoadingDashboard = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
  }

  void _showNotificationIfNeeded() {
    if (!_hasShownNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📢 لديك محاضرة Flutter اليوم الساعة 5 مساءً!'.tr()),
            duration: Duration(seconds: 3),
          ),
        );
        _hasShownNotification = true;
      });
    }
  }

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
          hintText: 'Search courses, levels, descriptions...'.tr(),
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

    int totalResults = _filteredMyCourses.length +
        _filteredContinueWatching.length +
        _filteredRecommended.length;

    if (totalResults == 0) {
      return Container(
        height: 300,
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
                'Try different keywords'.tr(),
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                },
                icon: Icon(Icons.clear),
                label: Text('Clear Search'.tr()),
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
          _buildMyCoursesGrid(_filteredMyCourses),
          SizedBox(height: 22),
        ],

        // Continue Watching Results
        if (_filteredContinueWatching.isNotEmpty) ...[
          _buildSectionHeader(
              'Continue Watching'.tr(), _filteredContinueWatching.length),
          SizedBox(height: 12),
          _buildHorizontalCourseList(_filteredContinueWatching),
          SizedBox(height: 22),
        ],

        // Recommended Results
        if (_filteredRecommended.isNotEmpty) ...[
          _buildSectionHeader('Recommended'.tr(), _filteredRecommended.length),
          SizedBox(height: 12),
          _buildHorizontalCourseList(_filteredRecommended),
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
            fontSize: 18,
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

  Widget _buildMyCoursesGrid(List<Course> courses) {
    return SizedBox(
      height: 180,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return CourseCard(
            title: course.displayTitle,
            short: course.displayTitle
                .split(' ')
                .first
                .substring(0, 2)
                .toUpperCase(),
            course: course,
          );
        },
      ),
    );
  }

  Widget _buildHorizontalCourseList(List<Course> courses) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return ContinueWatchingCard(
            course: course,
            clickable: true,
          );
        },
      ),
    );
  }

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
        userName: _userName,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط البحث
              _buildSearchBar(),
              const SizedBox(height: 22),

              // إظهار نتائج البحث أو المحتوى العادي
              if (_searchQuery.isNotEmpty)
                _buildSearchResults()
              else ...[
                // Dashboard Cards (Assignment & Performance)
                _buildDashboardCards(),
                const SizedBox(height: 22),

                // My Courses Section
                Text('My Courses'.tr(),
                    style: themeText.titleMedium!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 12),
                _buildMyCoursesSection(),
                const SizedBox(height: 22),

                // Continue Watching Section
                Text('Continue Watching'.tr(),
                    style: themeText.titleMedium!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 12),
                _buildContinueWatchingSection(),
                const SizedBox(height: 22),

                // Recommended Courses Section
                Text('Recommended Courses'.tr(),
                    style: themeText.titleMedium!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 12),
                _buildRecommendedSection(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDashboardCards() {
    if (_isLoadingDashboard) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              height: 120,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          Expanded(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      );
    }

    if (_hasError) {
      return Container(
        height: 120,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(height: 8),
              Text('Error loading assignments'.tr(),
                  style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DashboardCard(
          title: 'Assignment'.tr(),
          subtitle: 'Task Progress'.tr(),
          value: _assignmentStats['submitted_assignments']?.toString() ?? '0',
          status: _assignmentStats['pending_text'] ?? '0 tasks left',
          isPerformance: true,
        ),
        DashboardCard(
          title: 'Performance'.tr(),
          subtitle: 'GRADE'.tr(),
          value: _assignmentStats['grade'] ?? 'N/A',
          status: _assignmentStats['status'] ?? 'No data',
          isPerformance: true,
        ),
      ],
    );
  }

  Widget _buildMyCoursesSection() {
    if (_isLoadingDashboard) {
      return Container(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_myCourses.isEmpty) {
      return Container(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined,
                  size: 40, color: Colors.grey), // 🔥 قللنا حجم الأيقونة
              SizedBox(height: 6), // 🔥 قللنا المسافة
              Text('No enrolled courses yet'.tr()),
              SizedBox(height: 4), // 🔥 قللنا المسافة
              Text('Browse available courses'.tr(),
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    // 🔥 حساب الارتفاع المطلوب بناءً على عدد الكورسات
    final coursesCount = _myCourses.length.clamp(0, 4);
    final rows = (coursesCount / 2).ceil(); // عدد الصفوف (كل صف فيه كورسين)
    final dynamicHeight = (rows * 85.0).clamp(85.0, 170.0); // ارتفاع ديناميكي

    return SizedBox(
      height: dynamicHeight, // 🔥 استخدام الارتفاع الديناميكي
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2, // 🔥 زودنا النسبة علشان الكارد يبقى أقصر
        ),
        itemCount: coursesCount,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final course = _myCourses[index];
          return CourseCard(
            title: course.displayTitle,
            short: course.displayTitle
                .split(' ')
                .first
                .substring(0, 2)
                .toUpperCase(),
            course: course,
          );
        },
      ),
    );
  }

  Widget _buildContinueWatchingSection() {
    if (_isLoadingDashboard) {
      return Container(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_continueWatching.isEmpty) {
      return Container(
        height: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No courses to continue'.tr()),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _continueWatching.length,
        itemBuilder: (context, index) {
          final course = _continueWatching[index];
          return ContinueWatchingCard(
            course: course,
            clickable: true,
          );
        },
      ),
    );
  }

  Widget _buildRecommendedSection() {
    if (_isLoadingDashboard) {
      return Container(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recommended.isEmpty) {
      return Container(
        height: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.recommend_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No recommendations available'.tr()),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recommended.length,
        itemBuilder: (context, index) {
          final course = _recommended[index];
          return GestureDetector(
            onTap: () => _navigateToCourseDetails(course),
            child: ContinueWatchingCard(
              course: course,
              clickable: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (index) {
        setState(() => _currentIndex = index);
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
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_filled),
          label: 'Dashboard'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library_outlined),
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
