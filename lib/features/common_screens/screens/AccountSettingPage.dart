// lib/features/common_screens/screens/AccountSettingPage.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_routes.dart'; // AppRoutes importu
import '../../../state_management/auth_provider.dart'; // AuthProvider importu
// import '../models/account_setting_args.dart'; // Eğer argüman sınıfı kullanılacaksa

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({Key? key}) : super(key: key);

  @override
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  bool _notificationsEnabled = true;
  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedImageFile = File(pickedFile.path);
        });
        print('Seçilen resim: ${pickedFile.path}');
        // TODO: Seçilen resmi backend'e yükle
      }
    } catch (e) {
      print('Resim seçme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resim seçilirken bir hata oluştu.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ImageProvider currentProfileImageProvider;
    if (_pickedImageFile != null) {
      currentProfileImageProvider = FileImage(_pickedImageFile!);
    } else if (authProvider.profilePhotoUrl != null &&
        authProvider.profilePhotoUrl!.startsWith('http')) {
      currentProfileImageProvider = NetworkImage(authProvider.profilePhotoUrl!);
    } else {
      currentProfileImageProvider = const AssetImage(
        'assets/images/Profilimg.png',
      );
    }

    return Scaffold(
      appBar: AppBar(
        // backgroundColor, foregroundColor, titleTextStyle, iconTheme, elevation
        // gibi özellikler belirtilmediği için main.dart'taki appBarTheme'den alınacaktır.
        title: const Text('Kullanıcı Ayarları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Renk temadan gelecek
          onPressed: () => Navigator.pop(context),
        ),
        // titleSpacing: 0, // İsteğe bağlı, başlığı sola yaklaştırır
        // centerTitle: false, // İsteğe bağlı, başlığı sola yaslar
        // elevation: 0.5, // main.dart'taki temada zaten 0.5 olarak ayarlıydı.
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: currentProfileImageProvider,
                  onBackgroundImageError: (exception, stackTrace) {
                    print("Profil resmi yüklenemedi: $exception");
                  },
                ),
                Positioned(
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2.0,
                    child: InkWell(
                      onTap: _pickImage,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.edit,
                          size: 20,
                          color: Color(0xFFFF8128),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              authProvider.displayName ?? "Kullanıcı Adı",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              authProvider.email ?? "kullanici@eposta.com",
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 32),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Kullanıcı Bilgilerini Güncelle',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.updateUser);
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Şifre Değiştir',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.updatePassword);
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(
              Icons.notifications_outlined,
              color: Colors.black54,
            ),
            title: const Text(
              'Bildirimleri Aç/Kapat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              print('Bildirim ayarı: $value');
              // TODO: Bildirim ayarını kaydet
            },
            activeColor: const Color(0xFFFF8128),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 4,
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              )
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    );
  }
}
