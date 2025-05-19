// lib/features/user_features/account/models/update_password_request_model.dart

class UpdatePasswordRequestModel {
  final String currentPassword;
  final String newPassword;
  final String newPasswordAgain;

  UpdatePasswordRequestModel({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordAgain,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'newPasswordAgain': newPasswordAgain,
    };
  }
}
