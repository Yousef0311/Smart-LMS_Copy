// lib/screens/profile/components/profile_form.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProfileForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController birthDateController;
  final GlobalKey<FormState> formKey;
  final Function(BuildContext context) onDatePick;
  final bool readOnly;
  final String? errorMessage;

  const ProfileForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.birthDateController,
    required this.formKey,
    required this.onDatePick,
    this.readOnly = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error message display (if any)
          if (errorMessage != null) ...[
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
                  Icon(Icons.error_outline, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Name field
          TextFormField(
            controller: nameController,
            readOnly: readOnly,
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

          // Phone number field
          TextFormField(
            controller: phoneController,
            readOnly: readOnly,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number'.tr(),
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number'.tr();
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Email field
          TextFormField(
            controller: emailController,
            readOnly: readOnly,
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

          // Birth date field (with date picker)
          GestureDetector(
            onTap: !readOnly ? () => onDatePick(context) : null,
            child: AbsorbPointer(
              child: TextFormField(
                controller: birthDateController,
                decoration: InputDecoration(
                  labelText: 'Birthdate'.tr(),
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                  suffixIcon:
                      !readOnly ? Icon(Icons.calendar_today, size: 20) : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your birthdate'.tr();
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
