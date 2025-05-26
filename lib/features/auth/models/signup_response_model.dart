// lib/features/auth/models/signup_response_model.dart
class SignUpResponseModel {
  final bool isSuccess;
  final String? message;
  final List<String>? errors; // Added to store the list of errors
  final int? statusCode; // Added for consistency

  SignUpResponseModel({
    required this.isSuccess,
    this.message,
    this.errors,
    this.statusCode,
  });

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    List<String>? errorsList;
    if (json['errors'] != null) {
      if (json['errors'] is List) {
        errorsList = List<String>.from(json['errors'].map((e) => e.toString()));
      } else if (json['errors'] is Map) {
        errorsList = [];
        (json['errors'] as Map).forEach((key, value) {
          if (value is List) {
            errorsList!.addAll(value.map((e) => e.toString()));
          } else {
            errorsList!.add(value.toString());
          }
        });
      } else {
        errorsList = [json['errors'].toString()];
      }
    }

    return SignUpResponseModel(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] as String?,
      errors: errorsList,
      statusCode: json['statusCode'] as int?,
    );
  }

  factory SignUpResponseModel.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return SignUpResponseModel(
      isSuccess: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }
}
