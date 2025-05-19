// lib/features/course/models/course_index_response_dto.dart
import 'course_item_dto.dart';

class CourseIndexResponseDataDto {
  final List<CourseItemDto> popularCourses;
  final List<CourseItemDto> lastCreatedCourses;

  CourseIndexResponseDataDto({
    required this.popularCourses,
    required this.lastCreatedCourses,
  });

  factory CourseIndexResponseDataDto.fromJson(Map<String, dynamic> json) {
    return CourseIndexResponseDataDto(
      popularCourses:
          (json['popularCourses'] as List<dynamic>?)
              ?.map((e) => CourseItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastCreatedCourses:
          (json['lastCreatedCourses'] as List<dynamic>?)
              ?.map((e) => CourseItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CourseIndexApiResponseDto {
  final CourseIndexResponseDataDto? data;
  final int statusCode;
  final bool isSuccess;
  final List<String>? errors;

  CourseIndexApiResponseDto({
    this.data,
    required this.statusCode,
    required this.isSuccess,
    this.errors,
  });

  factory CourseIndexApiResponseDto.fromJson(Map<String, dynamic> json) {
    return CourseIndexApiResponseDto(
      data:
          json['data'] != null
              ? CourseIndexResponseDataDto.fromJson(
                json['data'] as Map<String, dynamic>,
              )
              : null,
      statusCode: json['statusCode'] as int,
      isSuccess: json['isSuccess'] as bool,
      errors:
          (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  factory CourseIndexApiResponseDto.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return CourseIndexApiResponseDto(
      isSuccess: false,
      errors: errors ?? [message],
      statusCode: statusCode ?? 500,
      data: null,
    );
  }
}
