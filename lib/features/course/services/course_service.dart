// lib/features/course/services/course_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/models/general_api_response_model.dart'; // Genel yanıt için
import '../models/course_index_response_dto.dart';
import '../models/course_detail_dto.dart';
import '../models/user_course_list_api_response_dto.dart';
import '../models/create_course_request_dto.dart';
// API'den Create/Update sonrası dönen yanıt için bir model (CourseItemDto veya CourseDetailDto içerebilir)
// Şimdilik, create/update sonrası CourseDetailDto döndüğünü varsayalım.
// Eğer sadece ID veya genel mesaj dönüyorsa GeneralApiResponseModel kullanılabilir.

class CourseService {
  // Kullanıcı için Popüler ve Son Eklenen Dersleri Getir
  Future<CourseIndexApiResponseDto> getCourseIndex(String? accessToken) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.getCourseIndexEndpoint,
    );
    print('CourseService: Kurs Index getiriliyor: ${uri.toString()}');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (accessToken != null) headers['Authorization'] = 'Bearer $accessToken';

    try {
      final response = await http.get(uri, headers: headers);
      final String responseBody = utf8.decode(response.bodyBytes);
      print(
        'CourseService (getCourseIndex) Status: ${response.statusCode}, Body: ${responseBody.length > 200 ? responseBody.substring(0, 200) : responseBody}',
      );
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return CourseIndexApiResponseDto.fromJson(responseData);
      } else {
        return CourseIndexApiResponseDto.failure(
          responseData['message'] ?? "Kurs index verileri getirilemedi.",
          errors: (responseData['errors'] as List<dynamic>?)?.cast<String>(),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('CourseService getCourseIndex Hata: $e');
      return CourseIndexApiResponseDto.failure(
        "Kurs index verileri getirilirken bağlantı hatası: $e",
      );
    }
  }

  // Kullanıcı için Tek Bir Kurs Detayını Getir
  Future<CourseDetailApiResponseDto> getCourseDetail(
    String courseId,
    String? accessToken,
  ) async {
    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getCourseDetailEndpoint}/$courseId',
    );
    print('CourseService: Kurs Detayı getiriliyor: ${uri.toString()}');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (accessToken != null) headers['Authorization'] = 'Bearer $accessToken';

    try {
      final response = await http.get(uri, headers: headers);
      final String responseBody = utf8.decode(response.bodyBytes);
      print(
        'CourseService (getCourseDetail) Status: ${response.statusCode}, Body: ${responseBody.length > 200 ? responseBody.substring(0, 200) : responseBody}',
      );
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return CourseDetailApiResponseDto.fromJson(responseData);
      } else {
        return CourseDetailApiResponseDto.failure(
          responseData['message'] ?? "Kurs detayı getirilemedi.",
          errors: (responseData['errors'] as List<dynamic>?)?.cast<String>(),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('CourseService getCourseDetail Hata: $e');
      return CourseDetailApiResponseDto.failure(
        "Kurs detayı getirilirken bağlantı hatası: $e",
      );
    }
  }

  // Mentor için Kendi Derslerini Getir
  Future<UserCourseListApiResponseDto> getUserCourses(
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.getUserCoursesEndpoint,
    );
    print('CourseService: Mentor kursları getiriliyor: ${uri.toString()}');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
      );
      final String responseBody = utf8.decode(response.bodyBytes);
      print(
        'CourseService (getUserCourses) Status: ${response.statusCode}, Body: ${responseBody.length > 200 ? responseBody.substring(0, 200) : responseBody}',
      );
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return UserCourseListApiResponseDto.fromJson(responseData);
      } else if (response.statusCode == 404 &&
          (responseData['errors'] as List<dynamic>?)?.any(
                (e) => e.toString().toLowerCase().contains("no course found"),
              ) ==
              true) {
        print(
          "CourseService (getUserCourses): 404 - No Course found. Başarılı ama boş liste.",
        );
        return UserCourseListApiResponseDto(
          isSuccess: true,
          data: [],
          statusCode: 404,
          errors: null,
        );
      } else {
        return UserCourseListApiResponseDto.failure(
          responseData['message'] ?? "Mentor kursları getirilemedi.",
          errors: (responseData['errors'] as List<dynamic>?)?.cast<String>(),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('CourseService getUserCourses Hata: $e');
      return UserCourseListApiResponseDto.failure(
        "Mentor kursları getirilirken bağlantı hatası: $e",
      );
    }
  }

  // Kullanıcı için Kurs Arama (Bu endpoint için response DTO'su UserCourseListApiResponseDto olabilir)
  Future<UserCourseListApiResponseDto> searchCourses(
    String query,
    String? accessToken,
  ) async {
    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.searchCoursesEndpoint}?query=${Uri.encodeComponent(query)}',
    );
    print('CourseService: Kurs aranıyor: ${uri.toString()}');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (accessToken != null) headers['Authorization'] = 'Bearer $accessToken';

    try {
      final response = await http.get(uri, headers: headers);
      final String responseBody = utf8.decode(response.bodyBytes);
      print(
        'CourseService (searchCourses) Status: ${response.statusCode}, Body: ${responseBody.length > 200 ? responseBody.substring(0, 200) : responseBody}',
      );
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return UserCourseListApiResponseDto.fromJson(
          responseData,
        ); // Arama sonuçları da CourseItemDto listesi dönebilir
      } else if (response.statusCode == 404 &&
          (responseData['errors'] as List<dynamic>?)?.any(
                (e) => e.toString().toLowerCase().contains("no course found"),
              ) ==
              true) {
        print(
          "CourseService (searchCourses): 404 - No Course found for query '$query'. Başarılı ama boş liste.",
        );
        return UserCourseListApiResponseDto(
          isSuccess: true,
          data: [],
          statusCode: 404,
          errors: null,
        );
      } else {
        return UserCourseListApiResponseDto.failure(
          responseData['message'] ?? "Kurs arama sırasında hata.",
          errors: (responseData['errors'] as List<dynamic>?)?.cast<String>(),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('CourseService searchCourses Hata: $e');
      return UserCourseListApiResponseDto.failure(
        "Kurs arama sırasında bağlantı hatası: $e",
      );
    }
  }

  // Mentor için Yeni Kurs Oluşturma
  // API'nin Create sonrası ne döndüğüne bağlı olarak dönüş tipi değişebilir.
  // Genellikle oluşturulan objenin ID'sini veya tamamını içeren bir DTO döner.
  // Şimdilik CourseDetailApiResponseDto (içinde CourseDetailDto var) döndüğünü varsayıyorum.
  // Veya GeneralApiResponseModel (data alanında ID olabilir)
  Future<CourseDetailApiResponseDto> createCourse(
    CreateCourseRequestDto requestModel,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.createCourseEndpoint,
    );
    print(
      'CourseService: Kurs oluşturuluyor: ${uri.toString()}, Data: ${jsonEncode(requestModel.toJson())}',
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
        'CourseService (createCourse) Status: ${response.statusCode}, Body: $responseBody',
      );
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // 201 Created
        return CourseDetailApiResponseDto.fromJson(
          responseData,
        ); // Varsayım: API oluşturulan kurs detayını döner
      } else {
        return CourseDetailApiResponseDto.failure(
          responseData['message'] ?? "Kurs oluşturulamadı.",
          errors: (responseData['errors'] as List<dynamic>?)?.cast<String>(),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('CourseService createCourse Hata: $e');
      return CourseDetailApiResponseDto.failure(
        "Kurs oluşturulurken bağlantı hatası: $e",
      );
    }
  }

  // Mentor için Kurs Güncelleme
  // API'nin Update sonrası ne döndüğüne bağlı. CourseDetailApiResponseDto veya GeneralApiResponseModel olabilir.
  Future<CourseDetailApiResponseDto> updateCourse(
    String courseId,
    CreateCourseRequestDto requestModel,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.updateCourseEndpoint}/$courseId',
    );
    print(
      'CourseService: Kurs güncelleniyor: ${uri.toString()}, Data: ${jsonEncode(requestModel.toJson())}',
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
      final String responseBody = utf8.decode(response.bodyBytes);
      print(
        'CourseService (updateCourse) Status: ${response.statusCode}, Body: $responseBody',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (responseBody.isEmpty || response.statusCode == 204) {
          // Eğer API 204 dönerse veya 200 dönüp body boşsa, güncellenmiş veriyi tekrar çekmek gerekebilir.
          // Şimdilik başarılı bir CourseDetailApiResponseDto döndürüyoruz, data null olabilir.
          // Veya getCourseDetail'i çağırıp güncel veriyi döndürebiliriz.
          return CourseDetailApiResponseDto(
            isSuccess: true,
            message: "Kurs başarıyla güncellendi.",
            statusCode: response.statusCode,
            data: null,
          );
        }
        final Map<String, dynamic> responseData = jsonDecode(responseBody);
        return CourseDetailApiResponseDto.fromJson(
          responseData,
        ); // API güncellenmiş kurs detayını dönerse
      } else {
        final Map<String, dynamic> responseData = jsonDecode(responseBody);
        return CourseDetailApiResponseDto.failure(
          responseData['message'] ?? "Kurs güncellenemedi.",
          errors: (responseData['errors'] as List<dynamic>?)?.cast<String>(),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('CourseService updateCourse Hata: $e');
      return CourseDetailApiResponseDto.failure(
        "Kurs güncellenirken bağlantı hatası: $e",
      );
    }
  }

  // Mentor için Kurs Silme
  Future<GeneralApiResponseModel> deleteCourse(
    String courseId,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.deleteCourseEndpoint}/$courseId',
    );
    print('CourseService: Kurs siliniyor: ${uri.toString()}');
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
        'CourseService (deleteCourse) Status: ${response.statusCode}, Body: $responseBody',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (responseBody.isNotEmpty) {
          final Map<String, dynamic> responseData = jsonDecode(responseBody);
          return GeneralApiResponseModel.fromJson(responseData);
        } else {
          return GeneralApiResponseModel(
            isSuccess: true,
            message: "Kurs başarıyla silindi.",
            statusCode: response.statusCode,
          );
        }
      } else {
        if (responseBody.isNotEmpty) {
          final Map<String, dynamic> responseData = jsonDecode(responseBody);
          return GeneralApiResponseModel.failure(
            responseData['message'] ?? "Kurs silinemedi.",
            errors: (responseData['errors'] as List<dynamic>?)?.cast<String>(),
            statusCode: response.statusCode,
          );
        } else {
          return GeneralApiResponseModel.failure(
            "Kurs silinemedi. Durum Kodu: ${response.statusCode} (yanıt boş)",
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e) {
      print('CourseService deleteCourse Hata: $e');
      return GeneralApiResponseModel.failure(
        "Kurs silinirken bağlantı hatası: $e",
      );
    }
  }
}
