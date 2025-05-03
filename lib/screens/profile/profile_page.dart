import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lms/screens/lecture/lecture_page.dart';
import 'package:smart_lms/screens/login_page.dart';
import 'package:smart_lms/widgets/transitions.dart';

import '../../widgets/custom_appbar.dart';
import '../courses/courses_page.dart';
import '../dashboard/dashboard_screen.dart';
import 'components/logout_button.dart';
import 'components/profile_form.dart';
import 'components/profile_header.dart';
import 'components/profile_save_button.dart';

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
  int _currentIndex = 3;
  File? _profileImage;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Adam Raw ');
  final _emailController = TextEditingController(text: 'alexarawles@gmail.com');
  final _phoneController = TextEditingController(text: '01010111049844');
  final _birthDateController = TextEditingController(text: '26/07/2000');
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // استعادة صورة الملف الشخصي المحفوظة
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');

    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        setState(() {
          _profileImage = file;
        });
      }
    }
  }

  // حفظ صورة الملف الشخصي
  Future<void> _saveProfileImage(File imageFile) async {
    try {
      // نسخ الصورة إلى مجلد التطبيق الدائم
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImagePath = '${directory.path}/$fileName';

      // نسخ الصورة إلى المجلد الدائم
      final savedImage = await imageFile.copy(savedImagePath);

      // حفظ مسار الصورة في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', savedImagePath);

      setState(() {
        _profileImage = savedImage;
      });
    } catch (e) {
      print('خطأ في حفظ الصورة: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 7, 26),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();

    // إظهار خيارات (الكاميرا أو معرض الصور)
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('Choose from gallery'.tr()),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text('Take a photo'.tr()),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      // حفظ الصورة بشكل دائم
      await _saveProfileImage(imageFile);
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // يمكنك هنا حفظ بيانات المستخدم الأخرى مثل الاسم والبريد الإلكتروني إلخ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully'.tr())),
      );
    }
  }

  // دالة تسجيل الخروج
  Future<void> _handleLogout() async {
    // عرض مربع تأكيد قبل تسجيل الخروج
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log out'.tr()),
        content: Text('Are you sure you want to log out?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              // إزالة بيانات الجلسة من التخزين المحلي (اختياري)
              final prefs = await SharedPreferences.getInstance();
              // يمكنك إضافة المزيد من مفاتيح البيانات التي تريد مسحها
              // على سبيل المثال، إزالة رمز الوصول أو بيانات المستخدم
              // await prefs.remove('access_token');

              // إغلاق مربع الحوار
              Navigator.pop(context);

              // الانتقال إلى صفحة تسجيل الدخول
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => LoginPage(
                          toggleTheme: widget.toggleTheme,
                          isDarkMode: widget.isDarkMode,
                        )),
                (route) => false, // إزالة جميع الصفحات السابقة من المكدس
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Log out'.tr().tr()),
          ),
        ],
      ),
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProfileHeader(
              imageFile: _profileImage,
              onTapImage: _selectImage,
              name: _nameController.text,
              email: _emailController.text,
            ),
            const SizedBox(height: 24),
            ProfileForm(
              nameController: _nameController,
              phoneController: _phoneController,
              emailController: _emailController,
              birthDateController: _birthDateController,
              passwordController: _passwordController,
              formKey: _formKey,
              onDatePick: _selectDate,
            ),
            const SizedBox(height: 12),
            ProfileSaveButton(onSave: _handleSave),
            //const SizedBox(height: 16),
            // زر تسجيل الخروج مباشرة بعد زر الحفظ (بدون الخط الفاصل)
            // Divider(
            //   indent: 6,
            //   thickness: 1,
            // ),
            LogoutButton(onLogout: _handleLogout),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
      ),
    );
  }
}
