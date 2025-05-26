class Course {
  // الحقول القديمة (للتوافق مع الداش بورد)
  final String title;
  final String imagePath;
  final String description;
  final double rating;
  final String duration;
  final String level;
  final int students;
  final double price;
  final String overview;

  // الحقول الجديدة من API (اختيارية)
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
    // الحقول القديمة (مطلوبة)
    required this.title,
    required this.imagePath,
    required this.description,
    required this.rating,
    required this.duration,
    required this.level,
    required this.students,
    required this.price,
    required this.overview,

    // الحقول الجديدة (اختيارية)
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
      // تحويل من API format إلى الحقول القديمة
      title: json['name'] ?? '',
      imagePath: json['course_image'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      duration: '${json['course_hours'] ?? 0}h',
      level: json['course_level'] ?? '',
      students: json['students_count'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      overview: json['bio'] ?? json['description'] ?? '',

      // الحقول الجديدة من API
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

  // Constructor للبيانات المحلية (Dashboard)
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

  // دوال مساعدة

  // السعر بعد الخصم
  double get finalPrice {
    if (discount != null && discount! > 0) {
      return price - (price * discount! / 100);
    }
    return price;
  }

  // هل مجاني
  bool get isFree {
    return finalPrice == 0;
  }

  // هل عليه خصم
  bool get hasDiscount {
    return discount != null && discount! > 0;
  }

  // حالة الاشتراك
  String get enrollmentStatus {
    return pivot?['status'] ?? 'not_enrolled';
  }

  // هل مشترك في الكورس
  bool get isEnrolled {
    return pivot != null;
  }

  // دالة لإصلاح رابط الصورة
  String get fixedImageUrl {
    if (courseImage != null && courseImage!.isNotEmpty) {
      // إصلاح localhost إلى 127.0.0.1:8000
      String fixedUrl = courseImage!
          .replaceAll('http://localhost', 'http://127.0.0.1:8000')
          .replaceAll('https://localhost', 'http://127.0.0.1:8000');

      print('🖼️ Fixed image URL: $fixedUrl');
      return fixedUrl;
    }

    // إذا مفيش صورة من API، استخدم الصورة المحلية
    return imagePath;
  }

  // الصورة المناسبة للعرض - الوحيدة الموجودة
  String get displayImage {
    return fixedImageUrl;
  }

  // المدة المناسبة
  String get displayDuration {
    if (courseHours != null) {
      return '${courseHours}h';
    }
    return duration;
  }

  // العنوان المناسب
  String get displayTitle {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    return title;
  }

  // الوصف المناسب
  String get displayDescription {
    if (bio != null && bio!.isNotEmpty) {
      return bio!;
    }
    return description;
  }

  // المستوى المناسب
  String get displayLevel {
    if (courseLevel != null && courseLevel!.isNotEmpty) {
      return courseLevel!;
    }
    return level;
  }

  // عدد الطلاب المناسب
  int get displayStudents {
    if (studentsCount != null) {
      return studentsCount!;
    }
    return students;
  }
}
