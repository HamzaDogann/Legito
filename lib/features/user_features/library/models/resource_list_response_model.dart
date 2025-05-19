// lib/features/user_features/library/models/resource_list_response_model.dart
import 'resource_response_model.dart';

// API'den dönen genel liste yanıtını sarmalamak için (eğer API'niz {isSuccess: true, data: [...]} gibi dönüyorsa)
class ResourceListResponseModel {
  final bool isSuccess;
  final String? message;
  final List<ResourceResponseModel>? data;
  final List<String>? errors;
  final int? statusCode;

  ResourceListResponseModel({
    required this.isSuccess,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ResourceListResponseModel.fromJson(Map<String, dynamic> json) {
    return ResourceListResponseModel(
      isSuccess:
          json['isSuccess'] ??
          (json['data'] != null &&
              (json['statusCode'] == 200 || json['statusCode'] == null)),
      message: json['message'] as String?,
      data:
          json['data'] != null
              ? List<ResourceResponseModel>.from(
                (json['data'] as List<dynamic>).map(
                  (x) => ResourceResponseModel.fromJson(x),
                ),
              )
              : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      statusCode: json['statusCode'] as int?,
    );
  }

  factory ResourceListResponseModel.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return ResourceListResponseModel(
      isSuccess: false,
      message: message,
      data: null,
      errors: errors,
      statusCode: statusCode,
    );
  }
}

// Eğer API'niz doğrudan List<ResourceResponseModel> dönüyorsa, bu sarmalayıcıya gerek olmayabilir.
// O zaman ResourceService'te doğrudan List<ResourceResponseModel> parse edilir.
// Şimdilik genel bir API yanıt yapısı varsayıyorum.
