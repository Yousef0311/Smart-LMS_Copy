
import 'package:flutter/material.dart';
import 'package:smart_lms/models/course.dart';
import 'package:smart_lms/screens/dashboard/components/course_details_page.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String short;

  const CourseCard({
    super.key,
    required this.title,
    required this.short,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Crear un objeto Course con datos basados en el título
        final Course course = _getCourseData(title);

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CourseDetailsPage(course: course),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
              var scaleTween = Tween<double>(begin: 0.9, end: 1.0);
              return FadeTransition(
                opacity: animation.drive(fadeTween),
                child: ScaleTransition(
                  scale: animation.drive(scaleTween),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(short, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.teal,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para obtener datos del curso basados en el título
  Course _getCourseData(String title) {
    switch (title) {
      case 'Data Science':
        return Course(
            title: 'Data Science',
            imagePath: 'assets/images/machine_course.png',
            description: 'Learn data analysis and visualization',
            rating: 4.8,
            duration: '14h 45m',
            students: 50,
            level: 'Intermediate',
            price: 54.9,
            overview:
                'This comprehensive Data Science course covers statistical analysis, '
                'data visualization, machine learning basics, and practical applications using Python. '
                'Perfect for aspiring data scientists and analysts looking to develop valuable skills '
                'in the field of big data and analytics.');
      case 'UX Design':
        return Course(
            title: 'UX Design',
            imagePath: 'assets/images/web_course.png',
            description: 'Master user experience design principles',
            rating: 4.7,
            duration: '12h 30m',
            students: 45,
            level: 'Beginner to Intermediate',
            price: 49.9,
            overview:
                'Learn the fundamentals of user experience design in this practical course. '
                'From user research and wireframing to prototyping and usability testing, you\'ll '
                'develop the skills needed to create intuitive and engaging digital experiences '
                'that users will love.');
      case 'Flutter':
        return Course(
            title: 'Flutter Development',
            imagePath: 'assets/images/flutter_course.png',
            description: 'Build cross-platform apps with Flutter',
            rating: 4.9,
            duration: '16h 20m',
            students: 65,
            level: 'Intermediate',
            price: 59.9,
            overview:
                'Become proficient in Flutter, Google\'s UI toolkit for building beautiful, '
                'natively compiled applications for mobile, web, and desktop from a single codebase. '
                'Learn Dart programming, widget implementation, state management, and how to create '
                'responsive and attractive user interfaces.');
      case 'AI Basics':
        return Course(
            title: 'AI Basics',
            imagePath: 'assets/images/machine_course.png',
            description: 'Introduction to artificial intelligence',
            rating: 4.6,
            duration: '10h 15m',
            students: 55,
            level: 'Beginner',
            price: 44.9,
            overview:
                'This course provides a solid foundation in artificial intelligence concepts. '
                'You\'ll learn about machine learning algorithms, neural networks, natural language processing, '
                'and computer vision. Ideal for beginners wanting to understand AI fundamentals and applications '
                'in today\'s technology landscape.');
      default:
        // Curso genérico por defecto
        return Course(
            title: title,
            imagePath: 'assets/images/web_course.png',
            description: 'Learn $title fundamentals',
            rating: 4.5,
            duration: '10h 00m',
            students: 30,
            level: 'Beginner',
            price: 39.9,
            overview:
                'A comprehensive introduction to $title with hands-on projects and exercises.');
    }
  }
}
