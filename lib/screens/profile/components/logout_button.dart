// lib/screens/profile/components/logout_button.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lms/screens/login_page.dart';

class LogoutButton extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const LogoutButton({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.white,
        ),
        label: Text(
          'Log out'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    print("LogoutButton: Logout initiated");

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
              // Close the dialog first for better UX
              Navigator.pop(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // مسح البيانات المحلية مباشرة بدلاً من انتظار استجابة API
                print("LogoutButton: Clearing local data");
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                print("LogoutButton: Local data cleared successfully");

                // لن نستخدم استدعاء واجهة برمجة التطبيقات للخروج هنا
                // بل نكتفي بمسح البيانات المحلية
              } catch (e) {
                print("LogoutButton: Error during logout - $e");
              } finally {
                // Close loading dialog if it's still showing
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                // Navigate to login page and clear navigation stack
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      toggleTheme: toggleTheme,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  (route) => false, // إزالة كل الشاشات السابقة
                );
              }
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
}
