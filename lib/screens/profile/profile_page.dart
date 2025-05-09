import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lms/screens/lecture/lecture_page.dart';
import 'package:smart_lms/screens/login_page.dart';
import 'package:smart_lms/services/user_service.dart';
import 'package:smart_lms/widgets/transitions.dart';

import '../../widgets/custom_appbar.dart';
import '../courses/courses_page.dart';
import '../dashboard/dashboard_screen.dart';
import 'components/logout_button.dart';

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
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  final UserService _userService = UserService();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // تحميل بيانات المستخدم من API
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // محاولة الحصول على بيانات المستخدم
      final profileData = await _userService.getProfile();
      print('Profile data loaded: $profileData'); // للتصحيح

      if (profileData['user'] != null) {
        final user = profileData['user'];

        setState(() {
          _nameController.text = user['name'] ?? '';
          _emailController.text = user['email'] ?? '';
          _phoneController.text = user['phone'] ?? '';

          // تنسيق تاريخ الميلاد من YYYY-MM-DD إلى DD/MM/YYYY للعرض
          if (user['date_of_birth'] != null) {
            final dateFormat = DateFormat('yyyy-MM-dd');
            final displayFormat = DateFormat('dd/MM/yyyy');
            try {
              final date = dateFormat.parse(user['date_of_birth']);
              _birthDateController.text = displayFormat.format(date);
            } catch (e) {
              _birthDateController.text = user['date_of_birth'];
            }
          }
        });

        // تحميل صورة الملف الشخصي
        await _loadProfileImage();
      }
    } catch (e) {
      print('Error loading profile: $e'); // للتصحيح
      setState(() {
        _errorMessage = 'Failed to load profile data. Please try again.';
      });

      // استخدام البيانات المحفوظة محليًا كبديل
      await _loadLocalUserData();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // تحميل بيانات المستخدم المحفوظة محليًا
  Future<void> _loadLocalUserData() async {
    final userData = await _userService.getLocalUserData();
    if (userData != null && userData['user'] != null) {
      final user = userData['user'];

      setState(() {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phone'] ?? '';

        if (user['date_of_birth'] != null) {
          final dateFormat = DateFormat('yyyy-MM-dd');
          final displayFormat = DateFormat('dd/MM/yyyy');
          try {
            final date = dateFormat.parse(user['date_of_birth']);
            _birthDateController.text = displayFormat.format(date);
          } catch (e) {
            _birthDateController.text = user['date_of_birth'];
          }
        }
      });
    }
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
    final DateTime initialDate = _birthDateController.text.isNotEmpty
        ? DateFormat('dd/MM/yyyy').parse(_birthDateController.text)
        : DateTime(1990);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

  // تحديث بيانات المستخدم
  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });

      try {
        // تجهيز بيانات التحديث
        final Map<String, dynamic> profileData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
        };

        // تحويل تاريخ الميلاد من DD/MM/YYYY إلى YYYY-MM-DD للـ API
        if (_birthDateController.text.isNotEmpty) {
          try {
            final date =
                DateFormat('dd/MM/yyyy').parse(_birthDateController.text);
            profileData['date_of_birth'] =
                DateFormat('yyyy-MM-dd').format(date);
          } catch (e) {
            profileData['date_of_birth'] = _birthDateController.text;
          }
        }

        // للتصحيح
        print('Sending profile data: $profileData');

        // تحديث البروفايل
        final response = await _userService.updateProfile(profileData);

        // للتصحيح
        print('Profile update response: $response');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully'.tr())),
        );
      } catch (e) {
        print('Error updating profile: $e'); // للتصحيح
        setState(() {
          _errorMessage = 'Failed to update profile: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // دالة لفتح حوار تغيير كلمة المرور
  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool isChanging = false;
    String? passwordError;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Change Password'.tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (passwordError != null)
                  Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      passwordError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                // كلمة المرور الحالية
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),

                // كلمة المرور الجديدة
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),

                // تأكيد كلمة المرور الجديدة
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.tr()),
            ),
            isChanging
                ? Container(
                    width: 24,
                    height: 24,
                    margin: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      // التحقق من تطابق كلمات المرور
                      if (newPasswordController.text.isEmpty ||
                          currentPasswordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty) {
                        setState(() {
                          passwordError = 'Please enter all passwords'.tr();
                        });
                        return;
                      }

                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        setState(() {
                          passwordError = 'New passwords do not match'.tr();
                        });
                        return;
                      }

                      setState(() {
                        isChanging = true;
                        passwordError = null;
                      });

                      try {
                        // محاولة تغيير كلمة المرور
                        print('Trying to change password');
                        await _userService.changePassword(
                            currentPasswordController.text,
                            newPasswordController.text,
                            confirmPasswordController.text);

                        // إغلاق الحوار وعرض رسالة نجاح
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Password changed successfully'.tr())),
                        );
                      } catch (e) {
                        print('Error changing password: $e');
                        setState(() {
                          isChanging = false;
                          passwordError = e.toString();
                          if (passwordError!.contains('Exception:')) {
                            passwordError =
                                passwordError!.split('Exception:')[1].trim();
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Change Password'.tr()),
                  ),
          ],
        ),
      ),
    );
  }

  // دالة تسجيل الخروج
  Future<void> _handleLogout() async {
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
              // إغلاق مربع الحوار
              Navigator.pop(context);

              try {
                // محاولة تسجيل الخروج باستخدام API الصحيح
                print('Starting logout process');
                await _userService.logout();
                print('Logout successful');
              } catch (e) {
                // إذا فشل API، نمسح البيانات المحلية مباشرة
                print('Logout API error, clearing data locally: $e');
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
              }

              // الانتقال إلى صفحة تسجيل الدخول في جميع الحالات
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => LoginPage(
                          toggleTheme: widget.toggleTheme,
                          isDarkMode: widget.isDarkMode,
                        )),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Log out'.tr()),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // رأس الملف الشخصي
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _selectImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!) as ImageProvider
                                  : const AssetImage(
                                      'assets/images/profile2.png'),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _nameController.text,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _emailController.text,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // نموذج البيانات
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم المستخدم
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name'.tr(),
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // رقم الهاتف
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number'.tr(),
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),

                        // البريد الإلكتروني
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email'.tr(),
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email'.tr();
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // تاريخ الميلاد
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _birthDateController,
                              decoration: InputDecoration(
                                labelText: 'Birthdate'.tr(),
                                prefixIcon: Icon(Icons.cake),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // زر الحفظ
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Save'.tr(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // زر تغيير كلمة المرور
                  Container(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showChangePasswordDialog,
                      icon: Icon(Icons.lock_reset),
                      label: Text('Change Password'.tr()),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // زر تسجيل الخروج
                  // زر تسجيل الخروج
                  LogoutButton(
                    isDarkMode: widget.isDarkMode,
                    toggleTheme: widget.toggleTheme,
                  ),
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
