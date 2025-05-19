// lib/features/user_features/account/models/update_user_photo_request_model.dart

class UpdateUserPhotoRequestModel {
  final String base64Content;

  UpdateUserPhotoRequestModel({required this.base64Content});

  Map<String, dynamic> toJson() {
    return {'base64Content': base64Content};
  }
}
