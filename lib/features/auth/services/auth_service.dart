// lib/features/auth/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../user_features/models/user_info_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/signup_response_model.dart';

// SignOut için response model
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
    return SignOutResponseModel(
      isSuccess: success,
      message: json['message'] as String?,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
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
      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(responseData);
      } else {
        String errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            responseData['title'] ??
            "Sunucu hatası: ${response.statusCode}";
        List<String>? errors;
        if (responseData['errors'] is List)
          errors = List<String>.from(responseData['errors']);
        else if (responseData['errors'] is Map) {
          errors = [];
          (responseData['errors'] as Map).forEach((key, value) {
            if (value is List) errors?.addAll(value.cast<String>());
          });
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
      if (response.statusCode == 200) {
        return UserInfoResponseModel.fromJson(responseData);
      } else {
        String errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            responseData['title'] ??
            "Kullanıcı bilgileri alınırken sunucu hatası: ${response.statusCode}";
        List<String>? errors;
        if (responseData['errors'] is List)
          errors = List<String>.from(responseData['errors']);
        else if (responseData['errors'] is Map) {
          errors = [];
          (responseData['errors'] as Map).forEach((key, value) {
            if (value is List) errors?.addAll(value.cast<String>());
          });
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SignUpResponseModel.fromJson(responseData);
      } else {
        String errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            responseData['title'] ??
            "Kayıt sırasında sunucu hatası: ${response.statusCode}";
        List<String>? errorsList;
        if (responseData['errors'] is List)
          errorsList = List<String>.from(responseData['errors']);
        else if (responseData['errors'] is Map) {
          errorsList = [];
          (responseData['errors'] as Map).forEach((key, value) {
            if (value is List) errorsList?.addAll(value.cast<String>());
          });
          if (errorsList.isNotEmpty &&
              (errorMessage == responseData['title'] ||
                  errorMessage.contains("sunucu hatası")))
            errorMessage = errorsList.join(" ");
        }
        // SignUpResponseModel.failure tanımınızın errors ve statusCode parametrelerini desteklediğinden emin olun.
        return SignUpResponseModel.failure(errorMessage);
      }
    } catch (e, s) {
      return SignUpResponseModel.failure(
        "Kayıt sırasında bağlantı hatası veya sunucuya ulaşılamadı.",
      );
    }
  }

  // signOut metodu refreshToken alacak şekilde güncellendi
  Future<SignOutResponseModel> signOut(
    String refreshToken, {
    String? accessTokenForHeader,
  }) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.signOutEndpoint,
    );
    print(
      'AuthService: Çıkış (SignOut) isteği gönderiliyor: ${uri.toString()}',
    );

    // API refreshToken bekliyor. Body'deki anahtarın 'token' mı 'refreshToken' mı olduğunu kontrol edin.
    // Şimdilik 'token' varsayıyoruz.
    final Map<String, String> requestBody = {'token': refreshToken};
    print(
      'AuthService: SignOut için gönderilen body (refreshToken içeren): ${jsonEncode(requestBody)}',
    );

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (accessTokenForHeader != null) {
      // Eğer API signOut için accessToken header'ı da istiyorsa
      headers['Authorization'] = 'Bearer $accessTokenForHeader';
      print('AuthService: SignOut için Authorization header kullanılıyor.');
    }

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('AuthService: SignOut cevabı statusCode: ${response.statusCode}');
      print('AuthService: SignOut cevabı body: ${response.body}');

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
        int? statusCode = response.statusCode;
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> errorData = jsonDecode(
              utf8.decode(response.bodyBytes),
            );
            errorMessage =
                errorData['message'] ??
                errorData['title'] ??
                "Çıkış hatası: $statusCode";
            if (errorData['errors'] is List) {
              errors = List<String>.from(errorData['errors']);
              if (errors.isNotEmpty) errorMessage = errors.join(" ");
            } else if (errorData['errors'] is Map) {
              errors = [];
              (errorData['errors'] as Map).forEach((key, value) {
                if (value is List)
                  errors?.addAll(value.cast<String>());
                else if (value is String)
                  errors?.add(value);
              });
              if (errors.isNotEmpty) errorMessage = errors.join(" ");
            }
          } catch (e) {
            errorMessage =
                "Çıkış yapılırken sunucu yanıtı okunamadı: $statusCode. Yanıt: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}";
          }
        } else {
          errorMessage =
              "Çıkış yapılırken sunucu hatası: $statusCode (yanıt boş).";
        }
        return SignOutResponseModel.failure(
          errorMessage,
          errors: errors,
          statusCode: statusCode,
        );
      }
    } catch (e) {
      print('AuthService signOut Hata: $e');
      return SignOutResponseModel.failure(
        "Çıkış yapılırken bağlantı hatası: $e",
      );
    }
  }
}
