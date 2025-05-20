// lib/features/user_features/reading_session/services/reading_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/reading_file_request_dto.dart';
import '../models/file_word_count_response_dto.dart';
import '../models/create_reading_session_request_dto.dart';
import '../models/reading_session_result_dto.dart';

class ReadingService {
  // Resimden kelime sayısı al
  Future<FileWordCountApiResponseDto> getWordCountFromImage(
    ReadingFileRequestDto requestDto,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.uploadReadingImageEndpoint,
    );
    print('ReadingService: Resimden kelime sayısı alınıyor: ${uri.toString()}');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestDto.toJson()),
      );
      final String responseBody = utf8.decode(response.bodyBytes);
      print(
        'ReadingService (getWordCountFromImage) Status: ${response.statusCode}, Body: $responseBody',
      );
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return FileWordCountApiResponseDto.fromJson(responseData);
      } else {
        return FileWordCountApiResponseDto.failure(
          responseData['message'] ?? "Resim işlenirken hata oluştu.",
          errors: (responseData['errors'] as List<dynamic>?)?.cast<String>(),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('ReadingService getWordCountFromImage Hata: $e');
      return FileWordCountApiResponseDto.failure(
        "Resim işlenirken bağlantı hatası: $e",
      );
    }
  }

  // PDF'ten kelime sayısı al
  Future<FileWordCountApiResponseDto> getWordCountFromPdf(
    ReadingFileRequestDto requestDto,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.uploadReadingPdfEndpoint,
    );
    print('ReadingService: PDF\'ten kelime sayısı alınıyor: ${uri.toString()}');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestDto.toJson()),
      );
      final String responseBody = utf8.decode(response.bodyBytes);
      print(
        'ReadingService (getWordCountFromPdf) Status: ${response.statusCode}, Body: $responseBody',
      );
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return FileWordCountApiResponseDto.fromJson(responseData);
      } else {
        return FileWordCountApiResponseDto.failure(
          responseData['message'] ?? "PDF işlenirken hata oluştu.",
          errors: (responseData['errors'] as List<dynamic>?)?.cast<String>(),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('ReadingService getWordCountFromPdf Hata: $e');
      return FileWordCountApiResponseDto.failure(
        "PDF işlenirken bağlantı hatası: $e",
      );
    }
  }

  // Okuma seansını kaydet
  Future<ReadingSessionResultApiResponseDto> createReadingSession(
    CreateReadingSessionRequestDto requestDto,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.createReadingSessionEndpoint,
    );
    print(
      'ReadingService: Okuma seansı oluşturuluyor: ${uri.toString()}, Data: ${jsonEncode(requestDto.toJson())}',
    );
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestDto.toJson()),
      );
      final String responseBody = utf8.decode(response.bodyBytes);
      print(
        'ReadingService (createReadingSession) Status: ${response.statusCode}, Body: $responseBody',
      );
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // 201 Created
        return ReadingSessionResultApiResponseDto.fromJson(responseData);
      } else {
        return ReadingSessionResultApiResponseDto.failure(
          responseData['message'] ?? "Okuma seansı kaydedilemedi.",
          errors: (responseData['errors'] as List<dynamic>?)?.cast<String>(),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('ReadingService createReadingSession Hata: $e');
      return ReadingSessionResultApiResponseDto.failure(
        "Okuma seansı kaydedilirken bağlantı hatası: $e",
      );
    }
  }
}
