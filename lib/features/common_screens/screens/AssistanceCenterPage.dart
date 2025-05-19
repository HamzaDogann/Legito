// lib/features/common_screens/screens/AssistanceCenterPage.dart
import 'package:flutter/material.dart';
// AuthProvider ve AppRoutes importları (yetkilendirme ve geri butonu için)
// Bu sayfa için yetkilendirme zorunlu olmayabilir, duruma göre ekleyebilirsiniz.
// import 'package:provider/provider.dart';
// import '../../../state_management/auth_provider.dart';
import '../../../core/navigation/app_routes.dart';

class AssistanceCenterPage extends StatefulWidget {
  const AssistanceCenterPage({Key? key}) : super(key: key);

  @override
  State<AssistanceCenterPage> createState() => _AssistanceCenterPageState();
}

class _AssistanceCenterPageState extends State<AssistanceCenterPage> {
  int? _expandedIndex;

  final List<Map<String, String>> faqList = [
    {
      'question': 'Profil fotoğrafımı nasıl değiştirebilirim?',
      'answer':
          'Ayarlar sayfasında profil resminize tıklayarak galeriden yeni bir fotoğraf seçebilirsiniz.',
    },
    {
      'question': 'Adımı veya e-posta adresimi nasıl güncelleyebilirim?',
      'answer':
          'Ayarlar > Kullanıcı Bilgilerini Güncelle bölümünden bilgilerinizi değiştirebilirsiniz.',
    },
    {
      'question': 'Şifremi nasıl değiştirebilirim?',
      'answer':
          'Ayarlar > Şifre Değiştir sayfasına giderek yeni şifrenizi belirleyebilirsiniz.',
    },
    {
      'question': 'Bildirimleri nasıl açabilir veya kapatabilirim?',
      'answer':
          'Ayarlar sayfasındaki "Bildirimleri Aç/Kapat" seçeneği ile kontrol edebilirsiniz.',
    },
    {
      'question': 'Koyu (karanlık) modu nasıl aktif ederim?',
      'answer':
          'Ayarlar sayfasından tema tercihinizi değiştirerek koyu modu kullanabilirsiniz.',
    },
    {
      'question': 'Günlük hedeflerimi nereden görebilirim?',
      'answer':
          'Ana sayfadaki hedef kutucuğu üzerinden 10 hedefin tamamlanma durumunu takip edebilirsiniz.',
    },
    {
      'question': 'Uygulamaya her girişte oturum açmak gerekir mi?',
      'answer': 'Hayır, bir kez giriş yaptıktan sonra oturumunuz açık kalır.',
    },
    {
      'question': 'Odaklanma modunu nasıl aktif edebilirim?',
      'answer':
          'Ana ekranda bulunan "Odak Modu" butonuna tıklayarak modu başlatabilirsiniz.',
    },
    {
      'question': 'İlerlemelerim uygulamada nasıl kaydediliyor?',
      'answer':
          'Tüm tamamladığınız hedefler ve ayarlar otomatik olarak kaydedilir.',
    },
    {
      'question': 'Uygulamadan çıkış yapmak istersem ne yapmalıyım?',
      'answer':
          'Profil veya Ayarlar sayfasında bulunan "Çıkış Yap" seçeneğini kullanabilirsiniz.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Bu sayfa için yetkilendirme zorunlu değilse bu kısım kaldırılabilir.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
    //   if (!authProvider.isAuthenticated) {
    //     Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // if (!authProvider.isAuthenticated && widgetRequiresAuth) { // widgetRequiresAuth gibi bir kontrol eklenebilir
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    return Scaffold(
      // backgroundColor: Colors.grey[50], // Temadan scaffoldBackgroundColor gelebilir
      appBar: AppBar(
        // backgroundColor, foregroundColor, titleTextStyle, iconTheme, elevation
        // gibi özellikler belirtilmediği için main.dart'taki appBarTheme'den alınacaktır.
        title: const Text(
          "Yardım Merkezi",
        ), // Stil temadan (appBarTheme.titleTextStyle)
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ), // Renk temadan (appBarTheme.iconTheme veya foregroundColor)
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Yardım merkezi genellikle bir ana sayfadan açılır,
              // ama doğrudan açılırsa diye bir fallback.
              Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
            }
          },
        ),
        // titleSpacing: 0, // İsteğe bağlı
        // centerTitle: false, // İsteğe bağlı
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: faqList.length,
        itemBuilder: (context, index) {
          final item = faqList[index];
          final isExpanded = _expandedIndex == index;

          return Card(
            elevation: 2, // Gölge biraz azaltıldı
            margin: const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 4,
            ), // Yatay margin eklendi
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ), // Radius biraz küçültüldü
            ),
            child: InkWell(
              // InkWell Card'ın içine alındı, tüm karta tıklama efekti için
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  _expandedIndex = isExpanded ? null : index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ), // Padding ayarlandı
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // İkonu sağa yasla
                      children: [
                        Expanded(
                          child: Text(
                            item['question']!,
                            style: const TextStyle(
                              fontSize: 15, // Font boyutu ayarlandı
                              fontWeight: FontWeight.w600, // Kalınlık ayarlandı
                              color: Color(0xFF1F2937), // Koyu renk
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), // Başlık ve ikon arası boşluk
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: const Color(0xFFFF8128), // Tema rengi
                          size: 26, // İkon boyutu
                        ),
                      ],
                    ),
                    // Divider kaldırıldı, bunun yerine AnimatedCrossFade ile yumuşak geçiş
                    AnimatedCrossFade(
                      firstChild: Container(), // Boş container (kapalıyken)
                      secondChild: Padding(
                        // Cevap için Padding (açıkken)
                        padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                        child: Text(
                          item['answer']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ), // Satır yüksekliği
                        ),
                      ),
                      crossFadeState:
                          isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                      duration: const Duration(
                        milliseconds: 250,
                      ), // Animasyon süresi
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
