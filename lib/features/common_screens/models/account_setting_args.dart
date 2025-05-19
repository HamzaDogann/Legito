// lib/features/common_screens/models/account_setting_args.dart
// Bu sayfa için şimdilik özel bir argüman gerekmeyebilir,
// ancak ileride ihtiyaç olursa diye bu yapı kullanılabilir.
class AccountSettingArgs {
  final String
  userId; // Ayarları yapılan kullanıcının ID'si (AuthProvider'dan da alınabilir)

  AccountSettingArgs({required this.userId});
}
