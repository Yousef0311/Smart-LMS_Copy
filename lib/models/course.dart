// lib/models/course.dart
import 'package:smart_lms/config/app_config.dart';

class Course {
  // باقي الحقول زي ما هي...
  final String title;
  final String imagePath;
  final String description;
  final double rating;
  final String duration;
  final String level;
  final int students;
  final double price;
  final String overview;

  // الحقول الجديدة من API
  final int? id;
  final String? name;
  final int? majorId;
  final double? discount;
  final String? bio;
  final String? courseImage;
  final int? courseHours;
  final int? lessonsNumber;
  final String? courseLevel;
  final int? status;
  final int? instructorId;
  final int? studentsCount;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? pivot;

  Course({
    required this.title,
    required this.imagePath,
    required this.description,
    required this.rating,
    required this.duration,
    required this.level,
    required this.students,
    required this.price,
    required this.overview,
    this.id,
    this.name,
    this.majorId,
    this.discount,
    this.bio,
    this.courseImage,
    this.courseHours,
    this.lessonsNumber,
    this.courseLevel,
    this.status,
    this.instructorId,
    this.studentsCount,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  // Constructor للبيانات من API
  factory Course.fromApi(Map<String, dynamic> json) {
    return Course(
      title: json['name'] ?? '',
      imagePath: json['course_image'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      duration: '${json['course_hours'] ?? 0}h',
      level: json['course_level'] ?? '',
      students: json['students_count'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      overview: json['bio'] ?? json['description'] ?? '',
      id: json['id'],
      name: json['name'],
      majorId: json['major_id'],
      discount: (json['discount'] ?? 0).toDouble(),
      bio: json['bio'],
      courseImage: json['course_image'],
      courseHours: json['course_hours'],
      lessonsNumber: json['lessons_number'],
      courseLevel: json['course_level'],
      status: json['status'],
      instructorId: json['instructor_id'],
      studentsCount: json['students_count'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      pivot: json['pivot'],
    );
  }

  // Constructor للبيانات المحلية
  factory Course.local({
    required String title,
    required String imagePath,
    required String description,
    required double rating,
    required String duration,
    required String level,
    required int students,
    required double price,
    required String overview,
  }) {
    return Course(
      title: title,
      imagePath: imagePath,
      description: description,
      rating: rating,
      duration: duration,
      level: level,
      students: students,
      price: price,
      overview: overview,
    );
  }

  // دوال مساعدة
  double get finalPrice {
    if (discount != null && discount! > 0) {
      return price - (price * discount! / 100);
    }
    return price;
  }

  bool get isFree => finalPrice == 0;
  bool get hasDiscount => discount != null && discount! > 0;

  String get enrollmentStatus => pivot?['status'] ?? 'not_enrolled';
  bool get isEnrolled => pivot != null;

  // 🔥 الحل الجديد لتصحيح روابط الصور باستخدام AppConfig
  String get fixedImageUrl {
    // استخدام دالة AppConfig لإصلاح الروابط
    if (courseImage != null && courseImage!.isNotEmpty) {
      return AppConfig.fixImageUrl(courseImage);
    }

    // إذا مفيش courseImage، استخدم imagePath المحلي
    return imagePath;
  }

  // الصورة المناسبة للعرض
  String get displayImage {
    final fixed = fixedImageUrl;
    print('🖼️ Display image for ${displayTitle}: $fixed');
    return fixed;
  }

  // باقي الـ getters
  String get displayDuration {
    if (courseHours != null) {
      return '${courseHours}h';
    }
    return duration;
  }

  String get displayTitle {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    return title;
  }

  String get displayDescription {
    if (bio != null && bio!.isNotEmpty) {
      return bio!;
    }
    return description;
  }

  String get displayLevel {
    if (courseLevel != null && courseLevel!.isNotEmpty) {
      return courseLevel!;
    }
    return level;
  }

  int get displayStudents {
    if (studentsCount != null) {
      return studentsCount!;
    }
    return students;
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imagePath': imagePath,
      'description': description,
      'rating': rating,
      'duration': duration,
      'level': level,
      'students': students,
      'price': price,
      'overview': overview,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (majorId != null) 'major_id': majorId,
      if (discount != null) 'discount': discount,
      if (bio != null) 'bio': bio,
      if (courseImage != null) 'course_image': courseImage,
      if (courseHours != null) 'course_hours': courseHours,
      if (lessonsNumber != null) 'lessons_number': lessonsNumber,
      if (courseLevel != null) 'course_level': courseLevel,
      if (status != null) 'status': status,
      if (instructorId != null) 'instructor_id': instructorId,
      if (studentsCount != null) 'students_count': studentsCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (pivot != null) 'pivot': pivot,
    };
  }
}
