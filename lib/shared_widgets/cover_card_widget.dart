// lib/shared_widgets/cover_card_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';

class CoverCardWidget extends StatelessWidget {
  final double size;
  final BorderRadius borderRadius;
  final Gradient? gradient; // Resim yoksa ve bu verilmişse gösterilir
  final String?
  imageAssetPath; // Lokal asset yolu (örn: 'assets/images/default.png')
  final String? imageNetworkPath; // Ağdan resim URL'si
  final File? imageFile; // Cihazdan seçilen resim dosyası
  final IconData? iconData; // Resim ve gradient yoksa gösterilecek ikon
  final Color? iconColor; // İkon rengi
  final double?
  iconOrImageSize; // Asset içindeki ikonun veya resmin boyutu (genellikle size'dan küçük)

  const CoverCardWidget({
    Key? key,
    required this.size,
    required this.borderRadius,
    this.gradient,
    this.imageAssetPath,
    this.imageNetworkPath,
    this.imageFile,
    this.iconData, // Eğer imageAssetPath bir ikon değil de resim dosyasıysa bu kullanılmayabilir.
    this.iconColor,
    this.iconOrImageSize, // Eğer imageAssetPath bir resimse, bu boyutlandırma için kullanılabilir.
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImageProvider? effectiveImageProvider;
    Widget? errorPlaceholder;

    if (imageFile != null && imageFile!.existsSync()) {
      try {
        effectiveImageProvider = FileImage(imageFile!);
      } catch (e) {
        print(
          "CoverCardWidget: FileImage yüklenemedi. Path: ${imageFile!.path}, Hata: $e",
        );
        errorPlaceholder = _buildErrorPlaceholder();
      }
    } else if (imageNetworkPath != null && imageNetworkPath!.isNotEmpty) {
      if (Uri.tryParse(imageNetworkPath!)?.isAbsolute == true) {
        effectiveImageProvider = NetworkImage(imageNetworkPath!);
      } else {
        print("CoverCardWidget: Geçersiz Network URL: $imageNetworkPath");
        errorPlaceholder = _buildErrorPlaceholder();
      }
    } else if (imageAssetPath != null && imageAssetPath!.isNotEmpty) {
      // imageAssetPath'in var olup olmadığını kontrol etmek zor, AssetImage kendisi hata yönetir.
      effectiveImageProvider = AssetImage(imageAssetPath!);
    }

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias, // Köşeleri düzgün kesmek için
      decoration: BoxDecoration(
        gradient:
            effectiveImageProvider == null && errorPlaceholder == null
                ? gradient
                : null, // Sadece resim/hata yoksa gradient
        borderRadius: borderRadius,
        image:
            (effectiveImageProvider != null && errorPlaceholder == null)
                ? DecorationImage(
                  image: effectiveImageProvider,
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Bu onError, NetworkImage ve FileImage için çalışır.
                    // AssetImage için bu callback tetiklenmez, var olmayan asset durumunda Flutter framework'ü hata verir.
                    print(
                      "CoverCardWidget: DecorationImage onError. Hata: $exception",
                    );
                    // Hata durumunda UI'ı güncellemek için setState gerekebilir (eğer stateful bir parent'ta ise)
                    // Şimdilik sadece logluyoruz ve errorPlaceholder (varsa) gösterilecek.
                    // effectiveImageProvider'ı null yaparak gradient veya ikona düşmesini sağlayabiliriz.
                    // Ancak bu build anında setState çağıramayacağımız için placeholder daha iyi.
                  },
                )
                : null,
        boxShadow: [
          // Hafif bir gölge
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        color:
            (effectiveImageProvider == null &&
                    errorPlaceholder == null &&
                    gradient == null &&
                    iconData == null)
                ? Colors
                    .grey
                    .shade200 // Her şey boşsa hafif bir arka plan
                : null,
      ),
      child:
          (errorPlaceholder != null)
              ? errorPlaceholder // Resim yükleme hatası varsa placeholder'ı göster
              : (effectiveImageProvider == null && iconData != null)
              ? Center(
                // Resim yoksa ve ikon varsa ikonu göster
                child: Icon(
                  iconData,
                  size: iconOrImageSize ?? size * 0.6, // İkon boyutunu ayarla
                  color:
                      iconColor ??
                      (gradient != null ? Colors.white : Colors.grey.shade600),
                ),
              )
              : (effectiveImageProvider == null &&
                  gradient == null &&
                  iconData == null &&
                  imageAssetPath != null &&
                  imageAssetPath!.isNotEmpty)
              // Bu durum, imageAssetPath verildi ama AssetImage yüklenemedi (çok nadir)
              // veya imageAssetPath bir resim dosyası ve iconData verilmediyse.
              // Eğer imageAssetPath bir resimse ve iconData yoksa, bu blok bir placeholder gösterebilir.
              // Şimdilik, imageAssetPath'in DecorationImage içinde halledildiğini varsayıyoruz.
              // Eğer imageAssetPath verilip effectiveImageProvider null kalıyorsa (asset bulunamadıysa)
              // ve gradient/icon da yoksa, bir placeholder göster.
              ? _buildErrorPlaceholder(icon: Icons.broken_image_outlined)
              : null, // Resim varsa veya gradient varsa (ve ikon yoksa) içerik boş
    );
  }

  Widget _buildErrorPlaceholder({
    IconData icon = Icons.image_not_supported_outlined,
  }) {
    return Container(
      color: Colors.grey.shade300, // Hata durumunda hafif bir arka plan
      child: Center(
        child: Icon(icon, size: size * 0.5, color: Colors.grey.shade600),
      ),
    );
  }
}
