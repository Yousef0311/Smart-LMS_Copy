
import 'package:flutter/material.dart';

class LectureCard extends StatelessWidget {
  final Map<String, dynamic> lecture;

  const LectureCard({super.key, required this.lecture});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color getStatusColor(String status) {
      switch (status) {
        case 'attended':
          return Colors.green.withOpacity(0.2);
        case 'missed':
          return Colors.red.withOpacity(0.2);
        default:
          return theme.cardColor;
      }
    }

    Icon getStatusIcon(String status) {
      switch (status) {
        case 'attended':
          return const Icon(Icons.check_circle, color: Colors.green, size: 16);
        case 'missed':
          return const Icon(Icons.cancel, color: Colors.red, size: 16);
        default:
          return const Icon(Icons.schedule, color: Colors.grey, size: 16);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: getStatusColor(lecture['status']),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              getStatusIcon(lecture['status']),
              const SizedBox(width: 8),
              Text(
                lecture['date'],
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                lecture['time'],
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lecture['course'],
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Lecture ${lecture['number']}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
