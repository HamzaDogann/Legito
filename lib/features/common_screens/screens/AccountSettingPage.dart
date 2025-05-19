// lib/features/common_screens/screens/AccountSettingPage.dart
import 'dart:io'; // File için
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../state_management/auth_provider.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({Key? key}) : super(key: key);

  @override
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  bool _notificationsEnabled = true; // Bu özellik API'ye bağlanmadı, sadece UI
  File? _pickedImageFile; // Seçilen yeni resim dosyası
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    // Oturum kontrolü, eğer kullanıcı login değilse login sayfasına yönlendir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      }
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Kalite %70
        maxWidth: 800, // Maksimum genişlik
        maxHeight: 800, // Maksimum yükseklik
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImageFile = File(pickedFile.path);
          _isUploadingPhoto = true; // Yükleme başladı
        });

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.clearOperationError();
        bool success = await authProvider.updateUserPhoto(_pickedImageFile!);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil fotoğrafı başarıyla güncellendi!'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _pickedImageFile = null;
            }); // Başarılı yükleme sonrası seçimi sıfırla
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Fotoğraf yükleme hatası: ${authProvider.operationError ?? "Bilinmeyen sorun."}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isUploadingPhoto = false;
          }); // Yükleme bitti
        }
      }
    } catch (e) {
      print('Resim seçme/yükleme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resim seçilirken veya yüklenirken bir hata oluştu.'),
          ),
        );
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider'ı dinleyerek displayName, email, profilePhotoUrl değişikliklerinde UI'ı güncelle
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated && !authProvider.isLoading) {
      // initState'te yönlendirme yapılıyor, bu bir fallback.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (authProvider.isLoading && authProvider.displayName == null) {
      // İlk yükleme gibi
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ImageProvider currentProfileImageProvider;
    if (_pickedImageFile != null) {
      currentProfileImageProvider = FileImage(_pickedImageFile!);
    } else if (authProvider.profilePhotoUrl != null &&
        authProvider.profilePhotoUrl!.isNotEmpty &&
        authProvider.profilePhotoUrl!.startsWith('http')) {
      currentProfileImageProvider = NetworkImage(authProvider.profilePhotoUrl!);
    } else {
      currentProfileImageProvider = const AssetImage(
        'assets/images/Profilimg.png',
      ); // Varsayılan resim
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Ayarları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                  child:
                      _isUploadingPhoto
                          ? Container(
                            // Yükleme sırasında overlay
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                          : null,
                ),
                if (!_isUploadingPhoto) // Yükleme sırasında butonu gizle
                  Positioned(
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2.0,
                      child: InkWell(
                        onTap: _pickAndUploadImage,
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
            onTap: () => Navigator.pushNamed(context, AppRoutes.updateUser),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Şifre Değiştir',
            onTap: () => Navigator.pushNamed(context, AppRoutes.updatePassword),
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
              setState(() => _notificationsEnabled = value);
              // TODO: Bildirim ayarını kaydet (API veya lokal)
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
