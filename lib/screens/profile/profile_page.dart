// lib/screens/profile/profile_page.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_lms/screens/courses/courses_page.dart';
import 'package:smart_lms/screens/dashboard/dashboard_screen.dart';
import 'package:smart_lms/screens/lecture/lecture_page.dart';
import 'package:smart_lms/screens/profile/components/change_password_button.dart';
import 'package:smart_lms/screens/profile/components/logout_button.dart';
import 'package:smart_lms/screens/profile/components/profile_form.dart';
import 'package:smart_lms/screens/profile/components/profile_header.dart';
import 'package:smart_lms/screens/profile/components/profile_save_button.dart';
import 'package:smart_lms/screens/profile/controllers/profile_controller.dart';
import 'package:smart_lms/widgets/custom_appbar.dart';
import 'package:smart_lms/widgets/transitions.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const ProfilePage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileController _controller;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadUserProfile();
    // Update UI after data is loaded
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // UI update method
  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        context: context,
        isDarkMode: widget.isDarkMode,
        toggleTheme: widget.toggleTheme,
        showGreeting: false,
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // Profile content builder
  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header with image and name/email
          ProfileHeader(
            imageFile: _controller.profileImage,
            onTapImage: () => _controller.selectImage(context),
            name: _controller.nameController.text,
            email: _controller.emailController.text,
            isLoading: _controller.isSaving,
          ),

          const SizedBox(height: 24),

          // Profile Form
          ProfileForm(
            nameController: _controller.nameController,
            phoneController: _controller.phoneController,
            emailController: _controller.emailController,
            birthDateController: _controller.birthDateController,
            formKey: _controller.formKey,
            onDatePick: (context) {
              _controller.selectDate(context).then((_) => _updateState());
            },
            errorMessage: _controller.errorMessage,
          ),

          const SizedBox(height: 20),

          // Save Button
          ProfileSaveButton(
            onSave: () {
              _controller.handleSave(context).then((_) => _updateState());
            },
            isLoading: _controller.isSaving,
          ),

          const SizedBox(height: 16),

          // Change Password Button
          ChangePasswordButton(),

          // Logout Button
          LogoutButton(
            isDarkMode: widget.isDarkMode,
            toggleTheme: widget.toggleTheme,
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      onTap: (index) {
        if (index == _currentIndex) return;

        setState(() => _currentIndex = index);

        Widget? nextPage;
        if (index == 0) {
          nextPage = DashboardScreen(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          );
        } else if (index == 1) {
          nextPage = CoursesPage(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          );
        } else if (index == 2) {
          nextPage = LecturesPage(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          );
        }

        if (nextPage != null) {
          Navigator.pushReplacement(
            context,
            FadePageRoute(page: nextPage),
          );
        }
      },
      currentIndex: _currentIndex,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Dashboard'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library_outlined),
          activeIcon: Icon(Icons.video_library),
          label: 'Courses'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note_outlined),
          activeIcon: Icon(Icons.event_note),
          label: 'Lectures'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile'.tr(),
        ),
      ],
    );
  }
}
