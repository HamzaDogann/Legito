// lib/features/course/models/course_item_dto.dart
class CourseItemDto {
  final String id;
  final String title;
  final String? thumbnail; // Null gelebilir veya her zaman olmayabilir
  final String? video; // Bazen liste görünümünde video URL'si de gelebilir
  final int viewCount;
  final DateTime createdDate;

  CourseItemDto({
    required this.id,
    required this.title,
    this.thumbnail,
    this.video,
    required this.viewCount,
    required this.createdDate,
  });

  factory CourseItemDto.fromJson(Map<String, dynamic> json) {
    return CourseItemDto(
      id: json['id'] as String,
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String?,
      video: json['video'] as String?, // API yanıtında varsa
      viewCount: json['viewCount'] as int? ?? 0, // null ise 0
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }
}
