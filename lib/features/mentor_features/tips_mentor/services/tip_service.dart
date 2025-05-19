// lib/features/mentor_features/tips_mentor/services/tip_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/general_api_response_model.dart';
import '../models/tip_response_dto.dart';
import '../models/tip_list_response_dto.dart';
import '../models/create_update_tip_request_dto.dart';
import '../models/create_tip_response_dto.dart'; // Bu dosya CreateUpdateTipApiResponseDto'yu içermeli

class TipService {
  Future<TipResponseDto?> getRandomTip({String? accessToken}) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.getRandomTipEndpoint,
    );
    print('TipService: Rastgele ipucu getiriliyor: ${uri.toString()}');

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };

    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
      print('TipService (getRandomTip): Authorization header eklendi.');
    } else {
      print(
        'TipService (getRandomTip): Authorization header eklenmedi (token yok veya boş).',
      );
    }

    try {
      final response = await http.get(uri, headers: headers);
      final String responseBody = utf8.decode(response.bodyBytes);
      final String loggableBody =
          responseBody.isNotEmpty
              ? responseBody.substring(
                0,
                responseBody.length > 100 ? 100 : responseBody.length,
              )
              : "<empty>";
      print(
        'TipService (getRandomTip) Status: ${response.statusCode}, Body: $loggableBody',
      );

      if (response.statusCode == 200) {
        if (responseBody.isEmpty) {
          print(
            'TipService (getRandomTip) Hata: Yanıt başarılı (200) ama body boş.',
          );
          return null;
        }
        try {
          final Map<String, dynamic> responseData = jsonDecode(responseBody);
          // API'den gelen yanıt {"data": {tip_objesi}, "statusCode": ..., ...} şeklinde olduğu için
          // 'data' anahtarının içindeki Map'i TipResponseDto.fromJson'a gönderiyoruz.
          if (responseData.containsKey('data') &&
              responseData['data'] != null &&
              responseData['data'] is Map) {
            return TipResponseDto.fromJson(
              responseData['data'] as Map<String, dynamic>,
            );
          } else {
            // Eğer 'data' anahtarı yoksa veya formatı beklenenden farklıysa, bu bir hatadır.
            print(
              'TipService (getRandomTip): Yanıt 200 OK ancak beklenen "data" anahtarı bulunamadı veya formatı yanlış. ResponseData: $responseData',
            );
            return null;
          }
        } catch (e) {
          print(
            'TipService (getRandomTip) JSON Parse Hata (Status 200): $e, Body: $responseBody',
          );
          return null;
        }
      } else if (response.statusCode == 404 &&
          responseBody.toLowerCase().contains("no tip found")) {
        print(
          'TipService (getRandomTip): 404 - No Tip found. Null döndürülüyor.',
        );
        return null;
      } else if (response.statusCode == 401) {
        print('TipService (getRandomTip) Hata: 401 Unauthorized.');
        return null;
      } else {
        print(
          'TipService (getRandomTip) Genel Hata: ${response.statusCode} - $responseBody',
        );
        return null;
      }
    } catch (e) {
      print('TipService getRandomTip Bağlantı/Diğer Hata: $e');
      return null;
    }
  }

  Future<TipListResponseDto> getUserTips(String accessToken) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.getUserTipsEndpoint,
    );
    print('TipService: Kullanıcı ipuçları getiriliyor: ${uri.toString()}');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
      );
      final String responseBody = utf8.decode(response.bodyBytes);
      final String loggableBody =
          responseBody.length > 200
              ? responseBody.substring(0, 200)
              : responseBody;
      print(
        'TipService (getUserTips) Status: ${response.statusCode}, Body: $loggableBody',
      );

      Map<String, dynamic> responseData = {};
      bool isJsonResponse = false;
      if (responseBody.isNotEmpty) {
        try {
          responseData = jsonDecode(responseBody);
          isJsonResponse = true;
        } catch (e) {
          if (response.statusCode != 200 && response.statusCode != 404)
            return TipListResponseDto.failure(
              "Sunucudan geçersiz yanıt formatı.",
              statusCode: response.statusCode,
            );
        }
      }

      if (response.statusCode == 200) {
        if (!isJsonResponse && responseBody.isNotEmpty)
          return TipListResponseDto.failure(
            "Başarılı yanıt ancak formatı bozuk.",
            statusCode: response.statusCode,
          );
        return TipListResponseDto.fromJson(responseData);
      } else if (response.statusCode == 404 &&
          ((isJsonResponse &&
                  responseData['errors'] != null &&
                  (responseData['errors'] as List).any(
                    (e) => e.toString().toLowerCase().contains("no tip found"),
                  )) ||
              (isJsonResponse &&
                  responseData['message']?.toString().toLowerCase().contains(
                        "no tip found",
                      ) ==
                      true) ||
              (!isJsonResponse &&
                  responseBody.toLowerCase().contains("no tip found")))) {
        return TipListResponseDto(
          isSuccess: true,
          data: [],
          message: "Henüz hiç ipucu bulunmamaktadır.",
          statusCode: response.statusCode,
          errors: null,
        );
      } else {
        String errorMessage =
            "İpuçları getirilemedi (HTTP ${response.statusCode}).";
        List<String>? errors;
        if (isJsonResponse) {
          errorMessage =
              responseData['message'] ?? responseData['title'] ?? errorMessage;
          if (responseData['errors'] is List)
            errors = List<String>.from(responseData['errors']);
          else if (responseData['errors'] is Map) {
            errors = [];
            (responseData['errors'] as Map).forEach((key, value) {
              if (value is List) errors?.addAll(value.cast<String>());
            });
          }
        } else if (responseBody.isNotEmpty)
          errorMessage = responseBody;
        return TipListResponseDto.failure(
          errorMessage,
          errors: errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return TipListResponseDto.failure(
        "İpuçları getirilirken bir bağlantı hatası oluştu: $e",
      );
    }
  }

  Future<CreateUpdateTipApiResponseDto> createTip(
    CreateUpdateTipRequestDto requestModel,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.createTipEndpoint,
    );
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestModel.toJson()),
      );
      final String responseBody = utf8.decode(response.bodyBytes);
      print(
        'TipService (createTip) Status: ${response.statusCode}, Body: $responseBody',
      );
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      if (response.statusCode == 201 || response.statusCode == 200)
        return CreateUpdateTipApiResponseDto.fromJson(responseData);
      else
        return CreateUpdateTipApiResponseDto.failure(
          responseData['message'] ?? "İpucu oluşturulamadı.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
    } catch (e) {
      return CreateUpdateTipApiResponseDto.failure(
        "İpucu oluşturulurken bağlantı hatası: $e",
      );
    }
  }

  Future<CreateUpdateTipApiResponseDto> updateTip(
    String tipId,
    CreateUpdateTipRequestDto requestModel,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.updateTipEndpoint}/$tipId',
    );
    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestModel.toJson()),
      );
      final String responseBody = utf8.decode(response.bodyBytes);
      print(
        'TipService (updateTip) Status: ${response.statusCode}, Body: $responseBody',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (responseBody.isEmpty || response.statusCode == 204)
          return CreateUpdateTipApiResponseDto(
            isSuccess: true,
            message: "İpucu başarıyla güncellendi.",
            statusCode: response.statusCode,
          );
        final Map<String, dynamic> responseData = jsonDecode(responseBody);
        return CreateUpdateTipApiResponseDto.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = jsonDecode(responseBody);
        return CreateUpdateTipApiResponseDto.failure(
          responseData['message'] ?? "İpucu güncellenemedi.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return CreateUpdateTipApiResponseDto.failure(
        "İpucu güncellenirken bağlantı hatası: $e",
      );
    }
  }

  Future<GeneralApiResponseModel> deleteTip(
    String tipId,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.deleteTipEndpoint}/$tipId',
    );
    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
      );
      final String responseBody = utf8.decode(response.bodyBytes);
      print(
        'TipService (deleteTip) Status: ${response.statusCode}, Body: $responseBody',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (responseBody.isNotEmpty) {
          final Map<String, dynamic> responseData = jsonDecode(responseBody);
          return GeneralApiResponseModel.fromJson(responseData);
        } else
          return GeneralApiResponseModel(
            isSuccess: true,
            message: "İpucu başarıyla silindi",
            statusCode: response.statusCode,
          );
      } else {
        if (responseBody.isNotEmpty) {
          final Map<String, dynamic> responseData = jsonDecode(responseBody);
          return GeneralApiResponseModel.failure(
            responseData['message'] ?? "İpucu silinemedi.",
            errors:
                responseData['errors'] != null
                    ? List<String>.from(responseData['errors'])
                    : null,
            statusCode: response.statusCode,
          );
        } else
          return GeneralApiResponseModel.failure(
            "İpucu silinemedi. Durum Kodu: ${response.statusCode} (yanıt boş)",
            statusCode: response.statusCode,
          );
      }
    } catch (e) {
      return GeneralApiResponseModel.failure(
        "İpucu silinirken bağlantı hatası: $e",
      );
    }
  }
}
