// lib/features/user_features/library/models/resource_response_model.dart
import 'resource_enums.dart';

class ResourceResponseModel {
  final String id;
  final String name;
  final String? author;
  final int type;
  final int status;
  // final String userId; // <<< BU ALANI KALDIRIYORUZ (veya String? yapıyoruz)
  // API'den createdDate, updatedDate gibi alanlar geliyorsa eklenebilir

  ResourceResponseModel({
    required this.id,
    required this.name,
    this.author,
    required this.type,
    required this.status,
    // required this.userId, // <<< KALDIRILDI
  });

  factory ResourceResponseModel.fromJson(Map<String, dynamic> json) {
    return ResourceResponseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      author: json['author'] as String?, // Null gelebilir
      type: json['type'] as int,
      status: json['status'] as int,
      // userId: json['userId'] as String, // <<< KALDIRILDI
    );
  }

  UiResourceType get uiResourceType {
    if (type >= 0 && type < ApiResourceType.values.length) {
      final apiType = ApiResourceType.values[type];
      switch (apiType) {
        case ApiResourceType.book:
          return UiResourceType.book;
        case ApiResourceType.journal:
          return UiResourceType.journal;
        case ApiResourceType.article:
          return UiResourceType.article;
        case ApiResourceType.blog:
          return UiResourceType.blog;
        case ApiResourceType.encyclopedia:
          return UiResourceType.encyclopedia;
        case ApiResourceType.other:
          return UiResourceType.other;
      }
    }
    return UiResourceType.other;
  }

  String get uiStatus {
    if (status >= 0 && status < ApiSourceStatus.values.length) {
      final apiStatus = ApiSourceStatus.values[status];
      switch (apiStatus) {
        case ApiSourceStatus.complete:
          return statusCompleted;
        case ApiSourceStatus.continues:
          return statusCurrentlyReading;
        case ApiSourceStatus.waiting:
          return statusToBeRead;
      }
    }
    return statusCurrentlyReading; // Veya uygun bir varsayılan
  }
}
