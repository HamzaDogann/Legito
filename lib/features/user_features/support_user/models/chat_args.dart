// lib/features/user_features/support_user/models/chat_args.dart

class ChatArgs {
  final String
  chatPartnerId; // Sohbet edilecek kişinin (mentor veya kullanıcı) benzersiz kimliği
  final String chatPartnerName; // AppBar'da ve yönlendirmede kullanılacak isim
  final String
  chatPartnerImage; // AppBar'da ve yönlendirmede kullanılacak profil resmi yolu (Asset veya Network)
  // İleride, eğer sohbet geçmişi belirli bir ID ile yükleniyorsa:
  // final String? conversationId;

  ChatArgs({
    required this.chatPartnerId,
    required this.chatPartnerName,
    required this.chatPartnerImage,
    // this.conversationId,
  });
}
