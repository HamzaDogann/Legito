// lib/features/mentor_features/tips_mentor/models/create_tip_response_dto.dart
import 'tip_response_dto.dart'; // TipResponseDto'yu import et

class CreateUpdateTipApiResponseDto {
  final bool isSuccess;
  final String? message;
  final TipResponseDto? data; // Oluşturulan veya güncellenen ipucu
  final List<String>? errors;
  final int? statusCode;

  CreateUpdateTipApiResponseDto({
    required this.isSuccess,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory CreateUpdateTipApiResponseDto.fromJson(Map<String, dynamic> json) {
    return CreateUpdateTipApiResponseDto(
      isSuccess:
          json['isSuccess'] ??
          (json['data'] != null &&
              (json['statusCode'] == 201 || json['statusCode'] == 200)),
      message: json['message'] as String?,
      data: json['data'] != null ? TipResponseDto.fromJson(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : [],
      statusCode: json['statusCode'] as int?,
    );
  }

  factory CreateUpdateTipApiResponseDto.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return CreateUpdateTipApiResponseDto(
      isSuccess: false,
      message: message,
      data: null,
      errors: errors,
      statusCode: statusCode,
    );
  }
}
