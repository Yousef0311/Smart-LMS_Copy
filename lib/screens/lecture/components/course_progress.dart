
import 'package:flutter/material.dart';

class CourseProgress extends StatelessWidget {
  final double progress;
  final String attendedText;

  const CourseProgress({
    super.key,
    required this.progress,
    required this.attendedText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          attendedText,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
