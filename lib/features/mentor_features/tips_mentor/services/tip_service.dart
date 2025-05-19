// lib/features/mentor_features/tips_mentor/services/tip_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/general_api_response_model.dart'; // Genel yanıt için
import '../models/tip_response_dto.dart';
import '../models/tip_list_response_dto.dart';
import '../models/create_update_tip_request_dto.dart';
import '../models/create_tip_response_dto.dart'; // create ve update için

class TipService {
  // PublicHomeScreen için rastgele ipucu
  Future<TipResponseDto?> getRandomTip() async {
    // Null dönebilir
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.getRandomTipEndpoint,
    );
    print('TipService: Rastgele ipucu getiriliyor: ${uri.toString()}');
    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );
      print(
        'TipService (getRandomTip) Status: ${response.statusCode}, Body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}',
      );
      if (response.statusCode == 200) {
        // API doğrudan TipResponseDto dönüyorsa
        final Map<String, dynamic> responseData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return TipResponseDto.fromJson(responseData);
        // Eğer API {isSuccess:..., data: TipResponseDto} dönüyorsa:
        // final RandomTipApiResponse apiResponse = RandomTipApiResponse.fromJson(responseData);
        // return apiResponse.isSuccess ? apiResponse.data : null;
      } else {
        print(
          'TipService (getRandomTip) Hata: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('TipService getRandomTip Hata: $e');
      return null;
    }
  }

  // Mentor için kullanıcının (mentorun) ipuçlarını getir
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
      print(
        'TipService (getUserTips) Status: ${response.statusCode}, Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 200) {
        return TipListResponseDto.fromJson(responseData);
      } else {
        return TipListResponseDto.failure(
          responseData['message'] ?? "İpuçları getirilemedi.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('TipService getUserTips Hata: $e');
      return TipListResponseDto.failure(
        "İpuçları getirilirken bağlantı hatası: $e",
      );
    }
  }

  // Mentor için yeni ipucu oluştur
  Future<CreateUpdateTipApiResponseDto> createTip(
    CreateUpdateTipRequestDto requestModel,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.createTipEndpoint,
    );
    print(
      'TipService: İpucu oluşturuluyor: ${uri.toString()}, Data: ${jsonEncode(requestModel.toJson())}',
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
      print(
        'TipService (createTip) Status: ${response.statusCode}, Body: ${response.body}',
      );
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // 201 Created
        return CreateUpdateTipApiResponseDto.fromJson(responseData);
      } else {
        return CreateUpdateTipApiResponseDto.failure(
          responseData['message'] ?? "İpucu oluşturulamadı.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('TipService createTip Hata: $e');
      return CreateUpdateTipApiResponseDto.failure(
        "İpucu oluşturulurken bağlantı hatası: $e",
      );
    }
  }

  // Mentor için ipucu güncelle
  Future<CreateUpdateTipApiResponseDto> updateTip(
    String tipId,
    CreateUpdateTipRequestDto requestModel,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.updateTipEndpoint}/$tipId',
    );
    print(
      'TipService: İpucu güncelleniyor: ${uri.toString()}, Data: ${jsonEncode(requestModel.toJson())}',
    );
    try {
      final response = await http.put(
        // PUT metodu
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestModel.toJson()),
      );
      print(
        'TipService (updateTip) Status: ${response.statusCode}, Body: ${response.body}',
      );
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return CreateUpdateTipApiResponseDto.fromJson(
          responseData,
        ); // API güncellenmiş tip dönebilir
      } else {
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
      print('TipService updateTip Hata: $e');
      return CreateUpdateTipApiResponseDto.failure(
        "İpucu güncellenirken bağlantı hatası: $e",
      );
    }
  }

  // Mentor için ipucu sil
  Future<GeneralApiResponseModel> deleteTip(
    String tipId,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.deleteTipEndpoint}/$tipId',
    );
    print('TipService: İpucu siliniyor: ${uri.toString()}');
    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
      );
      print(
        'TipService (deleteTip) Status: ${response.statusCode}, Body: ${response.body}',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> responseData = jsonDecode(
            utf8.decode(response.bodyBytes),
          );
          return GeneralApiResponseModel.fromJson(responseData);
        } else {
          return GeneralApiResponseModel(
            isSuccess: true,
            message: "İpucu başarıyla silindi",
            statusCode: response.statusCode,
          );
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return GeneralApiResponseModel.failure(
          responseData['message'] ?? "İpucu silinemedi.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('TipService deleteTip Hata: $e');
      return GeneralApiResponseModel.failure(
        "İpucu silinirken bağlantı hatası: $e",
      );
    }
  }
}
