// lib/features/course/models/create_course_request_dto.dart
class CreateCourseRequestDto {
  final String title;
  final String video; // Video URL'si
  final String? description;
  final String? base64Image; // Kapak resmi için base64 string, opsiyonel

  CreateCourseRequestDto({
    required this.title,
    required this.video,
    this.description,
    this.base64Image,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'title': title, 'video': video};
    if (description != null && description!.isNotEmpty) {
      map['description'] = description;
    }
    if (base64Image != null && base64Image!.isNotEmpty) {
      map['base64Image'] = base64Image;
    }
    return map;
  }
}
