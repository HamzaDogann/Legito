// lib/features/user_features/techniques_user/models/lesson_detail_args.dart

class LessonDetailArgs {
  final String
  lessonId; // Dersin veya tekniğin benzersiz kimliği (API'den detayları çekmek için)
  final String videoUrl; // Oynatılacak videonun URL'i
  final String title; // Dersin başlığı (AppBar'da ve içerikte gösterilecek)
  final String? description; // Dersin açıklaması (opsiyonel)
  final bool
  initialFavoriteState; // Kullanıcının bu dersi daha önce beğenip beğenmediği
  final String?
  viewCount; // Görüntülenme sayısı (String olarak alıp sayfada formatlayabiliriz)
  final String? likeCount; // Beğeni sayısı
  final String?
  publishDate; // Yayınlanma tarihi (String veya DateTime olarak alınıp formatlanabilir)
  final String? mentorName;
  final String? coverImageUrl;

  LessonDetailArgs({
    required this.lessonId,
    required this.videoUrl,
    required this.title,
    this.description,
    this.initialFavoriteState = false,
    this.viewCount,
    this.likeCount,
    this.publishDate,
    this.mentorName,
    this.coverImageUrl,
  });
}
