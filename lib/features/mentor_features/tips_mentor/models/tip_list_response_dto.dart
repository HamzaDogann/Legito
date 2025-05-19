// lib/features/mentor_features/tips_mentor/models/tip_list_response_dto.dart
import 'tip_response_dto.dart';

// /Tip/GetUser yanıtı için
class TipListResponseDto {
  final bool isSuccess;
  final String? message; // API'nizden message gelmeyebilir, logunuzda yoktu.
  final List<TipResponseDto>? data;
  final List<String>? errors;
  final int? statusCode;

  TipListResponseDto({
    required this.isSuccess,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory TipListResponseDto.fromJson(Map<String, dynamic> json) {
    return TipListResponseDto(
      isSuccess:
          json['isSuccess'] ??
          (json['data'] != null &&
              (json['statusCode'] == 200 || json['statusCode'] == null)),
      message: json['message'] as String?, // Olmadığı için null kalacak
      data:
          json['data'] != null
              ? List<TipResponseDto>.from(
                (json['data'] as List<dynamic>).map(
                  (x) => TipResponseDto.fromJson(x),
                ),
              )
              : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : [],
      statusCode: json['statusCode'] as int?,
    );
  }

  factory TipListResponseDto.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return TipListResponseDto(
      isSuccess: false,
      message: message,
      data: null,
      errors: errors,
      statusCode: statusCode,
    );
  }
}
