// lib/widgets/demo_data_indicator.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DemoDataIndicator extends StatelessWidget {
  final bool isVisible;
  final String message;

  const DemoDataIndicator({
    super.key,
    this.isVisible = false,
    this.message = 'Demo Data - Connect to internet for full experience',
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.tr(),
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.wifi_off,
            color: Colors.orange.shade700,
            size: 16,
          ),
        ],
      ),
    );
  }
}

// Extension لسهولة الاستخدام
extension DemoDataCheck on Map<String, dynamic> {
  bool get isDemoData =>
      this['isDefaultData'] == true || this['isOfflineMode'] == true;

  String get demoMessage {
    if (this['message'] != null) {
      return this['message'] as String;
    }
    return 'Demo Data - Connect to internet for full experience';
  }
}
