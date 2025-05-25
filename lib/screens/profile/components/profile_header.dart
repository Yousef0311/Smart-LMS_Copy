// lib/screens/profile/components/profile_header.dart
import 'dart:io';

import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTapImage;
  final String name;
  final String email;
  final bool isLoading;

  const ProfileHeader({
    super.key,
    this.imageFile,
    required this.onTapImage,
    required this.name,
    required this.email,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Profile Image with Camera Button
            GestureDetector(
              onTap: onTapImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: imageFile != null
                        ? FileImage(imageFile!) as ImageProvider
                        : const AssetImage('assets/images/profile2.png'),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
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

            // Loading indicator overlay (when isLoading is true)
            if (isLoading)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // User Information
        Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          email,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
/*
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/images/profile2.png'),
        ),
        SizedBox(height: 8),
        Text('Adam Raw'.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('alexarawles@gmail.com'.tr(), style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
 */
