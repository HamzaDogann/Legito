// lib/features/mentor_features/tips_mentor/models/create_update_tip_request_dto.dart

class CreateUpdateTipRequestDto {
  final String title;
  final String content;
  final int avatar; // ApiTipAvatar enum'ının index'i

  CreateUpdateTipRequestDto({
    required this.title,
    required this.content,
    required this.avatar,
  });

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content, 'avatar': avatar};
  }
}
