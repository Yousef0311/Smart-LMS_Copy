
import 'package:flutter/material.dart';

class ProfileSaveButton extends StatelessWidget {
  final VoidCallback onSave;
  const ProfileSaveButton({required this.onSave, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onSave,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
      child: Text('Save'),
    );
  }
}
