// lib/features/shared_widgets/content_card_widget.dart
import 'package:flutter/material.dart';

class ContentCardWidget extends StatelessWidget {
  // SABİT BOYUTLAR
  static const double cardWidth = 140.0;
  static const double cardHeight = 180.0; // Yüksekliği biraz artırdık
  static const double infoBoxHeightRatio =
      0.35; // Kart yüksekliğinin %35'i bilgi kutusu için
  static const double coverAreaHeightRatio =
      1.0 - infoBoxHeightRatio; // Kalan kısım kapak için
  static const double iconSizeRatioToCoverArea =
      0.45; // Kapak alanının yüksekliğine göre ikon boyutu

  final Gradient? gradient;
  final ImageProvider? coverImage;
  final IconData? iconData;
  final String title;
  final String? subtitlePrefix;
  final String? subtitleText;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  // Renkler ve stiller için varsayılanlar (isterseniz bunları dışarıdan alabilirsiniz ama sadelik için şimdilik sabit)
  final Color cardInfoPrimaryTextColor;
  final Color cardInfoSecondaryTextColor;
  final Color cardInfoBackgroundColor;
  final Color iconColor;
  final BorderRadius borderRadius;
  final List<BoxShadow> boxShadow;

  const ContentCardWidget({
    Key? key,
    required this.title,
    this.gradient,
    this.coverImage,
    this.iconData,
    this.subtitlePrefix,
    this.subtitleText,
    this.onTap,
    this.onLongPress,
    this.cardInfoPrimaryTextColor = const Color.fromARGB(255, 27, 18, 18),
    this.cardInfoSecondaryTextColor = const Color(0xFF6B7280),
    this.cardInfoBackgroundColor = Colors.white,
    this.iconColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.boxShadow = const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.08),
        blurRadius: 15.0,
        offset: Offset(0, 3),
      ),
    ],
  }) : assert(
         (coverImage != null) || (gradient != null && iconData != null),
         'Either coverImage must be provided, or both gradient and iconData must be provided.',
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasSubtitle = (subtitleText != null && subtitleText!.isNotEmpty);
    final double actualInfoBoxHeight = cardHeight * infoBoxHeightRatio;
    final double actualCoverAreaHeight = cardHeight * coverAreaHeightRatio;
    final double actualIconSize =
        actualCoverAreaHeight * iconSizeRatioToCoverArea;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          // Eğer tam kapak resmi varsa gradient'i gösterme, resim öncelikli.
          // Gradient sadece ikonlu modda görünür.
          gradient: (coverImage == null && gradient != null) ? gradient : null,
          color:
              (coverImage == null && gradient == null)
                  ? Colors
                      .grey
                      .shade200 // Varsayılan arka plan (ikon ve gradient yoksa)
                  : null,
          borderRadius: borderRadius,
          boxShadow: boxShadow,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kapak Alanı (Resim veya İkonlu Gradient)
              SizedBox(
                width: cardWidth,
                height: actualCoverAreaHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (coverImage != null)
                      Image(
                        image: coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey.shade600,
                                size: actualIconSize * 0.8,
                              ),
                            ),
                          );
                        },
                      ),
                    if (coverImage == null &&
                        iconData != null &&
                        gradient != null)
                      Center(
                        child: Icon(
                          iconData!,
                          size: actualIconSize,
                          color: iconColor.withOpacity(0.9),
                        ),
                      ),
                    // Eğer ne resim ne de ikon varsa, boş bir alan veya placeholder gösterilebilir.
                    // Şu anki mantıkta bu durum assert ile engelleniyor.
                  ],
                ),
              ),

              // Bilgi Kutusu
              Container(
                height: actualInfoBoxHeight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cardInfoBackgroundColor,
                  // Alt köşeler yuvarlak kalmalı, üst köşeler düz olmalı çünkü kapak alanıyla birleşiyor.
                  // Ancak kartın genel borderRadius'u ClipRRect ile sağlanıyor.
                  // Bu yüzden burada ayrıca borderRadius'a gerek yok veya sadece altı belirtilebilir.
                  // Şimdilik genel ClipRRect yeterli.
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // İçeriği dikeyde ortala
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: cardInfoPrimaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Sabit tipografi boyutu
                      ),
                      maxLines: 1, // Başlık taşmasını engelle
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasSubtitle)
                      const SizedBox(height: 2), // Daha az boşluk
                    if (hasSubtitle)
                      Text(
                        "${subtitlePrefix ?? ""}${subtitleText ?? ""}",
                        style: TextStyle(
                          color: cardInfoSecondaryTextColor,
                          fontSize: 11, // Sabit tipografi boyutu
                        ),
                        maxLines: 1, // Alt başlık taşmasını engelle
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
