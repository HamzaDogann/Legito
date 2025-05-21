// lib/features/user_features/dashboard/services/dashboard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/dashboard_dtos.dart'; // Bir önceki adımda oluşturduğumuz DTO'lar

class DashboardService {
  Future<UserDashboardApiResponseDto> getUserDashboardData(
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.getUserDashboardEndpoint,
    );
    print(
      'DashboardService: Kullanıcı dashboard verileri getiriliyor: ${uri.toString()}',
    );
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
          responseBody.length > 300
              ? responseBody.substring(0, 300)
              : responseBody;
      print(
        'DashboardService (getUserDashboardData) Status: ${response.statusCode}, Body: $loggableBody...',
      );

      Map<String, dynamic> responseData = {};
      bool isJsonResponse = false;
      if (responseBody.isNotEmpty) {
        try {
          responseData = jsonDecode(responseBody);
          isJsonResponse = true;
        } catch (e) {
          print('DashboardService JSON Parse Hata: $e, Body: $responseBody');
          if (response.statusCode != 200) {
            // Sadece gerçek HTTP hatalarında parse hatası dön
            return UserDashboardApiResponseDto.failure(
              "Sunucudan geçersiz yanıt formatı.",
              statusCode: response.statusCode,
            );
          }
          // 200 ama parse edilemiyorsa, bu da bir sorun
          return UserDashboardApiResponseDto.failure(
            "Başarılı yanıt ancak veri formatı bozuk.",
            statusCode: response.statusCode,
          );
        }
      } else if (response.statusCode != 200 && response.statusCode != 204) {
        // Body boş ve başarılı değilse
        return UserDashboardApiResponseDto.failure(
          "Sunucudan boş yanıt alındı (Hata Kodu: ${response.statusCode}).",
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 200) {
        if (!isJsonResponse && responseBody.isNotEmpty) {
          // 200 OK ama JSON değilse (çok nadir)
          return UserDashboardApiResponseDto.failure(
            "Başarılı yanıt ancak beklenmedik format.",
            statusCode: response.statusCode,
          );
        }
        // responseData'nın dolu olduğundan emin ol (body boş değilse parse edilmiş olmalı)
        if (responseData.isEmpty && responseBody.isNotEmpty) {
          // Parse edildi ama map boş kaldıysa (geçersiz JSON yapısı)
          return UserDashboardApiResponseDto.failure(
            "Alınan veri işlenemedi.",
            statusCode: response.statusCode,
          );
        }
        return UserDashboardApiResponseDto.fromJson(responseData);
      } else {
        String errorMessage =
            "Dashboard verileri getirilemedi (HTTP ${response.statusCode}).";
        List<String>? errors;
        if (isJsonResponse) {
          // responseData parse edilebildiyse oradan al
          errorMessage =
              responseData['message'] ?? responseData['title'] ?? errorMessage;
          if (responseData['errors'] is List) {
            errors = List<String>.from(responseData['errors']);
          } else if (responseData['errors'] is Map) {
            errors = [];
            (responseData['errors'] as Map).forEach((key, value) {
              if (value is List) errors?.addAll(value.cast<String>());
            });
          }
        } else if (responseBody.isNotEmpty) {
          // Parse edilemediyse ham body'yi kullan
          errorMessage = responseBody;
        }
        return UserDashboardApiResponseDto.failure(
          errorMessage,
          errors: errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('DashboardService getUserDashboardData Hata: $e');
      return UserDashboardApiResponseDto.failure(
        "Dashboard verileri getirilirken bağlantı hatası: $e",
      );
    }
  }
}
