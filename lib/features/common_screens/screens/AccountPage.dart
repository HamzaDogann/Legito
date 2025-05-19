// lib/features/common_screens/screens/AccountPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için eklendi
import 'package:intl/date_symbol_data_local.dart'; // Türkçe ay isimleri için eklendi

import '../../../core/navigation/app_routes.dart';
import '../../../state_management/auth_provider.dart';

class AccountPage extends StatefulWidget {
  // StatelessWidget'tan StatefulWidget'a dönüştü
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // State sınıfı eklendi
  // Renk Sabitleri
  static const Color pageBackgroundColor = Color(0xFFF4F6F9);
  static const Color profileHeaderBackgroundColor = Colors.black;
  static const Color profileImageBorderColor = Colors.white;
  static const Color primaryTextColor = Color(0xFF1F2937);
  static const Color secondaryTextColor = Colors.grey;
  static const Color accentColor = Color(0xFFFF8128);
  static const Color listItemBackgroundColor = Colors.white;
  static const Color listItemIconColor = Colors.black87;
  static const Color listItemTextColor = Colors.black87;
  static const Color listItemTrailingIconColor = Colors.grey;
  static const Color logoutButtonColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    // Türkçe tarih formatlaması için initialize et
    initializeDateFormatting('tr_TR', null);
  }

  String _formatRegistrationDate(DateTime? regDate) {
    if (regDate == null) {
      return 'Kayıt tarihi bilinmiyor';
    }
    // 'tr_TR' locale'i ile "MMMM yyyy tarihinde katıldı" formatında
    // Örnek: "Mayıs 2024 tarihinde katıldı"
    final formatter = DateFormat('MMMM yyyy', 'tr_TR');
    return '${formatter.format(regDate)} tarihinde katıldı';
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'nhrr.software@gmail.com',
      queryParameters: {'subject': 'Uygulama Geri Bildirimi'},
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'E-posta uygulaması açılamadı';
      }
    } catch (e) {
      print('E-posta başlatma hatası: $e');
      if (mounted) {
        // mounted kontrolü eklendi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'E-posta uygulaması bulunamadı veya bir hata oluştu.',
            ),
          ),
        );
      }
    }
  }

  void _shareApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paylaşma özelliği henüz eklenmedi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Oturum kontrolü ve yönlendirme
    if (!authProvider.isAuthenticated && authProvider.isLoading == false) {
      // isLoading kontrolü eklendi
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // mounted kontrolü eklendi
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      });
      // Yönlendirme sırasında boş bir Scaffold veya yükleme göstergesi
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // AuthProvider hala yükleniyorsa (örneğin checkAuthStatus çalışıyorsa)
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Bu noktada isAuthenticated true olmalı, yine de bir güvenlik önlemi olarak tekrar kontrol edilebilir.
    // Ama yukarıdaki blok bu durumu yönetiyor olmalı.

    const String placeholderProfileImage = 'assets/images/Profilimg.png';
    final String displayName =
        authProvider.displayName ?? 'Kullanıcı Adı'; // Daha kısa bir varsayılan
    final String email =
        authProvider.email ?? 'E-posta Yok'; // Daha kısa bir varsayılan
    final String registrationDateFormatted = _formatRegistrationDate(
      authProvider.userCreationDate,
    );

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text('Hesabım'),
        titleSpacing: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(height: 70, color: profileHeaderBackgroundColor),
              Positioned(
                top: 20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: profileImageBorderColor,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        (authProvider.profilePhotoUrl != null &&
                                authProvider
                                    .profilePhotoUrl!
                                    .isNotEmpty && // Boş string kontrolü eklendi
                                authProvider.profilePhotoUrl!.startsWith(
                                  'http',
                                ))
                            ? Image.network(
                              authProvider.profilePhotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print("Profil resmi yüklenemedi: $error");
                                return Image.asset(
                                  placeholderProfileImage,
                                  fit: BoxFit.cover,
                                );
                              },
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                );
                              },
                            )
                            : Image.asset(
                              placeholderProfileImage,
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 60,
          ), // Profil resmi ile altındaki metinler arası boşluk
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  registrationDateFormatted, // Dinamik tarih
                  style: const TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 0.5, indent: 20, endIndent: 20),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuButton(
                  context: context,
                  icon: Icons.settings_outlined,
                  label: 'Ayarlar',
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.accountSettings,
                      ),
                ),
                _buildMenuButton(
                  context: context,
                  icon: Icons.info_outline,
                  label: 'Hakkımızda',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.aboutUs),
                ),
                _buildMenuButton(
                  context: context,
                  icon: Icons.help_outline,
                  label: 'Yardım Merkezi',
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.assistanceCenter,
                      ),
                ),
                _buildMenuButton(
                  context: context,
                  icon: Icons.mail_outline,
                  label: 'Geri Bildirim Gönder',
                  onTap: () => _launchEmail(context),
                ),
                _buildMenuButton(
                  context: context,
                  icon: Icons.share_outlined,
                  label: 'Arkadaşlarını Davet Et',
                  onTap: () => _shareApp(context),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logoutButtonColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      // AuthProvider'dan logout işlemini çağır
                      await Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).logout();
                      // Logout sonrası Login sayfasına yönlendir ve geçmişi temizle
                      if (mounted) {
                        // mounted kontrolü eklendi
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: listItemBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: listItemIconColor, size: 24),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: listItemTextColor,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: listItemTrailingIconColor,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
