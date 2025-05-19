// lib/features/user_features/models/user_info_model.dart
import '../../../core/enums/user_role.dart';

class UserInfoResponseModel {
  final bool isSuccess;
  final UserInfoData? data;
  final String? message;
  final List<String>? errors;
  final int? statusCode;

  UserInfoResponseModel({
    required this.isSuccess,
    this.data,
    this.message,
    this.errors,
    this.statusCode,
  });

  factory UserInfoResponseModel.fromJson(Map<String, dynamic> json) {
    // API'nizin /User/Info endpoint'inden dönen JSON yapısına göre bu kısım ayarlanmalı.
    // Örnek olarak, başarılı bir yanıtın şöyle olduğunu varsayalım:
    // {
    //   "isSuccess": true,
    //   "message": "Kullanıcı bilgileri başarıyla alındı.",
    //   "data": {
    //     "userId": "6829dbd4-3350-b9f2-8d2a-c364uniqueid",
    //     "displayName": "Test Kullanıcısı",
    //     "email": "test@example.com",
    //     "gender": 0,
    //     "role": 0, // Member
    //     "photo": null, // veya "https://example.com/photo.jpg"
    //     "createdDate": "2023-10-27T10:00:00Z"
    //   },
    //   "errors": null,
    //   "statusCode": 200
    // }
    //
    // Veya hata yanıtı:
    // {
    //   "isSuccess": false,
    //   "message": "Yetkilendirme hatası.",
    //   "data": null,
    //   "errors": ["Token geçersiz"],
    //   "statusCode": 401
    // }

    // 'data' anahtarının varlığına ve null olmamasına göre 'isSuccess' belirlenebilir.
    // Ancak API'niz doğrudan 'isSuccess' alanı dönüyorsa, onu kullanmak daha iyi.
    bool success =
        json['isSuccess'] ??
        (json['data'] != null &&
            (json['statusCode'] == 200 || json['statusCode'] == null));

    return UserInfoResponseModel(
      isSuccess: success,
      data: json['data'] != null ? UserInfoData.fromJson(json['data']) : null,
      message: json['message'] as String?,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      statusCode: json['statusCode'] as int?,
    );
  }

  // Eksik olan failure constructor'ı
  factory UserInfoResponseModel.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return UserInfoResponseModel(
      isSuccess: false,
      data: null,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }
}

class UserInfoData {
  final String backendSpecificUserId;
  final String? displayName;
  final String? email;
  final int? gender;
  final int? role;
  final String? photoUrl;
  final DateTime? registrationDateTime;

  UserInfoData({
    required this.backendSpecificUserId,
    this.displayName,
    this.email,
    this.gender,
    this.role,
    this.photoUrl,
    this.registrationDateTime,
  });

  factory UserInfoData.fromJson(Map<String, dynamic> json) {
    // Backend'den gelen kullanıcı ID'sinin anahtarını buraya yazın.
    // Örneğin, API'niz 'userId', 'id', 'userGuid' gibi bir alan dönüyorsa:
    String userIdFromBackend =
        json['userId'] as String? ?? // En yaygın
        json['id'] as String? ?? // Alternatif
        json['userGuid'] as String? ?? // Başka bir alternatif
        ''; // Bulunamazsa boş string (bu durum loglanmalı)

    if (userIdFromBackend.isEmpty) {
      print(
        "UserInfoData.fromJson UYARI: Backend'den kullanıcı ID'si ('userId', 'id', 'userGuid') alınamadı. JSON: $json",
      );
      // Bu durumda geçici bir ID atamak yerine hata fırlatmak veya null döndürmek daha iyi olabilir.
      // Ancak AuthProvider'daki mantığa göre _userId null kalırsa sorun yaratabilir.
      // Şimdilik AuthProvider JWT'den 'sub' claim'ini önceliklendiriyor.
    }

    return UserInfoData(
      backendSpecificUserId: userIdFromBackend,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      gender: json['gender'] as int?,
      role: json['role'] as int?,
      photoUrl: json['photo'] as String?,
      registrationDateTime:
          json['createdDate'] != null
              ? DateTime.tryParse(json['createdDate'] as String)
              : null,
    );
  }

  UserRole get userRoleEnum {
    if (role == null) return UserRole.guest;
    switch (role) {
      case 0: // Backend'den "Member" rolü için 0 (veya UserRole.user'a karşılık gelen sayı)
        return UserRole.user;
      case 1: // Backend'den "Mentor" rolü için 1
        return UserRole.mentor;
      case 2: // Backend'den "Admin" rolü için 2
        return UserRole.admin;
      default:
        print(
          "UserInfoData.userRoleEnum: Tanınmayan sayısal rol değeri -> '$role'",
        );
        return UserRole.guest;
    }
  }

  // Bu getter artık doğrudan backendSpecificUserId'yi döndürüyor.
  // AuthProvider'da _userId'yi doldurmak için JWT'deki 'sub' veya 'nameidentifier' claim'i öncelikli.
  // Eğer onlar yoksa ve UserInfoData'dan ID alınacaksa bu alan kullanılacak.
  String get getUserIdForProvider => backendSpecificUserId;
}
