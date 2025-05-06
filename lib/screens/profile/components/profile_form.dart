import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProfileForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController birthDateController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final Function(BuildContext context) onDatePick;

  const ProfileForm({
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.birthDateController,
    required this.passwordController,
    required this.formKey,
    required this.onDatePick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name'.tr(),
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number'.tr(),
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email'.tr(),
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () => onDatePick(context),
            child: AbsorbPointer(
              child: TextFormField(
                controller: birthDateController,
                decoration: InputDecoration(
                  labelText: 'Birthdate'.tr(),
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Change Password'.tr(),
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
