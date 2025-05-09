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

  void _handleLogout(BuildContext context) {
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
              print("LogoutButton: Logout confirmed");

              // إغلاق مربع الحوار
              Navigator.pop(context);

              // مسح البيانات المحلية
              try {
                print("LogoutButton: Clearing local data");
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                print("LogoutButton: Local data cleared successfully");
              } catch (e) {
                print("LogoutButton: Error clearing data - $e");
              }

              // الانتقال إلى صفحة تسجيل الدخول
              print("LogoutButton: Navigating to login page");
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => LoginPage(
                    toggleTheme: toggleTheme,
                    isDarkMode: isDarkMode,
                  ),
                ),
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
}
