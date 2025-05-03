import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_lms/screens/login_page.dart';

import '../widgets/input.dart';
import 'dashboard/dashboard_screen.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const RegisterPage(
      {super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تجاوز كامل للثيم للصفحة
    return Theme(
      // إنشاء ثيم خاص بصفحة التسجيل مستقل عن ثيم التطبيق
      data: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black54,
          ),
        ),
      ),
      child: Scaffold(
        // إلغاء تأثير لون الخلفية من الثيم
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFD4E7E8), Color(0xFF64C7C5)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Image.asset('assets/images/logo_edited.png',
                          height: 110),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Learning Management System',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Input(
                      hint: 'Full Name',
                      icon: Icons.person,
                      keyboardType: TextInputType.name,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
                    Input(
                      hint: 'Email',
                      icon: Icons.mail,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),
                    Input(
                      hint: 'Password',
                      icon: Icons.lock,
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 16),
                    Input(
                      hint: 'Confirm Password',
                      icon: Icons.lock,
                      isPassword: true,
                      controller: _confirmPasswordController,
                    ),
                    const SizedBox(height: 24),
                    // زر التسجيل مع تحسينات بصرية
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DashboardScreen(
                                toggleTheme: widget.toggleTheme,
                                isDarkMode: widget.isDarkMode,
                              ),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 24),
                    // const Text(
                    //   'Or register with',
                    //   style: TextStyle(color: Colors.black54),
                    // ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                            FontAwesomeIcons.google, Colors.deepOrangeAccent),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                            FontAwesomeIcons.facebook, Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage(
                                        toggleTheme: widget.toggleTheme,
                                        isDarkMode: widget.isDarkMode,
                                      )),
                            );
                          },
                          child: const Text(
                            'Login Now',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 95,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: FaIcon(icon, color: color, size: 30),
        onPressed: () {
          debugPrint('$icon clicked');
        },
      ),
    );
  }
}
