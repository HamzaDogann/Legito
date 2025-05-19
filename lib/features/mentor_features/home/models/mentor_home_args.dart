// lib/features/mentor_features/home/models/mentor_home_args.dart

class MentorHomeArgs {
  final String mentorId; // Giriş yapan mentorun kimliği
  final String mentorName; // Mentorun adı (belki karşılama mesajı için)
  final int? pendingTaskCount; // Bekleyen görev sayısı (opsiyonel)
  final String? lastActivity; // Son aktivite özeti (opsiyonel)

  MentorHomeArgs({
    required this.mentorId,
    required this.mentorName,
    this.pendingTaskCount,
    this.lastActivity,
  });
}
