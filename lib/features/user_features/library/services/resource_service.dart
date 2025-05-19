// lib/features/user_features/library/services/resource_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/general_api_response_model.dart';
import '../models/resource_request_model.dart';
import '../models/resource_list_response_model.dart';
// ResourceResponseModel importu ResourceListResponseModel içinden dolaylı olarak gelebilir
// ama açıkça eklemek de sorun olmaz:
// import '../models/resource_response_model.dart';

class ResourceService {
  Future<ResourceListResponseModel> getResources(String accessToken) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.getResourcesEndpoint,
    );
    print('ResourceService: Kaynaklar getiriliyor: ${uri.toString()}');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
      );
      print(
        'ResourceService (getResources) Status: ${response.statusCode}, Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 200) {
        // Eğer API doğrudan List<Resource> dönüyorsa:
        // final List<dynamic> jsonDataList = jsonDecode(utf8.decode(response.bodyBytes));
        // final List<ResourceResponseModel> resources = jsonDataList.map((data) => ResourceResponseModel.fromJson(data)).toList();
        // return ResourceListResponseModel(isSuccess: true, data: resources, statusCode: 200);
        // Ama ResourceListResponseModel sarmalayıcısını kullanıyorsak:
        return ResourceListResponseModel.fromJson(responseData);
      } else {
        return ResourceListResponseModel.failure(
          responseData['message'] ?? "Kaynaklar getirilemedi.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('ResourceService getResources Hata: $e');
      return ResourceListResponseModel.failure(
        "Kaynaklar getirilirken bağlantı hatası: $e",
      );
    }
  }

  Future<GeneralApiResponseModel> createResource(
    ResourceRequestModel requestModel,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      ApiConstants.baseUrl + ApiConstants.createResourceEndpoint,
    );
    print(
      'ResourceService: Kaynak oluşturuluyor: ${uri.toString()}, Data: ${jsonEncode(requestModel.toJson())}',
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
        'ResourceService (createResource) Status: ${response.statusCode}, Body: ${response.body}',
      );
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      // Create işlemi genelde 201 Created döner
      if (response.statusCode == 201 || response.statusCode == 200) {
        return GeneralApiResponseModel.fromJson(
          responseData,
        ); // API'den dönen ID 'data' içinde olabilir
      } else {
        return GeneralApiResponseModel.failure(
          responseData['message'] ?? "Kaynak oluşturulamadı.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('ResourceService createResource Hata: $e');
      return GeneralApiResponseModel.failure(
        "Kaynak oluşturulurken bağlantı hatası: $e",
      );
    }
  }

  Future<GeneralApiResponseModel> updateResource(
    String resourceId,
    ResourceRequestModel requestModel,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.updateResourceEndpoint}/$resourceId',
    );
    print(
      'ResourceService: Kaynak güncelleniyor: ${uri.toString()}, Data: ${jsonEncode(requestModel.toJson())}',
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
      print(
        'ResourceService (updateResource) Status: ${response.statusCode}, Body: ${response.body}',
      );
      // Başarılı update 200 OK veya 204 No Content dönebilir
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> responseData = jsonDecode(
            utf8.decode(response.bodyBytes),
          );
          return GeneralApiResponseModel.fromJson(responseData);
        } else {
          return GeneralApiResponseModel(
            isSuccess: true,
            message: "Kaynak başarıyla güncellendi.",
            statusCode: response.statusCode,
          );
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return GeneralApiResponseModel.failure(
          responseData['message'] ?? "Kaynak güncellenemedi.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('ResourceService updateResource Hata: $e');
      return GeneralApiResponseModel.failure(
        "Kaynak güncellenirken bağlantı hatası: $e",
      );
    }
  }

  Future<GeneralApiResponseModel> deleteResource(
    String resourceId,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.deleteResourceEndpoint}/$resourceId',
    );
    print('ResourceService: Kaynak siliniyor: ${uri.toString()}');
    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $accessToken',
        },
      );
      print(
        'ResourceService (deleteResource) Status: ${response.statusCode}, Body: ${response.body}',
      );
      // Başarılı delete 200 OK veya 204 No Content dönebilir
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> responseData = jsonDecode(
            utf8.decode(response.bodyBytes),
          );
          return GeneralApiResponseModel.fromJson(responseData);
        } else {
          return GeneralApiResponseModel(
            isSuccess: true,
            message: "Kaynak başarıyla silindi.",
            statusCode: response.statusCode,
          );
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return GeneralApiResponseModel.failure(
          responseData['message'] ?? "Kaynak silinemedi.",
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('ResourceService deleteResource Hata: $e');
      return GeneralApiResponseModel.failure(
        "Kaynak silinirken bağlantı hatası: $e",
      );
    }
  }
}
