// lib/features/mentor_features/tips_mentor/models/tip_response_dto.dart

class TipResponseDto {
  final String id;
  final String title;
  final String content;
  final int avatar; // API'den gelen int (ApiTipAvatar enum'ının index'i)

  TipResponseDto({
    required this.id,
    required this.title,
    required this.content,
    required this.avatar,
  });

  factory TipResponseDto.fromJson(Map<String, dynamic> json) {
    // API'den gelen alan adlarının buradakilerle eşleştiğinden emin olun.
    // Örneğin, API 'tipId' dönüyorsa: json['tipId'] as String
    return TipResponseDto(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      avatar: json['avatar'] as int,
    );
  }

  // İsteğe bağlı: toJson metodu (Eğer bu objeyi API'ye gönderecekseniz, ama genellikle bu response için gerekmez)
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'content': content,
  //     'avatar': avatar,
  //   };
  // }
}
