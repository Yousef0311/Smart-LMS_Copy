// lib/screens/profile/controllers/profile_controller.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lms/services/user_service.dart';

class ProfileController {
  // Text controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // User service for API calls
  final UserService _userService = UserService();

  // State variables
  File? profileImage;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  // Constructor
  ProfileController() {
    loadUserProfile();
  }

  // Dispose method to clean up resources
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
  }

  // Load user profile data
  Future<void> loadUserProfile() async {
    isLoading = true;
    errorMessage = null;

    try {
      // Try to get user data from API
      final profileData = await _userService.getProfile();

      if (profileData['user'] != null) {
        final user = profileData['user'];

        // Fill in form fields
        nameController.text = user['name'] ?? '';
        emailController.text = user['email'] ?? '';
        phoneController.text = user['phone'] ?? '';

        // Format birthdate from YYYY-MM-DD to DD/MM/YYYY for display
        if (user['date_of_birth'] != null) {
          final dateFormat = DateFormat('yyyy-MM-dd');
          final displayFormat = DateFormat('dd/MM/yyyy');
          try {
            final date = dateFormat.parse(user['date_of_birth']);
            birthDateController.text = displayFormat.format(date);
          } catch (e) {
            birthDateController.text = user['date_of_birth'];
          }
        }

        // Load profile image
        await loadProfileImage();
      }
    } catch (e) {
      print('Error loading profile: $e');
      errorMessage = 'Failed to load profile data. Please try again.';

      // Try to load locally saved data as fallback
      await loadLocalUserData();
    } finally {
      isLoading = false;
    }
  }

  // Load locally saved user data
  Future<void> loadLocalUserData() async {
    final userData = await _userService.getLocalUserData();
    if (userData != null && userData['user'] != null) {
      final user = userData['user'];

      nameController.text = user['name'] ?? '';
      emailController.text = user['email'] ?? '';
      phoneController.text = user['phone'] ?? '';

      if (user['date_of_birth'] != null) {
        final dateFormat = DateFormat('yyyy-MM-dd');
        final displayFormat = DateFormat('dd/MM/yyyy');
        try {
          final date = dateFormat.parse(user['date_of_birth']);
          birthDateController.text = displayFormat.format(date);
        } catch (e) {
          birthDateController.text = user['date_of_birth'];
        }
      }
    }
  }

  // Load profile image from storage
  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');

    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        profileImage = file;
      }
    }
  }

  // Save profile image to storage
  Future<void> saveProfileImage(File imageFile) async {
    try {
      // Copy image to app's permanent directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImagePath = '${directory.path}/$fileName';

      // Copy image to permanent directory
      final savedImage = await imageFile.copy(savedImagePath);

      // Save image path in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', savedImagePath);

      profileImage = savedImage;
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  // Select date from date picker
  Future<void> selectDate(BuildContext context) async {
    DateTime initialDate;

    try {
      // Parse existing date or use default
      initialDate = birthDateController.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(birthDateController.text)
          : DateTime(1990);
    } catch (e) {
      initialDate = DateTime(1990);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  // Select image from gallery or camera
  Future<void> selectImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    // Show options bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Get image from camera or gallery
  Future<void> getImage(ImageSource source) async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      // Save image permanently
      await saveProfileImage(imageFile);
    }
  }

  // Save profile data
  Future<void> handleSave(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isSaving = true;
      errorMessage = null;

      try {
        // Prepare update data
        final Map<String, dynamic> profileData = {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
        };

        // Convert birthdate from DD/MM/YYYY to YYYY-MM-DD for API
        if (birthDateController.text.isNotEmpty) {
          try {
            final date =
                DateFormat('dd/MM/yyyy').parse(birthDateController.text);
            profileData['date_of_birth'] =
                DateFormat('yyyy-MM-dd').format(date);
          } catch (e) {
            profileData['date_of_birth'] = birthDateController.text;
          }
        }

        // Update profile
        final response = await _userService.updateProfile(profileData);

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error updating profile: $e');
        errorMessage = 'Failed to update profile: ${e.toString()}';
      } finally {
        isSaving = false;
      }
    }
  }
}
