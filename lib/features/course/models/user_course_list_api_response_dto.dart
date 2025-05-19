// lib/features/course/models/user_course_list_api_response_dto.dart
import 'course_item_dto.dart';

class UserCourseListApiResponseDto {
  final List<CourseItemDto>? data;
  final int statusCode;
  final bool isSuccess;
  final List<String>? errors;

  UserCourseListApiResponseDto({
    this.data,
    required this.statusCode,
    required this.isSuccess,
    this.errors,
  });

  factory UserCourseListApiResponseDto.fromJson(Map<String, dynamic> json) {
    return UserCourseListApiResponseDto(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => CourseItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statusCode: json['statusCode'] as int,
      isSuccess: json['isSuccess'] as bool,
      errors:
          (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }
  factory UserCourseListApiResponseDto.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return UserCourseListApiResponseDto(
      isSuccess: false,
      errors: errors ?? [message],
      statusCode: statusCode ?? 500,
      data: null,
    );
  }
}
