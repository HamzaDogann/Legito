// lib/features/user_features/account/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/general_api_response_model.dart'; // Genel yanıt için
import '../../models/user_info_model.dart'; // UserInfoResponseModel (güncelleme sonrası dönebilir)
import '../models/update_user_request_model.dart';
import '../models/update_user_photo_request_model.dart';
import '../models/update_password_request_model.dart';

class UserService {
  // Kullanıcı bilgilerini güncelleme (PATCH /User/Info)
  Future<UserInfoResponseModel> updateUserProfile(
    UpdateUserRequestModel requestModel,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.updateUserEndpoint,
    );
    print('UserService: Kullanıcı profili güncelleniyor: ${uri.toString()}');
    try {
      final response = await http.patch(
        // HTTP PATCH metodu
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestModel.toJson()),
      );

      print('UserService (updateUserProfile) Status: ${response.statusCode}');
      print('UserService (updateUserProfile) Body: ${response.body}');
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 200) {
        // API güncellenmiş kullanıcı bilgilerini dönüyorsa UserInfoResponseModel olarak parse et
        return UserInfoResponseModel.fromJson(responseData);
      } else {
        return UserInfoResponseModel.failure(
          // UserInfoResponseModel'in failure constructor'ı
          responseData['message'] ?? "Profil güncellenirken hata oluştu.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('UserService updateUserProfile Hata: $e');
      return UserInfoResponseModel.failure(
        "Profil güncellenirken bağlantı hatası: $e",
      );
    }
  }

  // Kullanıcı fotoğrafını güncelleme (PATCH /User/Photo)
  // Bu metodun dönüş tipi API'nize göre değişebilir. Sadece başarı/hata veya güncellenmiş UserInfo dönebilir.
  // Şimdilik GeneralApiResponseModel kullanıyorum, ama UserInfoResponseModel de olabilir.
  Future<GeneralApiResponseModel> updateUserPhoto(
    // VEYA UserInfoResponseModel
    UpdateUserPhotoRequestModel requestModel,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.updateUserPhotoEndpoint,
    );
    print('UserService: Kullanıcı fotoğrafı güncelleniyor: ${uri.toString()}');
    try {
      final response = await http.patch(
        // HTTP PATCH metodu
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestModel.toJson()),
      );

      print('UserService (updateUserPhoto) Status: ${response.statusCode}');
      print('UserService (updateUserPhoto) Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> responseData = jsonDecode(
            utf8.decode(response.bodyBytes),
          );
          // Eğer API güncellenmiş UserInfo dönüyorsa:
          // return UserInfoResponseModel.fromJson(responseData);
          return GeneralApiResponseModel.fromJson(
            responseData,
          ); // Veya UserInfoResponseModel
        } else {
          // 204 No Content veya body boşsa
          return GeneralApiResponseModel(
            isSuccess: true,
            message: "Fotoğraf başarıyla güncellendi.",
            statusCode: response.statusCode,
          );
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return GeneralApiResponseModel.failure(
          // Veya UserInfoResponseModel.failure
          responseData['message'] ?? "Fotoğraf güncellenirken hata oluştu.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('UserService updateUserPhoto Hata: $e');
      return GeneralApiResponseModel.failure(
        "Fotoğraf güncellenirken bağlantı hatası: $e",
      );
    }
  }

  // Kullanıcı şifresini güncelleme (PATCH /User/Password)
  Future<GeneralApiResponseModel> updateUserPassword(
    UpdatePasswordRequestModel requestModel,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.updateUserPasswordEndpoint,
    );
    print('UserService: Kullanıcı şifresi güncelleniyor: ${uri.toString()}');
    try {
      final response = await http.patch(
        // HTTP PATCH metodu
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestModel.toJson()),
      );

      print('UserService (updateUserPassword) Status: ${response.statusCode}');
      print('UserService (updateUserPassword) Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Genellikle 204 No Content
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> responseData = jsonDecode(
            utf8.decode(response.bodyBytes),
          );
          return GeneralApiResponseModel.fromJson(responseData);
        } else {
          return GeneralApiResponseModel(
            isSuccess: true,
            message: "Şifre başarıyla güncellendi.",
            statusCode: response.statusCode,
          );
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return GeneralApiResponseModel.failure(
          responseData['message'] ?? "Şifre güncellenirken hata oluştu.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('UserService updateUserPassword Hata: $e');
      return GeneralApiResponseModel.failure(
        "Şifre güncellenirken bağlantı hatası: $e",
      );
    }
  }
}
