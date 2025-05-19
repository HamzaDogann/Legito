// lib/core/models/general_api_response_model.dart

class GeneralApiResponseModel {
  final bool isSuccess;
  final String? message;
  final dynamic data; // Opsiyonel, bazen Create sonrası ID dönebilir
  final List<String>? errors;
  final int? statusCode;

  GeneralApiResponseModel({
    required this.isSuccess,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory GeneralApiResponseModel.fromJson(Map<String, dynamic> json) {
    return GeneralApiResponseModel(
      isSuccess:
          json['isSuccess'] ??
          (json['statusCode'] == 200 ||
              json['statusCode'] == 201 ||
              json['statusCode'] == 204),
      message: json['message'] as String?,
      data: json['data'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      statusCode: json['statusCode'] as int?,
    );
  }

  factory GeneralApiResponseModel.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
    dynamic data,
  }) {
    return GeneralApiResponseModel(
      isSuccess: false,
      message: message,
      data: data,
      errors: errors,
      statusCode: statusCode,
    );
  }
}
