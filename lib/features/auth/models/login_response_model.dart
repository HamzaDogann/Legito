// lib/features/auth/models/login_response_model.dart

class LoginResponseModel {
  final bool isSuccess;
  final String? message;
  final LoginData? data;
  final List<String>? errors;
  final int? statusCode;

  LoginResponseModel({
    required this.isSuccess,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // API'nizin /Auth/SignInEmail endpoint'inden dönen JSON yapısına göre bu kısım ayarlanmalı.
    // Başarılı bir yanıtın şöyle olduğunu varsayalım:
    // {
    //   "isSuccess": true,
    //   "message": "Giriş başarılı.",
    //   "data": {
    //     "accessToken": "eyJhbGciOiJIUz...",
    //     "refreshToken": "_R3fr3sH_T0k3n_"
    //   },
    //   "errors": null,
    //   "statusCode": 200
    // }
    //
    // Veya hata yanıtı:
    // {
    //   "isSuccess": false,
    //   "message": "E-posta veya şifre hatalı.",
    //   "data": null,
    //   "errors": ["Invalid credentials"],
    //   "statusCode": 400
    // }

    // 'data'nın varlığı ve içindeki 'accessToken'ın dolu olması da bir başarı göstergesi olabilir.
    // Ancak API'niz doğrudan 'isSuccess' alanı dönüyorsa, onu kullanmak daha güvenilir.
    bool success =
        json['isSuccess'] ??
        (json['data'] != null &&
            json['data']['accessToken'] != null &&
            (json['data']['accessToken'] as String).isNotEmpty &&
            (json['statusCode'] == 200 || json['statusCode'] == null));

    return LoginResponseModel(
      isSuccess: success,
      message: json['message'] as String?,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      statusCode: json['statusCode'] as int?,
    );
  }

  // Eksik olan failure constructor'ı
  factory LoginResponseModel.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return LoginResponseModel(
      isSuccess: false,
      message: message,
      data: null,
      errors: errors,
      statusCode: statusCode,
    );
  }
}

class LoginData {
  final String accessToken;
  final String? refreshToken; // refreshToken null olabilir

  LoginData({required this.accessToken, this.refreshToken});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    // accessToken'ın null veya boş olmaması önemli
    final String token = json['accessToken'] as String? ?? '';
    if (token.isEmpty) {
      // Bu durum genellikle bir hatayı işaret eder, loglanabilir.
      // Ancak LoginResponseModel'in genel isSuccess durumu bunu yönetmeli.
      print(
        "LoginData.fromJson UYARI: 'accessToken' null veya boş geldi. JSON: $json",
      );
    }
    return LoginData(
      accessToken: token,
      refreshToken: json['refreshToken'] as String?,
    );
  }
}
