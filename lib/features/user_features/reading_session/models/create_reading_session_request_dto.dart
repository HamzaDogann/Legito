// lib/features/user_features/reading_session/models/create_reading_session_request_dto.dart
class CreateReadingSessionRequestDto {
  final int wordCount;
  final String duration; // "HH:mm:ss" veya "mm:ss" formatında süre

  CreateReadingSessionRequestDto({
    required this.wordCount,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {'wordCount': wordCount, 'duration': duration};
  }
}
