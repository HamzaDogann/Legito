// lib/features/user_features/reading_session/models/reading_file_request_dto.dart
class ReadingFileRequestDto {
  final String base64Content;

  ReadingFileRequestDto({required this.base64Content});

  Map<String, dynamic> toJson() {
    return {'base64Content': base64Content};
  }
}
