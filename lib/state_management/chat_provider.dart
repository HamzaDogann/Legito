// lib/state_management/chat_provider.dart
import 'package:flutter/material.dart';
import '../features/user_features/support_user/models/message_model.dart'; // Adjust path if necessary

class ChatProvider with ChangeNotifier {
  final Map<String, List<Message>> _chatHistories = {};
  final Map<String, int> _unreadCounts = {};

  static const String geminiId = 'gemini_ai_001';
  static const String mentorNkId = 'mentor_nk_002';
  static const String mentorRyId = 'mentor_ry_003';
  static const String mentorRyzId = 'mentor_ryz_004';

  ChatProvider() {
    _initializeDefaultChats();
  }

  void _initializeDefaultChats() {
    // Gemini - introductory message
    _chatHistories[geminiId] = [
      Message(
        text:
            "Merhaba! Ben Gemini. Okuma hedeflerinize ulaşmanızda size nasıl yardımcı olabilirim?",
        isMe: false,
        time: "09:00",
      ),
    ];
    _unreadCounts[geminiId] = 1;

    // Nazmi Koçak
    _chatHistories[mentorNkId] = [
      Message(
        text: "Merhaba Nazmi Bey, bir konuda danışmak istiyorum.",
        isMe: true,
        time: "13:58",
      ),
      Message(
        text: "Elbette, nasıl yardımcı olabilirim?",
        isMe: false,
        time: "14:00",
      ),
    ];
    _unreadCounts[mentorNkId] = 0;

    // Ramazan Yiğit
    _chatHistories[mentorRyId] = [
      Message(
        text: "Ramazan Bey, odaklanma teknikleri hakkında bilginiz var mı?",
        isMe: true,
        time: "09:18",
      ),
      Message(text: "Günaydın...", isMe: false, time: "09:20"),
      Message(
        text: "Evet, Pomodoro tekniğini önerebilirim. Detaylı konuşalım mı?",
        isMe: false,
        time: "09:21",
      ),
    ];
    _unreadCounts[mentorRyId] = 2;

    // Rabia Yazlı
    _chatHistories[mentorRyzId] = [
      Message(
        text: "Hızlı okuma kursunuz hakkında bilgi alabilir miyim?",
        isMe: true,
        time: "13:50",
      ),
      Message(
        text: "Tabii, memnuniyetle. Şu an aktif bir grup dersimiz mevcut.",
        isMe: false,
        time: "13:52",
      ),
      Message(
        text: "Teşekkürler, değerlendireceğim.",
        isMe: true,
        time: "13:55",
      ),
      Message(
        text: "Umarım yardımcı olabilmişimdir.",
        isMe: false,
        time: "14:00",
      ),
    ];
    _unreadCounts[mentorRyzId] = 0;
  }

  List<Message> getMessages(String chatPartnerId) {
    return _chatHistories[chatPartnerId] ?? [];
  }

  Message? getLastMessage(String chatPartnerId) {
    final messages = _chatHistories[chatPartnerId];
    if (messages != null && messages.isNotEmpty) {
      return messages.last;
    }
    return null;
  }

  int getUnreadCount(String chatPartnerId) {
    return _unreadCounts[chatPartnerId] ?? 0;
  }

  void addMessage(
    String chatPartnerId,
    Message message, {
    bool fromUser = true,
    bool isOnline =
        true, // This parameter is for determining if unread count should increment
  }) {
    if (!_chatHistories.containsKey(chatPartnerId)) {
      _chatHistories[chatPartnerId] = [];
    }
    _chatHistories[chatPartnerId]!.add(message);

    // Only increment unread count if the message is FROM THE BOT/MENTOR
    // AND the user is considered 'online' in the app but NOT necessarily on this specific chat page.
    // ChatPage's markAsRead will handle resetting it when the user opens that specific chat.
    if (!fromUser && isOnline) {
      _unreadCounts[chatPartnerId] = (_unreadCounts[chatPartnerId] ?? 0) + 1;
    }
    notifyListeners();
  }

  void markAsRead(String chatPartnerId) {
    if ((_unreadCounts[chatPartnerId] ?? 0) > 0) {
      _unreadCounts[chatPartnerId] = 0;
      notifyListeners();
    }
  }

  Future<void> simulateResponse(
    String chatPartnerId,
    String userMessageText,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    if (chatPartnerId == geminiId) {
      final currentTime = TimeOfDay.now();
      final formattedTime =
          "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}";

      final botMessage = Message(
        text:
            _simulatedGeminiResponseText, // Gemini always gives its standard response
        isMe: false,
        time: formattedTime,
      );

      // Add Gemini's message to history and increment unread count
      // (if the user isn't currently on the Gemini chat page).
      addMessage(chatPartnerId, botMessage, fromUser: false, isOnline: true);
    }
    // For other mentors, no response is simulated.
  }

  static const String _simulatedGeminiResponseText = """
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
}
