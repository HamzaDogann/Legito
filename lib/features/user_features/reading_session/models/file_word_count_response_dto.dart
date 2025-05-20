// lib/features/user_features/reading_session/models/file_word_count_response_dto.dart
class FileWordCountDataDto {
  final int wordCount;

  FileWordCountDataDto({required this.wordCount});

  factory FileWordCountDataDto.fromJson(Map<String, dynamic> json) {
    return FileWordCountDataDto(wordCount: json['wordCount'] as int? ?? 0);
  }
}

class FileWordCountApiResponseDto {
  final FileWordCountDataDto? data;
  final int statusCode;
  final bool isSuccess;
  final List<String>? errors;

  FileWordCountApiResponseDto({
    this.data,
    required this.statusCode,
    required this.isSuccess,
    this.errors,
  });

  factory FileWordCountApiResponseDto.fromJson(Map<String, dynamic> json) {
    return FileWordCountApiResponseDto(
      data:
          json['data'] != null
              ? FileWordCountDataDto.fromJson(
                json['data'] as Map<String, dynamic>,
              )
              : null,
      statusCode: json['statusCode'] as int,
      isSuccess: json['isSuccess'] as bool,
      errors:
          (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  factory FileWordCountApiResponseDto.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return FileWordCountApiResponseDto(
      isSuccess: false,
      errors: errors ?? [message],
      statusCode: statusCode ?? 500,
      data: null,
    );
  }
}
