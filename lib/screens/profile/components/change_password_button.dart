// lib/screens/profile/components/change_password_button.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_lms/services/user_service.dart';

class ChangePasswordButton extends StatelessWidget {
  final UserService _userService = UserService();

  ChangePasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        onPressed: () => _showChangePasswordDialog(context),
        icon: const Icon(Icons.lock_reset),
        label: Text('Change Password'.tr()),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.teal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
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
                // Error message display
                if (passwordError != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      passwordError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // Current password field
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // New password field
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // Confirm new password field
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.tr()),
            ),

            // Change password button or loading indicator
            isChanging
                ? Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.all(16),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      // Validate inputs
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

                      // Show loading state
                      setState(() {
                        isChanging = true;
                        passwordError = null;
                      });

                      try {
                        // Call API to change password
                        await _userService.changePassword(
                          currentPasswordController.text,
                          newPasswordController.text,
                          confirmPasswordController.text,
                        );

                        // Close dialog and show success message
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Password changed successfully'.tr()),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        // Show error message
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

    // Clean up controllers
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}
