// lib/features/user_features/vocabulary_practice/models/word_list_response_dto.dart
import 'word_item_dto.dart';

class WordListResponseDto {
  final List<WordItemDto>? data;
  final int statusCode;
  final bool isSuccess;
  final List<String>? errors;

  WordListResponseDto({
    this.data,
    required this.statusCode,
    required this.isSuccess,
    this.errors,
  });

  factory WordListResponseDto.fromJson(Map<String, dynamic> json) {
    return WordListResponseDto(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => WordItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [], // data null ise boş liste
      statusCode: json['statusCode'] as int,
      isSuccess: json['isSuccess'] as bool,
      errors:
          (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  factory WordListResponseDto.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return WordListResponseDto(
      isSuccess: false,
      errors: errors ?? [message],
      statusCode: statusCode ?? 500,
      data: null,
    );
  }
}
