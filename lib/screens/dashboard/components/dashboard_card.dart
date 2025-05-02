import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title, subtitle, value, status;
  final bool isPerformance;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.status,
    this.isPerformance = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // بدّل الأبيض بكده
          borderRadius: BorderRadius.circular(10),
        ),
        child: isPerformance
            ? Column(
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 3),
                  Text(value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        overflow: TextOverflow.ellipsis,
                      )),
                  Text(status,
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(subtitle, style: TextStyle(color: Colors.grey)),
                  Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(status, style: TextStyle(color: Colors.grey)),
                ],
              ),
      ),
    );
  }
}
