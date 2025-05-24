// lib/features/user_features/support_user/screens/ChatPage.dart
import 'dart:async'; // Timer için
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../state_management/auth_provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../models/chat_args.dart';
import '../models/mentor_account_args.dart';

// Message sınıfı (Aynı kalacak)
class Message {
  final String text;
  final bool isMe;
  final String time;
  Message({required this.text, required this.isMe, required this.time});
}

class ChatPage extends StatefulWidget {
  final ChatArgs args;
  const ChatPage({Key? key, required this.args}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = []; // Başlangıçta boş
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // Otomatik scroll için

  // Simülasyon için sabit yanıt
  static const String _simulatedResponseText = """
Merhaba! Okuma hızını artırma isteğin ve odaklanma sorununu aşma çaban takdire şayan. Seni bu konuda desteklemekten mutluluk duyarım. Verilerine baktığımda, genel olarak 252 kelime/dakika gibi iyi bir ortalama okuma hızına sahip olduğunu görüyorum. Bu, başlangıç için gayet güzel bir seviye.

Güçlü Yönlerin:

İyi Bir Başlangıç Hızı: 252 kelime/dakika, birçok insanın ortalama okuma hızının üzerinde. Bu, hızlı okuma tekniklerini öğrenmek ve uygulamak için sağlam bir temel oluşturduğun anlamına geliyor.

Düzenli Okuma: Son 7 günde düzenli olarak okuma yapmış olman, okuma alışkanlığını geliştirmek için önemli bir adım. Bu alışkanlığı sürdürmek, ilerleme kaydetmeni kolaylaştıracaktır.

Gelişim Alanların ve Önerilerim:

Odaklanma sorunu, okuma hızını artırmak isteyen birçok kişinin karşılaştığı yaygın bir problem. Dikkat dağınıklığı, okuma hızını düşürmekle kalmaz, aynı zamanda okuduğunu anlamanı da zorlaştırır. Bu sorunu aşmak için sana birkaç öneride bulunabilirim:

Okuma Ortamını Düzenle: Sessiz, dikkat dağıtıcı olmayan bir ortamda, rahat bir pozisyonda oku. Gerekirse odaklanma müziği ya da kulaklık kullanabilirsin.

Pomodoro Tekniğini Uygula: 25 dakika odaklanıp 5 dakika mola vererek çalış. Bu, dikkatini toplamana ve zihinsel yorgunluğu azaltmana yardımcı olur.

Okuma Egzersizleri Yap: Göz egzersizleri, satır takibi ve göz kırpma farkındalığı gibi küçük pratiklerle okuma becerilerini geliştirebilirsin.

Okuma Alışkanlığını Eğlenceli Hale Getir: İlgi çekici konular seçerek ve küçük hedefler belirleyerek motivasyonunu artırabilirsin.

Uygulama Desteğinden Yararlan: LEGITO uygulamasındaki odaklanmayı kolaylaştıran görsel ayarları ve okuma hızı takibini kullanarak gelişimini izleyebilirsin.

Unutma, bu bir süreç. Küçük ama istikrarlı adımlarla ilerlemek en doğru yol. Yardıma ihtiyacın olursa her zaman buradayım. Başarılar!
""";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        if (mounted)
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
      }
      // Simülasyon için başlangıç mesajları (isteğe bağlı)
      // Eğer sayfa açıldığında hemen bir konuşma başlatmak isterseniz:
      // _addSimulatedInitialMessages();
    });
  }

  // İsteğe bağlı: Sayfa açıldığında ilk mesajları eklemek için
  /*
  void _addSimulatedInitialMessages() {
    if (_messages.isEmpty) { // Sadece ilk açılışta
      setState(() {
        _messages.add(Message(text: "Merhaba, okuma hızımı ve odaklanmamı geliştirmek istiyorum.", isMe: true, time: "10:00"));
      });
      _simulateResponseAfterDelay(_simulatedResponseText, "10:01");
    }
  }
  */

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Kısa bir gecikmeyle scroll yap, widget'ların build olması için zaman tanır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final currentTime = TimeOfDay.now();
      final formattedTime =
          "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}";

      setState(() {
        _messages.add(Message(text: text, isMe: true, time: formattedTime));
      });
      _messageController.clear();
      FocusScope.of(context).unfocus();
      _scrollToBottom(); // Kullanıcı mesajı gönderdikten sonra scroll et

      // Simüle edilmiş yanıtı 1 saniye sonra ekle
      _simulateResponseAfterDelay(
        _simulatedResponseText,
        formattedTime,
      ); // Yanıt için de yaklaşık bir zaman
    }
  }

  void _simulateResponseAfterDelay(String responseText, String requestTime) {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // Widget hala ağaçtaysa devam et
        final responseTime = TimeOfDay.now(); // Gerçek yanıt zamanı
        final formattedResponseTime =
            "${responseTime.hour.toString().padLeft(2, '0')}:${responseTime.minute.toString().padLeft(2, '0')}";
        setState(() {
          _messages.add(
            Message(
              text: responseText,
              isMe: false,
              time: formattedResponseTime,
            ),
          );
        });
        _scrollToBottom(); // Yanıt geldikten sonra scroll et
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.mentorAccountViewByUser,
              arguments: MentorAccountArgs(
                mentorId: widget.args.chatPartnerId,
                mentorName: widget.args.chatPartnerName,
                mentorImage: widget.args.chatPartnerImage,
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    (widget.args.chatPartnerImage != null &&
                            widget.args.chatPartnerImage!.startsWith('http'))
                        ? NetworkImage(widget.args.chatPartnerImage!)
                        : AssetImage(
                              widget.args.chatPartnerImage ??
                                  'assets/images/default_avatar.png',
                            )
                            as ImageProvider,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.args.chatPartnerName,
                  style:
                      Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                        fontWeight: FontWeight.bold,
                      ) ??
                      const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 16), // Sağdan boşluk
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // ScrollController'ı ata
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment:
                      message.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                    ), // Mesajlar arası dikey boşluk
                    child: Column(
                      crossAxisAlignment:
                          message.isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ), // İç padding
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color:
                                message.isMe
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft:
                                  message.isMe
                                      ? const Radius.circular(18)
                                      : const Radius.circular(4),
                              bottomRight:
                                  message.isMe
                                      ? const Radius.circular(4)
                                      : const Radius.circular(18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                offset: const Offset(0, 1),
                                blurRadius: 1.5,
                              ),
                            ],
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color:
                                  message.isMe ? Colors.white : Colors.black87,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.time,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.grey.shade700,
                    size: 26,
                  ),
                  onPressed: () {
                    /* Resim seçme */
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Bir mesaj yazın...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    minLines: 1,
                    maxLines: 5,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  onPressed: _sendMessage,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
