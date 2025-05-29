import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_lms/screens/courses/courses_page.dart';
import 'package:smart_lms/screens/dashboard/dashboard_screen.dart';
import 'package:smart_lms/screens/lecture/components/course_filter_tabs.dart';
import 'package:smart_lms/screens/lecture/components/lecture_card.dart';
import 'package:smart_lms/screens/profile/profile_page.dart';
import 'package:smart_lms/services/lectures_service.dart';
import 'package:smart_lms/widgets/custom_appbar.dart';

import '../../widgets/transitions.dart';
import 'components/course_progress.dart';
import 'components/filter_bar.dart';

class LecturesPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const LecturesPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<LecturesPage> createState() => _LecturesPageState();
}

class _LecturesPageState extends State<LecturesPage> {
  int _currentIndex = 2;
  int _selectedCourseIndex = 0;
  String _searchQuery = '';
  String _selectedStatus = 'All';

  // Services
  final LecturesService _lecturesService = LecturesService();

  // Data
  List<String> _courses = [];
  List<Map<String, dynamic>> _allLectures = [];
  List<Map<String, dynamic>> _filteredLectures = [];
  Map<String, double> _progressMap = {};

  // Loading states
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  final List<String> statusOptions = ['All', 'Attended', 'Missed', 'Upcoming'];

  @override
  void initState() {
    super.initState();
    _loadLecturesData();
  }

  Future<void> _loadLecturesData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      print('🔄 Loading lectures data...');

      // جلب البيانات من API
      final apiResponse = await _lecturesService.getAllLectures();

      // معالجة البيانات
      final processedData = _lecturesService.processLecturesData(apiResponse);

      setState(() {
        _courses = List<String>.from(processedData['courses']);
        _allLectures =
            List<Map<String, dynamic>>.from(processedData['lectures']);

        // حساب التقدم لكل كورس
        _progressMap =
            _lecturesService.calculateProgressPerCourse(_allLectures);

        // تصفية المحاضرات
        _filterLectures();

        _isLoading = false;
        _hasError = false;
      });

      print('✅ Lectures loaded successfully');
      print('📚 Courses: ${_courses.length}');
      print('📖 Total Lectures: ${_allLectures.length}');
    } catch (e) {
      print('❌ Error loading lectures: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterLectures() {
    if (_courses.isEmpty) {
      _filteredLectures = [];
      return;
    }

    final currentCourse = _courses[_selectedCourseIndex];

    _filteredLectures = _allLectures.where((lecture) {
      final matchesCourse = lecture['course'] == currentCourse;
      final matchesSearch = _searchQuery.isEmpty ||
          lecture['course']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          lecture['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'All' ||
          lecture['status'] == _selectedStatus.toLowerCase();

      return matchesCourse && matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> _refreshData() async {
    await _loadLecturesData();
  }

  double get _currentProgress {
    if (_courses.isEmpty) return 0.0;
    final currentCourse = _courses[_selectedCourseIndex];
    return _progressMap[currentCourse] ?? 0.0;
  }

  String get _currentCourse {
    if (_courses.isEmpty) return 'No Courses';
    return _courses[_selectedCourseIndex];
  }

  String get _attendedText {
    if (_courses.isEmpty) return 'No data available';

    final currentCourse = _courses[_selectedCourseIndex];
    final courseLectures = _allLectures
        .where((lecture) => lecture['course'] == currentCourse)
        .toList();
    final attendedCount = courseLectures
        .where((lecture) => lecture['status'] == 'attended')
        .length;

    return 'Attended $attendedCount of ${courseLectures.length} lectures';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppBar(
        context: context,
        isDarkMode: widget.isDarkMode,
        toggleTheme: widget.toggleTheme,
        showGreeting: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading lectures...'.tr()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error loading lectures'.tr()),
                  SizedBox(height: 8),
                  Text(_errorMessage,
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: Text('Retry'.tr()),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_courses.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No enrolled courses found'.tr()),
                  SizedBox(height: 8),
                  Text('Enroll in courses to see lectures'.tr(),
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        FadePageRoute(
                          page: CoursesPage(
                            toggleTheme: widget.toggleTheme,
                            isDarkMode: widget.isDarkMode,
                          ),
                        ),
                      );
                    },
                    child: Text('Browse Courses'.tr()),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Course Filter Tabs
              CourseFilterTabs(
                courses: _courses,
                selectedIndex: _selectedCourseIndex,
                onTap: (index) {
                  setState(() {
                    _selectedCourseIndex = index;
                    _filterLectures();
                  });
                },
              ),
              const SizedBox(height: 12),

              // Course Title and Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentCourse,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    CourseProgress(
                      progress: _currentProgress,
                      attendedText: _attendedText,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilterBar(
                  selectedStatus: _selectedStatus,
                  statusOptions: statusOptions,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterLectures();
                    });
                  },
                  onStatusChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                      _filterLectures();
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Results Counter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${_filteredLectures.length} Lecture${_filteredLectures.length == 1 ? '' : 's'} Found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_searchQuery.isNotEmpty ||
                        _selectedStatus != 'All') ...[
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedStatus = 'All';
                            _filterLectures();
                          });
                        },
                        child: Text('Clear Filters'.tr()),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // Lectures List
        _filteredLectures.isEmpty
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No lectures match your filters.'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_searchQuery.isNotEmpty ||
                          _selectedStatus != 'All') ...[
                        SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedStatus = 'All';
                              _filterLectures();
                            });
                          },
                          child: Text('Clear Filters'.tr()),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: LectureCard(lecture: _filteredLectures[index]),
                  ),
                  childCount: _filteredLectures.length,
                ),
              ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
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
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            FadePageRoute(
              page: CoursesPage(
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
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Dashboard'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library_outlined),
          label: 'Courses'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note_outlined),
          activeIcon: Icon(Icons.event_note),
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
