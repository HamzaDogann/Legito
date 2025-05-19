// lib/core/enums/user_role.dart
enum UserRole {
  guest,
  user, // Backend'den gelen sayısal role göre bu "Member" olabilir
  mentor,
  admin;

  static UserRole fromString(String? roleString) {
    // Bu metod, eğer UserInfo'dan string rol gelirse kullanılacak.
    // Şu an sayısal rol geldiği için UserInfoData.userRoleEnum daha kritik.
    if (roleString == null) return UserRole.guest;
    switch (roleString.trim().toLowerCase()) {
      case 'user':
      case 'member': // Backend "Member" string'ini gönderiyorsa
        return UserRole.user;
      case 'mentor':
        return UserRole.mentor;
      case 'admin':
        return UserRole.admin;
      default:
        print("UserRole.fromString: Tanınmayan rol string'i -> '$roleString'");
        return UserRole.guest;
    }
  }
}
