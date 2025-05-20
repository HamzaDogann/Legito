// lib/features/user_features/support_user/screens/SupportPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../state_management/auth_provider.dart';
import '../models/chat_args.dart'; // ChatArgs için

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  List<Map<String, dynamic>> supportData = [
    {
      'id': 'mentor_ryz_004',
      'name': 'Rabia Yazlı',
      'message': 'Umarım yardımcı olabilmişimdir.',
      'time': '14:00',
      'unread': 0,
      'image': 'assets/images/Profilimg3.png',
    },
    {
      'id': 'mentor_nk_002',
      'name': 'Nazmi Koçak',
      'message': 'Elbette, nasıl yardımcı olabilirim?',
      'time': '14:00',
      'unread': 0,
      'image': 'assets/images/Profilimg.png',
    },
    {
      'id': 'mentor_ry_003',
      'name': 'Ramazan Yiğit',
      'message': 'Günaydın...',
      'time': '09:20',
      'unread': 4,
      'image': 'assets/images/Profilimg4.png',
    },
  ];

  bool isSelectionMode = false;
  Set<int> selectedIndexes = {};

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
      // TODO: supportData'yı API'den yükle
    });
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
        if (selectedIndexes.isEmpty) isSelectionMode = false;
      } else {
        selectedIndexes.add(index);
        isSelectionMode = true;
      }
    });
  }

  void deleteSelected() {
    setState(() {
      final toDelete = selectedIndexes.toList()..sort((a, b) => b.compareTo(a));
      for (var index in toDelete) {
        supportData.removeAt(index);
      }
      selectedIndexes.clear();
      isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seçili sohbetler silindi (simülasyon).')),
    );
  }

  void _navigateToChat(Map<String, dynamic> chatPartner) {
    print("Navigating to chat with: ${chatPartner['name']}");
    Navigator.pushNamed(
      context,
      AppRoutes.chatWithMentor,
      arguments: ChatArgs(
        chatPartnerId: chatPartner['id'] ?? 'unknown_partner_id',
        chatPartnerName: chatPartner['name'],
        chatPartnerImage: chatPartner['image'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Temadan gelen AppBar renklerini ve stillerini kullanacağız.
    // final appBarTheme = Theme.of(context).appBarTheme;
    // final Color currentAppBarForegroundColor = appBarTheme.foregroundColor ?? const Color(0xFF1F2937);

    return Scaffold(
      // backgroundColor: Colors.white, // Temadan scaffoldBackgroundColor gelebilir.
      appBar: AppBar(
        // backgroundColor: const Color(0xFFF4F4F4), // KALDIRILDI - Temadan gelecek
        // foregroundColor: Colors.black, // KALDIRILDI - Temadan gelecek
        // elevation: 0.5, // Temadan gelebilir veya özel ayarlanabilir. Şimdilik temaya bırakalım.
        leading: IconButton(
          // icon: const Icon(Icons.arrow_back, color: Colors.black), // KALDIRILDI - Temadan gelecek
          icon: const Icon(
            Icons.arrow_back,
          ), // Renk temadan (appBarTheme.iconTheme) gelecek
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
            }
          },
        ),
        title: const Text(
          'Destek Mesajları',
        ), // Stil temadan (appBarTheme.titleTextStyle) gelecek
        titleSpacing:
            0, // <<< YENİ: Geri butonu ile başlık arasındaki boşluğu azaltır
        centerTitle:
            false, // Başlığı sola yaslamak için (iOS'ta varsayılan true)
        actions:
            isSelectionMode
                ? [
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 26,
                    ),
                    tooltip: 'Seçilenleri Sil',
                    onPressed: selectedIndexes.isEmpty ? null : deleteSelected,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black54,
                      size: 26,
                    ),
                    tooltip: 'Seçimi İptal Et',
                    onPressed: () {
                      setState(() {
                        isSelectionMode = false;
                        selectedIndexes.clear();
                      });
                    },
                  ),
                ]
                : [/* İsteğe bağlı actions eklenebilir */],
      ),
      body:
          supportData.isEmpty
              ? const Center(
                child: Padding(
                  // Padding eklendi
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Henüz destek mesajınız bulunmuyor.\nYeni bir görüşme başlatmak için aşağıdaki (+) butonunu kullanabilirsiniz.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: supportData.length,
                itemBuilder: (context, index) {
                  final item = supportData[index];
                  final isSelected = selectedIndexes.contains(index);

                  return GestureDetector(
                    onLongPress: () => toggleSelection(index),
                    onTap: () {
                      if (isSelectionMode) {
                        toggleSelection(index);
                      } else {
                        _navigateToChat(item);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.15)
                                : Colors.white, // Tema rengi kullanıldı
                        borderRadius: BorderRadius.circular(16),
                        border:
                            isSelected
                                ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1.5,
                                ) // Tema rengi
                                : Border.all(
                                  color: Colors.grey.shade300,
                                  width: 0.8,
                                ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary
                                        .withOpacity(0.2), // Tema rengi
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(item['image']),
                                radius: 28,
                              ),
                              if (isSelectionMode)
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      isSelected
                                          ? Colors.black.withOpacity(0.5)
                                          : Colors.transparent,
                                  child:
                                      isSelected
                                          ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 24,
                                          )
                                          : null,
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['message'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['time'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (item['unread'] != null &&
                                  item['unread'] > 0 &&
                                  !isSelected)
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ), // Tema rengi
                                  child: Text(
                                    '${item['unread']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton:
          isSelectionMode
              ? null
              : FloatingActionButton.extended(
                onPressed: () {
                  print("FAB tıklandı: SearchMentorPage'e gidiliyor.");
                  Navigator.pushNamed(context, AppRoutes.searchMentor);
                },
                backgroundColor:
                    Theme.of(context).colorScheme.primary, // Tema rengi
                icon: const Icon(
                  Icons.add_comment_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  "Yeni Mesaj",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                tooltip: 'Yeni Destek Konuşması Başlat',
              ),
    );
  }
}
