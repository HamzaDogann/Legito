// lib/features/user_features/vocabulary_practice/services/word_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/word_list_response_dto.dart';
// Diğer importlar (eğer bu dosyada başka servis metodları da varsa)
// import '../../../../core/models/general_api_response_model.dart';
// import '../models/tip_response_dto.dart'; // Bu örnekte kullanılmıyor ama genel yapı için durabilir
// import '../models/create_update_tip_request_dto.dart'; // Bu örnekte kullanılmıyor
// import '../models/create_tip_response_dto.dart'; // Bu örnekte kullanılmıyor

class WordService {
  Future<WordListResponseDto> getRandomWords({
    required int wordCount,
    required String accessToken,
  }) async {
    // Query parametresini URL'ye ekle
    final queryParameters = {'wordCount': wordCount.toString()};
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.getRandomWordsEndpoint,
    ).replace(
      queryParameters: queryParameters,
    ); // <<< QUERY PARAMETRESİ EKLENDİ

    print(
      'WordService: Rastgele kelimeler GET isteği ile getiriliyor: ${uri.toString()}',
    );

    try {
      // --- DEĞİŞİKLİK BURADA: POST yerine GET ---
      final response = await http.get(
        // <<< GET OLARAK DEĞİŞTİRİLDİ
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken', // Token hala gerekli
        },
        // GET isteğinde body olmaz, bu satır kaldırıldı:
        // body: jsonEncode({'wordCount': wordCount}),
      );
      // --- DEĞİŞİKLİK BİTTİ ---

      final String responseBody = utf8.decode(response.bodyBytes);
      final String loggableBody =
          responseBody.isNotEmpty
              ? responseBody.substring(
                0,
                responseBody.length > 200 ? 200 : responseBody.length,
              )
              : "<empty>";
      print(
        'WordService (getRandomWords) Status: ${response.statusCode}, Body: $loggableBody',
      );

      Map<String, dynamic> responseData = {};
      bool isJsonResponse = false;
      if (responseBody.isNotEmpty) {
        try {
          responseData = jsonDecode(responseBody);
          isJsonResponse = true;
        } catch (e) {
          print(
            'WordService (getRandomWords) JSON Parse Hata: $e, Body: $responseBody',
          );
          if (response.statusCode != 200) {
            return WordListResponseDto.failure(
              "Sunucudan geçersiz yanıt formatı.",
              statusCode: response.statusCode,
            );
          }
        }
      }

      if (response.statusCode == 200) {
        if (!isJsonResponse && responseBody.isNotEmpty)
          return WordListResponseDto.failure(
            "Başarılı yanıt ancak formatı bozuk.",
            statusCode: response.statusCode,
          );
        // API'den gelen yanıtın doğrudan WordListResponseDto.fromJson'a uygun olduğunu varsayıyoruz.
        // Yani {"data": [...], "statusCode": ..., "isSuccess": ...}
        return WordListResponseDto.fromJson(responseData);
      }
      // Eğer API 404 "No words found" gibi bir durum için özel bir body dönmüyorsa,
      // ve sadece status code 404 ise, bunu genel hata olarak yakalayabiliriz.
      // Veya API'nin 404'te ne döndüğüne göre özel bir kontrol eklenebilir.
      else {
        String errorMessage =
            "Kelimeler getirilemedi (HTTP ${response.statusCode}).";
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
        } else if (responseBody.isNotEmpty) {
          // Eğer body JSON değilse ama doluysa
          errorMessage = responseBody;
        }
        return WordListResponseDto.failure(
          errorMessage,
          errors: errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('WordService getRandomWords Hata: $e');
      return WordListResponseDto.failure(
        "Kelimeler getirilirken bağlantı hatası: $e",
      );
    }
  }
}
