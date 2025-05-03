import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_lms/screens/login_page.dart';

class SplashScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const SplashScreen({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // استخدام AnimationController واحد لكل الحركات
  late AnimationController _animationController;

  // تعريف الحركات المختلفة
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // تكوين AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // حركة الظهور التدريجي
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // حركة التكبير
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // حركة الانزلاق للأعلى للنص
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // بدء الحركة
    _animationController.forward();

    // الانتقال إلى صفحة تسجيل الدخول بعد فترة
    Timer(const Duration(milliseconds: 2800), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginPage(
            isDarkMode: widget.isDarkMode,
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // استخدام التدرج اللوني المحدد
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4E7E8), Color(0xFF64C7C5)],
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار مع حركة التكبير
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/logo_edited.png',
                  width: 180,
                  height: 180,
                ),
              ),
              const SizedBox(height: 18),

              // النص مع حركة الانزلاق
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // نص Smart LMS
                      const Text(
                        'Smart LMS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D7B7A),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // نص وصفي أصغر
                      const Text(
                        'Learning Management System',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2D7B7A),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
