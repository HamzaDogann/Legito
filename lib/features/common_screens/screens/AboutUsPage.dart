// lib/features/common_screens/screens/AboutUsPage.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// AuthProvider ve AppRoutes importları gerekebilir (yetkilendirme ve geri butonu için)
import '../../../core/navigation/app_routes.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  Future<void> _launchURL(BuildContext context, String url) async {
    // SnackBar için context eklendi
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Bağlantı açılamıyor: $url';
      }
    } catch (e) {
      print("URL başlatma hatası: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bağlantı açılamadı: $url')));
      }
    }
  }

  Widget _iconButton(BuildContext context, IconData icon, String url) {
    // context eklendi
    return InkWell(
      onTap: () => _launchURL(context, url), // context geçirildi
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Renk biraz daha belirgin yapıldı
          borderRadius: BorderRadius.circular(8),
        ),
        child: FaIcon(icon, size: 18, color: Colors.black87), // Renk ayarlandı
      ),
    );
  }

  Widget buildProfileCard({
    required BuildContext context, // context eklendi
    required String imagePath,
    required String name,
    required String title,
    required String linkedinUrl,
    required String githubUrl,
    required String mailUrl,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(radius: 28, backgroundImage: AssetImage(imagePath)),
            const SizedBox(width: 12), // Boşluk artırıldı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ), // Renk eklendi
                  const SizedBox(height: 3), // Boşluk ayarlandı
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ), // Font boyutu ayarlandı
                ],
              ),
            ),
            Row(
              children: [
                _iconButton(
                  context,
                  FontAwesomeIcons.linkedin,
                  linkedinUrl,
                ), // context geçirildi
                const SizedBox(width: 8), // Boşluk ayarlandı
                _iconButton(
                  context,
                  FontAwesomeIcons.github,
                  githubUrl,
                ), // context geçirildi
                const SizedBox(width: 8), // Boşluk ayarlandı
                _iconButton(
                  context,
                  FontAwesomeIcons.envelope,
                  mailUrl,
                ), // context geçirildi
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProjectTitleCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 16), // Üst margin artırıldı
      elevation: 2,
      color: Colors.grey[100], // Renk biraz daha açık
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // Padding ayarlandı
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Proje Başlığı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Odaklanma ve Hızlı Okuma Becerisi Kazandırma Uygulaması",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                  height: 1.3,
                ), // Renk ve satır yüksekliği eklendi
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProjectDescriptionCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Üst margin kaldırıldı
      color: Colors.grey[100],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Proje Açıklaması',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 8), // Boşluk artırıldı
              Text(
                "Geliştirilen mobil uygulama; kullanıcıların okuma, odaklanma ve anlama becerilerini artırmak "
                "üzere göz takibi, dikkat egzersizleri, hızlı okuma testleri ve kişisel gelişim panelleri gibi özellikler sunmaktadır. "
                "Kullanıcılar, mobil uygulamanın bünyesinde barındırdığı pek çok özellik sayesinde düzenli bir okuma alışkanlığı kazanabiliyor.",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4B5563),
                  height: 1.4,
                ), // Renk ve satır yüksekliği
                textAlign: TextAlign.justify, // Metni iki yana yasla
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Yetkilendirme kontrolü (Bu sayfa için gerekli olmayabilir, ama örnek olarak eklendi)
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // if (!authProvider.isAuthenticated) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (context.mounted) {
    //       Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    //     }
    //   });
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    return Scaffold(
      // backgroundColor: Colors.grey[100], // Temadan scaffoldBackgroundColor gelebilir
      appBar: AppBar(
        // backgroundColor, foregroundColor, titleTextStyle, iconTheme, elevation
        // gibi özellikler belirtilmediği için main.dart'taki appBarTheme'den alınacaktır.
        title: const Text(
          "Hakkımızda",
        ), // Stil temadan (appBarTheme.titleTextStyle)
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ), // Renk temadan (appBarTheme.iconTheme veya foregroundColor)
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Hakkımızda sayfası genellikle bir ana sayfadan açılır,
              // ama doğrudan açılırsa diye bir fallback.
              Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
            }
          },
        ),
        // titleSpacing: 0, // İsteğe bağlı
        // centerTitle: false, // İsteğe bağlı
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProjectTitleCard(),
            buildProjectDescriptionCard(),
            // buildProfileCard metoduna context geçildi
            buildProfileCard(
              context: context,
              imagePath: 'assets/images/Profilimg2.png',
              name: 'Hamza Doğan',
              title: 'Frontend Developer',
              linkedinUrl: 'https://www.linkedin.com/in/hamzadogann/',
              githubUrl: 'https://github.com/HamzaDogann',
              mailUrl: 'mailto:hamzaalidogantr@gmail.com',
            ),
            buildProfileCard(
              context: context,
              imagePath: 'assets/images/Profilimg4.png',
              name: 'Ramazan Yiğit',
              title: 'Frontend Developer',
              linkedinUrl: 'https://www.linkedin.com/in/ramazanyiğit/',
              githubUrl: 'https://github.com/ramazanyigit18',
              mailUrl: 'mailto:rmnygt2002@gmail.com',
            ),
            buildProfileCard(
              context: context,
              imagePath: 'assets/images/Profilimg.png',
              name: 'Nazmi Koçak',
              title: 'Backend Developer',
              linkedinUrl: 'https://www.linkedin.com/in/nazmikocak/',
              githubUrl: 'https://github.com/nazmikocak',
              mailUrl: 'mailto:nazmikocak.dev@hotmail.com',
            ),
            buildProfileCard(
              context: context,
              imagePath: 'assets/images/Profilimg3.png',
              name: 'Rabia Yazlı',
              title: 'Backend Developer',
              linkedinUrl: 'https://www.linkedin.com/in/rabiayazlı34/',
              githubUrl: 'https://github.com/rabiay34',
              mailUrl: 'mailto:yazlirabiaa4@gmail.com',
            ),
            const SizedBox(height: 20), // Altta biraz boşluk
          ],
        ),
      ),
    );
  }
}
