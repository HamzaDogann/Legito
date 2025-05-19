// lib/features/user_features/account/models/update_user_request_model.dart

class UpdateUserRequestModel {
  final String? displayName; // Opsiyonel olarak güncellenebilir
  final String? email; // Opsiyonel
  final int?
  gender; // Opsiyonel (0: Erkek, 1: Kadın, vb. API'nizin enum'una göre)
  final String? birthDate; // Opsiyonel, "YYYY-MM-DD" formatında

  UpdateUserRequestModel({
    this.displayName,
    this.email,
    this.gender,
    this.birthDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['displayName'] = displayName;
    if (email != null) data['email'] = email;
    if (gender != null) data['gender'] = gender;
    if (birthDate != null) data['birthDate'] = birthDate;
    return data;
  }
}
