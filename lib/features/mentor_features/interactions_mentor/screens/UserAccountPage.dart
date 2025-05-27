import 'package:flutter/material.dart';
import '../models/user_account_args.dart'; // Args sınıfını import et
import '../../../../core/navigation/app_routes.dart'; // Geri butonu fallback için
import '../../../../shared_widgets/user_stats_card_widget.dart';

class UserAccountPage extends StatelessWidget {
  final UserAccountArgs args;

  // Renk Sabitleri
  static const Color _pageBackground = Color(0xFFF4F6F9);
  static const Color _headerBackground = Color.fromARGB(255, 23, 23, 23);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _roleButtonBackground = Color(0xFFFF8128);
  static const Color _roleButtonText = Colors.white;
  static const Color _dividerColor = Color(0xFFE5E7EB);

  const UserAccountPage({Key? key, required this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double profileImageRadius = 55.0;
    const double profileImageFrameRadius = profileImageRadius + 4;
    const double headerHeight = 110.0;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.mentorHome);
            }
          },
        ),
        title: const Text('Kullanıcı Bilgileri'),
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
                  color: _headerBackground,
                  height: headerHeight,
                  width: double.infinity,
                ),
                Positioned(
                  top: headerHeight - profileImageFrameRadius,
                  child: CircleAvatar(
                    radius: profileImageFrameRadius,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: profileImageRadius,
                      backgroundImage:
                          (args.userImage.startsWith('http'))
                              ? NetworkImage(args.userImage)
                              : AssetImage(args.userImage) as ImageProvider,
                      onBackgroundImageError: (exception, stackTrace) {
                        print(
                          "Profil resmi yüklenemedi (UserAccountPage): $exception",
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: profileImageFrameRadius + 12),
            Text(
              args.userName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              args.userEmail,
              style: const TextStyle(fontSize: 16, color: _textGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _roleButtonBackground,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: _roleButtonText,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    args.userRole,
                    style: const TextStyle(
                      color: _roleButtonText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ), // Rol butonu ile istatistikler arasına boşluk
            // <<< YENİ KONUM: StatsGrid ve ChartsSection buraya taşındı >>>
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: LayoutBuilder(
                // LayoutBuilder hala kullanılabilir, eğer child'lar responsive ise
                builder: (context, constraints) {
                  // labelMaxWidth hesaplaması StatsGrid içinde yapılıyorsa veya gerekmiyorsa kaldırılabilir.
                  // Eğer StatsGrid bu parametreyi bekliyorsa, doğru bir şekilde hesaplayın.
                  double labelMaxWidth =
                      (constraints.maxWidth / 2) - 40; // Örnek hesaplama

                  return Column(
                    children: [
                      // TODO: StatsGrid ve ChartsSection'a kullanıcıya özel veriler (args.userId gibi)
                      //       parametre olarak geçilebilir veya bu widget'lar kendi içlerinde
                      //       bu ID'yi kullanarak veri çekebilirler.
                      StatsGrid(
                        labelMaxWidth: labelMaxWidth,
                      ), // labelMaxWidth'i StatsGrid'e göre ayarlayın
                      const SizedBox(
                        height: 24,
                      ), // İstatistikler ve grafikler arasına boşluk
                      const ChartsSection(),
                    ],
                  );
                },
              ),
            ),

            // <<< StatsGrid ve ChartsSection buraya taşındı (BİTİŞ) >>>
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
