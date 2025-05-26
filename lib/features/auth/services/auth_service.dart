// lib/features/auth/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../user_features/models/user_info_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/signup_response_model.dart';

// SignOutResponseModel - ensure it also parses errors list
class SignOutResponseModel {
  final bool isSuccess;
  final String? message;
  final List<String>? errors;
  final int? statusCode;

  SignOutResponseModel({
    required this.isSuccess,
    this.message,
    this.errors,
    this.statusCode,
  });

  factory SignOutResponseModel.fromJson(Map<String, dynamic> json) {
    bool success =
        json['isSuccess'] ??
        (json['statusCode'] == 200 || json['statusCode'] == 204) ||
            (json.isEmpty &&
                (json['statusCode'] == null || json['statusCode'] == 204));

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

    return SignOutResponseModel(
      isSuccess: success,
      message: json['message'] as String?,
      errors: errorsList,
      statusCode: json['statusCode'] as int?,
    );
  }

  factory SignOutResponseModel.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return SignOutResponseModel(
      isSuccess: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }
}

class AuthService {
  // Helper function to parse errors robustly from API response
  List<String>? _parseErrors(Map<String, dynamic> responseData) {
    if (responseData['errors'] == null) return null;

    if (responseData['errors'] is List) {
      return List<String>.from(responseData['errors'].map((e) => e.toString()));
    } else if (responseData['errors'] is Map) {
      List<String> errors = [];
      (responseData['errors'] as Map).forEach((key, value) {
        if (value is List) {
          errors.addAll(value.map((e) => e.toString()));
        } else {
          errors.add(value.toString());
        }
      });
      return errors.isNotEmpty ? errors : null;
    } else if (responseData['errors'] is String) {
      return [responseData['errors'].toString()];
    }
    return null; // Should not happen if 'errors' is present and not null
  }

  Future<LoginResponseModel> signInWithEmail(
    String email,
    String password,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.signInEmailEndpoint,
    );
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 200 &&
          (responseData['isSuccess'] == true ||
              responseData['data']?['accessToken'] != null)) {
        return LoginResponseModel.fromJson(responseData);
      } else {
        String errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            responseData['title'] ??
            "Sunucu hatası: ${response.statusCode}";
        List<String>? errors = _parseErrors(responseData);
        if (errors?.isNotEmpty ?? false) {
          errorMessage = errors!.first; // Use first specific error if available
        }
        return LoginResponseModel.failure(
          errorMessage,
          errors: errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return LoginResponseModel.failure(
        "Bağlantı hatası veya sunucuya ulaşılamadı.",
      );
    }
  }

  Future<UserInfoResponseModel> getUserInfo(String token) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.userInfoEndpoint,
    );
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      if (response.statusCode == 200 && responseData['isSuccess'] == true) {
        return UserInfoResponseModel.fromJson(responseData);
      } else {
        String errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            responseData['title'] ??
            "Kullanıcı bilgileri alınırken sunucu hatası: ${response.statusCode}";
        List<String>? errors = _parseErrors(responseData);
        if (errors?.isNotEmpty ?? false) {
          errorMessage = errors!.first;
        }
        return UserInfoResponseModel.failure(
          errorMessage,
          errors: errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return UserInfoResponseModel.failure(
        "Kullanıcı bilgileri alınırken bağlantı hatası.",
      );
    }
  }

  Future<SignUpResponseModel> signUp(RegisterRequestModel requestModel) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.signUpEndpoint,
    );
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(requestModel.toJson()),
      );
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData['isSuccess'] == true) {
        return SignUpResponseModel.fromJson(responseData);
      } else {
        String errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            responseData['title'] ??
            "Kayıt sırasında sunucu hatası: ${response.statusCode}";
        List<String>? errors = _parseErrors(responseData);
        // If errors list is not empty and general message is generic, override general message
        if (errors?.isNotEmpty ?? false) {
          errorMessage =
              errors!.first; // Prioritize the first specific error message
        }
        return SignUpResponseModel.failure(
          errorMessage,
          errors: errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return SignUpResponseModel.failure(
        "Kayıt sırasında bağlantı hatası veya sunucuya ulaşılamadı.",
      );
    }
  }

  Future<SignOutResponseModel> signOut(
    String refreshToken, {
    String? accessTokenForHeader,
  }) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.signOutEndpoint,
    );
    final Map<String, String> requestBody = {'token': refreshToken};
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (accessTokenForHeader != null) {
      headers['Authorization'] = 'Bearer $accessTokenForHeader';
    }

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> responseData = jsonDecode(
              utf8.decode(response.bodyBytes),
            );
            return SignOutResponseModel.fromJson(responseData);
          } catch (e) {
            return SignOutResponseModel(
              isSuccess: true,
              message: "Başarıyla çıkış yapıldı (yanıt parse edilemedi).",
              statusCode: response.statusCode,
            );
          }
        } else {
          return SignOutResponseModel(
            isSuccess: true,
            message: "Başarıyla çıkış yapıldı (sunucudan).",
            statusCode: response.statusCode,
          );
        }
      } else {
        String errorMessage = "Çıkış yapılırken sunucu hatası oluştu.";
        List<String>? errors;
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> errorData = jsonDecode(
              utf8.decode(response.bodyBytes),
            );
            errorMessage =
                errorData['message'] ??
                errorData['title'] ??
                "Çıkış hatası: ${response.statusCode}";
            errors = _parseErrors(errorData);
            if (errors?.isNotEmpty ?? false) {
              errorMessage = errors!.first;
            }
          } catch (e) {
            errorMessage =
                "Çıkış yapılırken sunucu yanıtı okunamadı: ${response.statusCode}. Yanıt: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}";
          }
        } else {
          errorMessage =
              "Çıkış yapılırken sunucu hatası: ${response.statusCode} (yanıt boş).";
        }
        return SignOutResponseModel.failure(
          errorMessage,
          errors: errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return SignOutResponseModel.failure(
        "Çıkış yapılırken bağlantı hatası: $e",
      );
    }
  }
}
