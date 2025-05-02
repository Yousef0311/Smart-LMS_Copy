
import 'package:flutter/material.dart';
import 'package:smart_lms/screens/courses/courses_page.dart';
import 'package:smart_lms/screens/dashboard/dashboard_screen.dart';
import 'package:smart_lms/screens/lecture/components/course_filter_tabs.dart';
import 'package:smart_lms/screens/lecture/components/lecture_card.dart';
import 'package:smart_lms/screens/lecture/components/lectures_data.dart';
import 'package:smart_lms/screens/profile/profile_page.dart';
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

  final List<String> statusOptions = ['All', 'Attended', 'Missed', 'Upcoming'];

  Map<String, double> _calculateProgressPerCourse() {
    Map<String, int> totalLectures = {};
    Map<String, int> attendedLectures = {};

    for (var lecture in lectures) {
      String course = lecture['course'];
      totalLectures[course] = (totalLectures[course] ?? 0) + 1;
      if (lecture['status'] == 'attended') {
        attendedLectures[course] = (attendedLectures[course] ?? 0) + 1;
      }
    }

    Map<String, double> progressMap = {};
    totalLectures.forEach((course, total) {
      int attended = attendedLectures[course] ?? 0;
      progressMap[course] = attended / total;
    });

    return progressMap;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredLectures = lectures.where((lecture) {
      final matchesCourse = lecture['course'] == courses[_selectedCourseIndex];
      final matchesSearch =
          lecture['course'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'All' ||
          lecture['status'] == _selectedStatus.toLowerCase();
      return matchesCourse && matchesSearch && matchesStatus;
    }).toList();

    final progressMap = _calculateProgressPerCourse();
    final currentCourse = courses[_selectedCourseIndex];
    final currentProgress = progressMap[currentCourse] ?? 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppBar(
        context: context,
        isDarkMode: widget.isDarkMode,
        toggleTheme: widget.toggleTheme,
        showGreeting: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                CourseFilterTabs(
                  courses: courses,
                  selectedIndex: _selectedCourseIndex,
                  onTap: (index) =>
                      setState(() => _selectedCourseIndex = index),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentCourse,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CourseProgress(
                        progress: currentProgress,
                        attendedText:
                            'Attended ${(currentProgress * (lectures.where((lecture) => lecture['course'] == currentCourse).length)).toStringAsFixed(0)} of ${lectures.where((lecture) => lecture['course'] == currentCourse).length} lectures',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilterBar(
                    selectedStatus: _selectedStatus,
                    statusOptions: statusOptions,
                    onSearchChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onStatusChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${filteredLectures.length} Lecture${filteredLectures.length == 1 ? '' : 's'} Found',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          filteredLectures.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No lectures match your filters.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: LectureCard(lecture: filteredLectures[index]),
                    ),
                    childCount: filteredLectures.length,
                  ),
                ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
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
