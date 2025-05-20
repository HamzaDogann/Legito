// lib/features/user_features/reading_session/models/reading_session_result_dto.dart
class ReadingSessionResultDataDto {
  final int wordCount;
  final String duration; // API'den gelen format "00:00:30"
  final int speed; // Kelime/Dakika

  ReadingSessionResultDataDto({
    required this.wordCount,
    required this.duration,
    required this.speed,
  });

  factory ReadingSessionResultDataDto.fromJson(Map<String, dynamic> json) {
    return ReadingSessionResultDataDto(
      wordCount: json['wordCount'] as int? ?? 0,
      duration: json['duration'] as String? ?? "00:00:00",
      speed: json['speed'] as int? ?? 0,
    );
  }
}

class ReadingSessionResultApiResponseDto {
  final ReadingSessionResultDataDto? data;
  final int statusCode;
  final bool isSuccess;
  final List<String>? errors;

  ReadingSessionResultApiResponseDto({
    this.data,
    required this.statusCode,
    required this.isSuccess,
    this.errors,
  });

  factory ReadingSessionResultApiResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReadingSessionResultApiResponseDto(
      data:
          json['data'] != null
              ? ReadingSessionResultDataDto.fromJson(
                json['data'] as Map<String, dynamic>,
              )
              : null,
      statusCode: json['statusCode'] as int,
      isSuccess: json['isSuccess'] as bool,
      errors:
          (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  factory ReadingSessionResultApiResponseDto.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return ReadingSessionResultApiResponseDto(
      isSuccess: false,
      errors: errors ?? [message],
      statusCode: statusCode ?? 500,
      data: null,
    );
  }
}
