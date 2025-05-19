// lib/features/course/models/course_detail_dto.dart

class CourseDetailDto {
  final String id;
  final String title;
  final String video;
  final String? description;
  final int viewCount;
  final int likeCount;
  final DateTime createdDate;

  CourseDetailDto({
    required this.id,
    required this.title,
    required this.video,
    this.description,
    required this.viewCount,
    required this.likeCount,
    required this.createdDate,
  });

  factory CourseDetailDto.fromJson(Map<String, dynamic> json) {
    return CourseDetailDto(
      id: json['id'] as String,
      title: json['title'] as String,
      video: json['video'] as String,
      description: json['description'] as String?,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }
}

class CourseDetailApiResponseDto {
  final CourseDetailDto? data;
  final int statusCode;
  final bool isSuccess;
  final String? message; // <<< EKSİK OLAN ALAN BURAYA EKLENDİ
  final List<String>? errors;

  CourseDetailApiResponseDto({
    this.data,
    required this.statusCode,
    required this.isSuccess,
    this.message, // <<< CONSTRUCTOR'A EKLENDİ
    this.errors,
  });

  factory CourseDetailApiResponseDto.fromJson(Map<String, dynamic> json) {
    return CourseDetailApiResponseDto(
      data:
          json['data'] != null
              ? CourseDetailDto.fromJson(json['data'] as Map<String, dynamic>)
              : null,
      statusCode: json['statusCode'] as int,
      isSuccess: json['isSuccess'] as bool,
      message: json['message'] as String?, // <<< JSON'DAN OKUMA EKLENDİ
      errors:
          (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  factory CourseDetailApiResponseDto.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return CourseDetailApiResponseDto(
      isSuccess: false,
      message: message, // <<< FAILURE CONSTRUCTOR'INA EKLENDİ
      errors: errors,
      statusCode: statusCode ?? 500,
      data: null,
    );
  }
}
