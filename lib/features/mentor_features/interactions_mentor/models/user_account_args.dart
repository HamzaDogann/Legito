// lib/features/mentor_features/interactions_mentor/models/user_account_args.dart

class UserAccountArgs {
  final String userId; // Kullanıcının benzersiz kimliği
  final String userName; // Kullanıcının adı
  final String userImage; // Kullanıcının profil resmi yolu (Asset veya Network)
  final String userEmail; // Kullanıcının e-posta adresi
  final String
  userRole; // Kullanıcının rol etiketi (Örn: "Kullanıcı", "Öğrenci")
  // İstatistikler veya diğer grafik verileri de buraya eklenebilir veya
  // userId kullanılarak sayfada API'den çekilebilir.

  UserAccountArgs({
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.userEmail,
    required this.userRole,
  });
}
