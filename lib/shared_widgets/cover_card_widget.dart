// widgets/cover_card_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';

class CoverCardWidget extends StatelessWidget {
  final double size;
  final BorderRadius borderRadius;
  final Gradient? gradient;
  final String? imageAssetPath;
  final File? imageFile;
  final double?
  iconOrImageSize; // Bu hala opsiyonel, ama varsayılanı değiştirebiliriz
  final Color? iconColor;
  final Widget? child;
  final Color?
  backgroundColor; // Resim veya gradient olmadığında arka plan rengi
  final List<BoxShadow>? boxShadow; // Daha soft bir görünüm için gölge

  const CoverCardWidget({
    super.key,
    required this.size,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(16.0),
    ), // Biraz daha yuvarlak
    this.gradient,
    this.imageAssetPath,
    this.imageFile,
    this.iconOrImageSize,
    this.iconColor,
    this.child,
    this.backgroundColor, // Varsayılan olarak null
    this.boxShadow = const [
      // Varsayılan soft gölge
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.08), // Daha yumuşak bir siyah
        blurRadius: 20.0, // Daha yayvan bir blur
        offset: Offset(0, 4), // Hafif aşağıda
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    Widget? cardContent;

    // İçerideki resim/ikon için varsayılan oransal boyut
    // Daha soft bir görünüm için biraz daha küçük bir oran tercih edilebilir
    final double defaultInternalSize =
        size * 0.65; // Önceki 0.75'ten biraz daha küçük
    final double actualInternalSize = iconOrImageSize ?? defaultInternalSize;

    if (child != null) {
      cardContent = Center(child: child); // Child'ı her zaman ortala
    } else if (imageFile != null && imageFile!.existsSync()) {
      // Dosyadan resim gösteriliyorsa, gradient'i gösterme
      cardContent = Image.file(
        imageFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (imageAssetPath != null) {
      // Asset'ten resim/ikon gösteriliyorsa
      cardContent = Center(
        child: Image.asset(
          imageAssetPath!,
          width: actualInternalSize,
          height: actualInternalSize,
          color: iconColor,
          fit: BoxFit.contain, // Genellikle ikonlar için contain daha iyidir
          // İkonun keskinliğini korumak için filtre kalitesi (opsiyonel)
          // filterQuality: FilterQuality.medium,
        ),
      );
    }

    // Arka planı belirle
    BoxDecoration decoration = BoxDecoration(
      borderRadius: borderRadius,
      boxShadow: boxShadow,
    );

    if (imageFile != null && imageFile!.existsSync()) {
      // Dosya resmi varsa, gradient veya arka plan rengi uygulanmaz,
      // resim kendisi arka planı oluşturur (ClipRRect ile).
      // Gölge hala uygulanabilir.
    } else if (gradient != null) {
      decoration = decoration.copyWith(gradient: gradient);
    } else {
      // Gradient yoksa, belirtilen backgroundColor veya varsayılan bir renk kullanılır
      decoration = decoration.copyWith(
        color: backgroundColor ?? Colors.grey.shade200,
      );
    }

    return Container(
      width: size,
      height: size, // Yükseklik hala size ile aynı (kare kart)
      decoration: decoration,
      child: ClipRRect(
        borderRadius: borderRadius,
        child:
            cardContent ??
            Container(
              // Eğer cardContent null ise (yani ne child, ne imageFile, ne de imageAssetPath varsa)
              // ve gradient de yoksa, decoration'daki backgroundColor zaten uygulanmış olacak.
              // Bu yüzden buradaki Container boş olabilir veya ek bir placeholder içerebilir.
              // Örneğin, bir ikon placeholder'ı:
              // child: (decoration.gradient == null && decoration.image == null)
              //     ? Icon(Icons.image_not_supported_outlined, size: actualInternalSize * 0.7, color: Colors.grey.shade400)
              //     : null,
            ),
      ),
    );
  }
}
