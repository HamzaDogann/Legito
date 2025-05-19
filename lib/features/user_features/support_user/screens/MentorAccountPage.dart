// lib/features/user_features/support_user/screens/MentorAccountPage.dart
import 'package:flutter/material.dart';
import '../models/mentor_account_args.dart';
import '../../../../core/navigation/app_routes.dart';

class MentorAccountPage extends StatelessWidget {
  final MentorAccountArgs args;

  const MentorAccountPage({Key? key, required this.args}) : super(key: key);

  // Tema turuncu rengi (main.dart'tan alınabilir veya burada sabit tutulabilir)
  static const Color themeOrangeColor = Color(0xFFFF8128);

  @override
  Widget build(BuildContext context) {
    const double profileAvatarRadius = 46.0;
    const double profileFrameRadius = 50.0; // Dış çerçevenin/border'ın yarıçapı
    const double headerHeight = 100.0;
    const double avatarUpwardShift =
        profileFrameRadius - 12; // 50 - 12 = 38px yukarı (resmin çoğu görünsün)

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.supportUser);
            }
          },
        ),
        title: Text(args.mentorName, overflow: TextOverflow.ellipsis),
        titleSpacing: 0,
        centerTitle: false,
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  color: Colors.black,
                  height: headerHeight,
                  width: double.infinity,
                ),
                Positioned(
                  top: headerHeight - avatarUpwardShift,
                  child: CircleAvatar(
                    // Dış CircleAvatar (Border için)
                    radius: profileFrameRadius, // Dış dairenin yarıçapı
                    backgroundColor:
                        themeOrangeColor, // <<< TURUNCU BORDER RENGİ
                    child: CircleAvatar(
                      // İç CircleAvatar (Resim için)
                      radius:
                          profileAvatarRadius, // İç dairenin yarıçapı (dıştan biraz küçük)
                      // profileFrameRadius - borderKalinligi (50 - 4 = 46)
                      backgroundImage:
                          (args.mentorImage != null &&
                                  args.mentorImage!.startsWith('http'))
                              ? NetworkImage(args.mentorImage!)
                              : AssetImage(
                                    args.mentorImage ??
                                        'assets/default_mentor_image.png',
                                  )
                                  as ImageProvider,
                      onBackgroundImageError: (exception, stackTrace) {
                        print("Mentor profil resmi yüklenemedi: $exception");
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Avatarın altından başlaması gereken içeriği içeren Column'u da yukarı taşıyalım.
            Transform.translate(
              // Bu offset değerini ekran görüntünüze ve isteğinize göre ayarlayın.
              // Amaç, resim ile isim arasında istenen boşluğu bırakmak.
              offset: const Offset(
                0,
                -(profileAvatarRadius * 0.6) + 100,
              ), // Örneğin -25 + 10 = -15
              // (46 * 0.6) = ~27. -27 + 10 = -17
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      args.mentorName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      args.mentorEmail ?? 'E-posta bilgisi mevcut değil',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (args.mentorRoleLabel != null &&
                        args.mentorRoleLabel!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              themeOrangeColor, // Buton için de tema turuncusu
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              args.mentorRoleLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
