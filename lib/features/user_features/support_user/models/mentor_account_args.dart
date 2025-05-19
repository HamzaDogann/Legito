// lib/features/user_features/support_user/models/mentor_account_args.dart

class MentorAccountArgs {
  final String mentorId; // Mentorun benzersiz kimliği (API işlemleri için)
  final String mentorName; // Mentorun adı
  final String mentorImage; // Mentorun profil resmi yolu (Asset veya Network)
  final String?
  mentorEmail; // Mentorun e-posta adresi (opsiyonel, sayfada gösteriliyor)
  final String?
  mentorRoleLabel; // Mentorun rol etiketi (sayfada "Mentor" olarak sabit, ama dinamik olabilir)

  MentorAccountArgs({
    required this.mentorId,
    required this.mentorName,
    required this.mentorImage,
    this.mentorEmail, // Eğer her zaman biliniyorsa required yapılabilir
    this.mentorRoleLabel = 'Mentor', // Varsayılan değer
  });
}
