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
        case 'upcoming':
          return theme.cardColor;
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
        case 'upcoming':
          return const Icon(Icons.schedule, color: Colors.orange, size: 16);
        default:
          return const Icon(Icons.help_outline, color: Colors.grey, size: 16);
      }
    }

    String getStatusText(String status) {
      switch (status) {
        case 'attended':
          return 'Completed';
        case 'missed':
          return 'Missed';
        case 'upcoming':
          return 'Upcoming';
        default:
          return 'Unknown';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: getStatusColor(lecture['status']),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // يمكن إضافة navigation لصفحة تفاصيل المحاضرة
            print('Tapped on lecture: ${lecture['title']}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row - Date, Status, Duration
                Row(
                  children: [
                    getStatusIcon(lecture['status']),
                    const SizedBox(width: 8),
                    Text(
                      lecture['date'] ?? 'No Date',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${lecture['duration'] ?? 0}min',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Lecture Title
                Text(
                  lecture['title'] ?? 'Unknown Lecture',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Course Name
                Text(
                  lecture['course'] ?? 'Unknown Course',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),

                // Description (if available)
                if (lecture['description'] != null &&
                    lecture['description'].isNotEmpty) ...[
                  Text(
                    lecture['description'],
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],

                // Bottom Row - Lecture Number, Status, Progress
                Row(
                  children: [
                    // Lecture Number
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Lecture ${lecture['number'] ?? lecture['order'] ?? '?'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Type Badge
                    if (lecture['type'] != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              _getTypeColor(lecture['type']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          lecture['type'].toUpperCase(),
                          style: TextStyle(
                            color: _getTypeColor(lecture['type']),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    const Spacer(),

                    // Status and Progress
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          getStatusText(lecture['status']),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getStatusTextColor(lecture['status']),
                          ),
                        ),
                        if (lecture['progress'] != null &&
                            lecture['progress'] > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 60,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: lecture['progress'].clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getStatusTextColor(lecture['status']),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                // Free Badge
                if (lecture['isFree'] == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'FREE',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Colors.blue;
      case 'quiz':
        return Colors.orange;
      case 'assignment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'attended':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'upcoming':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
