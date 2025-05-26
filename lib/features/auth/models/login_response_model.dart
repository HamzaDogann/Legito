// lib/features/auth/models/login_response_model.dart

class LoginResponseModel {
  final bool isSuccess;
  final String? message;
  final LoginData? data;
  final List<String>? errors; // Keep this to store the list of errors
  final int? statusCode;

  LoginResponseModel({
    required this.isSuccess,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    bool success =
        json['isSuccess'] ??
        (json['data'] != null &&
            json['data']['accessToken'] != null &&
            (json['data']['accessToken'] as String).isNotEmpty &&
            (json['statusCode'] == 200 || json['statusCode'] == null));

    List<String>? errorsList;
    if (json['errors'] != null) {
      if (json['errors'] is List) {
        errorsList = List<String>.from(
          json['errors'].map((e) => e.toString()),
        ); // Ensure elements are strings
      } else if (json['errors'] is Map) {
        // Handle cases where errors might be a map (e.g., field-specific errors from ASP.NET Identity)
        errorsList = [];
        (json['errors'] as Map).forEach((key, value) {
          if (value is List) {
            errorsList!.addAll(value.map((e) => e.toString()));
          } else {
            errorsList!.add(value.toString());
          }
        });
      } else {
        errorsList = [
          json['errors'].toString(),
        ]; // Fallback if it's a single string
      }
    }

    return LoginResponseModel(
      isSuccess: success,
      message: json['message'] as String?,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      errors: errorsList,
      statusCode: json['statusCode'] as int?,
    );
  }

  factory LoginResponseModel.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return LoginResponseModel(
      isSuccess: false,
      message: message,
      data: null,
      errors: errors,
      statusCode: statusCode,
    );
  }
}

class LoginData {
  final String accessToken;
  final String? refreshToken;

  LoginData({required this.accessToken, this.refreshToken});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    final String token = json['accessToken'] as String? ?? '';
    if (token.isEmpty) {
      print(
        "LoginData.fromJson UYARI: 'accessToken' null veya boş geldi. JSON: $json",
      );
    }
    return LoginData(
      accessToken: token,
      refreshToken: json['refreshToken'] as String?,
    );
  }
}
