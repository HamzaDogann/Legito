// lib/features/auth/models/register_request_model.dart
class RegisterRequestModel {
  final String displayName;
  final String email;
  final String password;
  final String passwordAgain; // Backend bunu istiyorsa
  final int
  gender; // 0: Erkek, 1: Kadın, 2: Belirtmek İstemiyor (API'nizin beklentisine göre)
  final String birthDate; // "YYYY-MM-DD" formatında

  RegisterRequestModel({
    required this.displayName,
    required this.email,
    required this.password,
    required this.passwordAgain,
    required this.gender,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'password': password,
      'passwordAgain':
          passwordAgain, // Eğer backend istemiyorsa bu satırı kaldırın.
      'gender': gender,
      'birthDate': birthDate,
    };
  }
}
