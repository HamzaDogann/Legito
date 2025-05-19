// lib/features/user_features/support_user/screens/ChatPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../state_management/auth_provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../models/chat_args.dart';
import '../models/mentor_account_args.dart';

class ChatPage extends StatefulWidget {
  final ChatArgs args;

  const ChatPage({Key? key, required this.args}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [
    Message(
      text: "Merhaba yardımcı olabilir misiniz?",
      isMe: true,
      time: "12:05",
    ),
    Message(
      text: "Elbette, nasıl yardımcı olabilirim?",
      isMe: false,
      time: "12:08",
    ),
  ];
  final TextEditingController _messageController = TextEditingController();

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
      // TODO: Sohbet geçmişini yükle
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(
          Message(
            text: text,
            isMe: true,
            time:
                "${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}",
          ),
        );
        _messageController.clear();
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // AppBar için renkler ve stiller temadan gelecek.
    // final appBarTheme = Theme.of(context).appBarTheme;
    // final Color currentAppBarForegroundColor = appBarTheme.foregroundColor ?? Colors.black;
    // final TextStyle? currentAppBarTitleTextStyle = appBarTheme.titleTextStyle;

    return Scaffold(
      // backgroundColor: Colors.white, // Temadan scaffoldBackgroundColor gelebilir
      appBar: AppBar(
        // backgroundColor: const Color(0xFFF4F4F4), // KALDIRILDI - Temadan gelecek
        // elevation: 0.5, // Temadan gelebilir veya burada özel ayarlanabilir
        toolbarHeight: 70, // Bu özel yükseklik korunabilir
        leading: IconButton(
          // icon: const Icon(Icons.arrow_back, color: Colors.black), // KALDIRILDI - Temadan gelecek
          icon: const Icon(
            Icons.arrow_back,
          ), // Renk temadan (appBarTheme.iconTheme veya foregroundColor)
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing:
            0, // <<< Geri butonu ile title arasındaki boşluğu azaltır/kaldırır
        // centerTitle: false, // Başlığı sola yaslar (varsayılan olabilir)
        title: GestureDetector(
          onTap: () {
            print(
              "AppBar title tapped. Navigating to mentor account for: ${widget.args.chatPartnerName}",
            );
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
                                  'assets/default_avatar.png',
                            )
                            as ImageProvider,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.args.chatPartnerName,
                  // style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Temadan gelecek
                  // Temadan gelen titleTextStyle'ı kullanabiliriz veya üzerine yazabiliriz.
                  // Eğer temadaki başlık stili buraya uymuyorsa, burada özel stil tanımlanabilir.
                  // Örneğin, temadan gelen rengi alıp fontWeight'u değiştirebiliriz:
                  style:
                      Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                        fontWeight:
                            FontWeight
                                .bold, // Temadaki font ailesi ve rengi korunur
                      ) ??
                      const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ), // Fallback
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4), // İsim ve ok ikonu arası boşluk
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade600,
              ),
              // <<< YENİ: Sağdan boşluk vermek için SizedBox eklendi >>>
              const SizedBox(
                width: 30,
              ), // İstediğiniz boşluk miktarı (örneğin 30px)
            ],
          ),
        ),
        actions: const [
          // Üç nokta menüsü kaldırıldı
          // Eğer başka action butonları istenirse buraya eklenebilir.
          // Örneğin bir arama veya bilgi butonu.
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              // reverse: true, // Yeni mesajların altta görünmesi ve otomatik scroll için
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
                      vertical: 5.0,
                    ), // Dikey padding ayarlandı
                    child: Column(
                      crossAxisAlignment:
                          message.isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color:
                                message.isMe
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors
                                        .grey
                                        .shade200, // Tema rengi kullanıldı
                            borderRadius: BorderRadius.circular(18),
                            boxShadow:
                                message.isMe
                                    ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ), // Gölge yumuşatıldı
                                    ]
                                    : [],
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color:
                                  message.isMe ? Colors.white : Colors.black87,
                              fontSize: 15.5,
                            ), // Font boyutu ayarlandı
                          ),
                        ),
                        const SizedBox(height: 3), // Boşluk azaltıldı
                        Text(
                          message.time,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ), // Font boyutu küçültüldü
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ), // Padding ayarlandı
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ), // Border inceltildi
              boxShadow: [
                // Hafif bir üst gölge
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end, // İkonların dikeyde hizalanması için
              children: [
                IconButton(
                  icon: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.grey.shade700,
                    size: 26,
                  ), // Boyut ayarlandı
                  onPressed: () {
                    /* Resim/dosya seçme */
                  },
                  padding: EdgeInsets.zero, // Ekstra padding'i kaldır
                  constraints:
                      const BoxConstraints(), // Ekstra padding'i kaldır
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
                      ), // Padding ayarlandı
                      isDense: true, // Yoğunluğu artır
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    minLines: 1,
                    maxLines: 5,
                    style: const TextStyle(fontSize: 16), // Yazı boyutu
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ), // Tema rengi ve boyut
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

// Message sınıfı (değişiklik yok)
class Message {
  final String text;
  final bool isMe;
  final String time;
  Message({required this.text, required this.isMe, required this.time});
}
