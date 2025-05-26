// lib/features/user_features/support_user/screens/SupportPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../state_management/auth_provider.dart';
import '../../../../state_management/chat_provider.dart'; // Import ChatProvider
import '../models/chat_args.dart';
import '../models/message_model.dart'; // For Message type hint

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  // This list now primarily defines the mentor profiles.
  // Last message, time, and unread count will come from ChatProvider.
  final List<Map<String, dynamic>> supportProfiles = [
    {
      'id': ChatProvider.geminiId, // Use ID from ChatProvider
      'name': 'Gemini',
      'image': 'assets/images/Gemini.png', // Ensure this asset exists
      'defaultMessage': 'Yapay zeka ile sohbet edin...',
    },
    {
      'id': ChatProvider.mentorRyzId,
      'name': 'Rabia Yazlı',
      'image': 'assets/images/Profilimg3.png',
      'defaultMessage': 'Sohbete devam edin...',
    },
    {
      'id': ChatProvider.mentorNkId,
      'name': 'Nazmi Koçak',
      'image': 'assets/images/Profilimg.png',
      'defaultMessage': 'Sohbete devam edin...',
    },
    {
      'id': ChatProvider.mentorRyId,
      'name': 'Ramazan Yiğit',
      'image': 'assets/images/Profilimg4.png',
      'defaultMessage': 'Sohbete devam edin...',
    },
  ];

  bool isSelectionMode = false;
  Set<String> selectedMentorIds = {}; // Use mentorId (String) for selection

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
      // Data will be dynamically fetched in the build method using ChatProvider
    });
  }

  void toggleSelection(String mentorId) {
    setState(() {
      if (selectedMentorIds.contains(mentorId)) {
        selectedMentorIds.remove(mentorId);
        if (selectedMentorIds.isEmpty) isSelectionMode = false;
      } else {
        selectedMentorIds.add(mentorId);
        isSelectionMode = true;
      }
    });
  }

  void deleteSelected() {
    // In a real app, you'd call chatProvider.deleteChats(selectedMentorIds.toList());
    // For this simulation, we'll just clear selection and show a snackbar.
    // The actual chat history will remain in ChatProvider for this example.
    setState(() {
      selectedMentorIds.clear();
      isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seçili sohbetlerin silinmesi simüle edildi.'),
      ),
    );
  }

  void _navigateToChat(Map<String, dynamic> chatPartnerProfile) {
    Navigator.pushNamed(
      context,
      AppRoutes.chatWithMentor,
      arguments: ChatArgs(
        chatPartnerId: chatPartnerProfile['id'],
        chatPartnerName: chatPartnerProfile['name'],
        chatPartnerImage: chatPartnerProfile['image'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Use Consumer to rebuild when ChatProvider notifies
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Create the display data by combining static profiles with dynamic chat data
        List<Map<String, dynamic>> currentDisplayData =
            supportProfiles.map((profile) {
              final mentorId = profile['id'] as String;
              final Message? lastMsg = chatProvider.getLastMessage(mentorId);
              final int unreadCount = chatProvider.getUnreadCount(mentorId);

              return {
                ...profile, // Spread the static profile data
                'message': lastMsg?.text ?? profile['defaultMessage'],
                'time': lastMsg?.time ?? "", // Use last message's time or empty
                'unread': unreadCount,
              };
            }).toList();

        // Optional: Sort by last message time (more complex, requires proper time parsing)
        // currentDisplayData.sort((a, b) => (b['time'] as String).compareTo(a['time'] as String));

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
                }
              },
            ),
            title: const Text('Destek Mesajları'),
            titleSpacing: 0,
            centerTitle: false,
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
                        onPressed:
                            selectedMentorIds.isEmpty ? null : deleteSelected,
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
                            selectedMentorIds.clear();
                          });
                        },
                      ),
                    ]
                    : [],
          ),
          body:
              currentDisplayData.isEmpty
                  ? const Center(
                    child: Padding(
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
                    itemCount: currentDisplayData.length,
                    itemBuilder: (context, index) {
                      final item = currentDisplayData[index];
                      final mentorId = item['id'] as String;
                      final isSelected = selectedMentorIds.contains(mentorId);

                      return GestureDetector(
                        onLongPress: () => toggleSelection(mentorId),
                        onTap: () {
                          if (isSelectionMode) {
                            toggleSelection(mentorId);
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
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                isSelected
                                    ? Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 1.5,
                                    )
                                    : Border.all(
                                      color: Colors.grey.shade300,
                                      width: 0.8,
                                    ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.2),
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
                                      item['message'], // Dynamically set from ChatProvider
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
                                    item['time'], // Dynamically set
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
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
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
                                    const SizedBox(
                                      height: 20,
                                    ), // Maintain alignment
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
                      Navigator.pushNamed(context, AppRoutes.searchMentor);
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
      },
    );
  }
}
