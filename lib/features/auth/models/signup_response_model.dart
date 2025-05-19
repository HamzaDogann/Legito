// lib/features/auth/models/signup_response_model.dart
class SignUpResponseModel {
  final bool isSuccess;
  final String? message;
  // API'den dönen başka veriler varsa (örn: kullanıcı ID'si) buraya eklenebilir
  // final dynamic data; // Örneğin

  SignUpResponseModel({
    required this.isSuccess,
    this.message,
    // this.data,
  });

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    // Bu kısım API'nizin tam yanıt yapısına göre ayarlanmalıdır.
    // Örnek bir ASP.NET Core yanıtı için:
    // {
    //   "isSuccess": true,
    //   "message": "Kayıt başarılı.",
    //   "errors": null, // veya hata durumunda {"fieldName": ["error message"]}
    //   "data": null // veya { "userId": "..." }
    // }
    return SignUpResponseModel(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] as String?,
      // data: json['data'],
    );
  }

  factory SignUpResponseModel.failure(String message) {
    return SignUpResponseModel(isSuccess: false, message: message);
  }
}
