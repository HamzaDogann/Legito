// lib/features/user_features/support_user/screens/ChatPage.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../state_management/auth_provider.dart';
import '../../../../state_management/chat_provider.dart';
import '../../../../core/navigation/app_routes.dart'; // Make sure this path is correct
import '../models/chat_args.dart';
import '../models/mentor_account_args.dart';
import '../models/message_model.dart';

class ChatPage extends StatefulWidget {
  final ChatArgs args;
  const ChatPage({Key? key, required this.args}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatProvider _chatProvider;
  int _previousMessageCount = 0; // To track message changes for scrolling

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Get initial message count. This is important for the Consumer's first build.
    _previousMessageCount =
        _chatProvider.getMessages(widget.args.chatPartnerId).length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
        return;
      }
      // Mark messages as read. Provider will notify if unread count changes.
      _chatProvider.markAsRead(widget.args.chatPartnerId);

      // Initial scroll is now handled reliably by the Consumer's build method
      // when it first gets the messages.
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // This function will be called after the ListView has been built or updated
    // by the Consumer, ensuring maxScrollExtent is correct.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Only scroll if there is content beyond the viewport
        if (_scrollController.position.maxScrollExtent > 0.0) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final currentTime = TimeOfDay.now();
      final formattedTime =
          "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}";

      final userMessage = Message(text: text, isMe: true, time: formattedTime);

      // ChatProvider's addMessage will call notifyListeners()
      _chatProvider.addMessage(
        widget.args.chatPartnerId,
        userMessage,
        fromUser: true,
      );
      _messageController.clear();
      FocusScope.of(context).unfocus();
      // Scrolling for user's message will be handled by the Consumer's build method

      _chatProvider.simulateResponse(widget.args.chatPartnerId, text);
      // Scrolling for bot's response will also be handled by the Consumer
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // This line is crucial: it gets the LATEST messages every time ChatProvider notifies.
        final currentMessages = chatProvider.getMessages(
          widget.args.chatPartnerId,
        );

        // If messages are loaded for the first time OR new messages arrived, scroll.
        // `currentMessages.isNotEmpty` ensures we don't try to scroll an empty list uselessly.
        // `currentMessages.length != _previousMessageCount` handles new messages.
        if (currentMessages.isNotEmpty &&
            currentMessages.length != _previousMessageCount) {
          _scrollToBottom();
        }
        // Update the previous count for the next build comparison.
        _previousMessageCount = currentMessages.length;

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
                  AppRoutes
                      .mentorAccountViewByUser, // Make sure this route is defined
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
                                widget.args.chatPartnerImage!.startsWith(
                                  'http',
                                ))
                            ? NetworkImage(widget.args.chatPartnerImage!)
                            : AssetImage(
                                  widget.args.chatPartnerImage ??
                                      'assets/images/default_avatar.png',
                                ) // Make sure this asset exists
                                as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.args.chatPartnerName,
                      style:
                          Theme.of(context).appBarTheme.titleTextStyle
                              ?.copyWith(fontWeight: FontWeight.bold) ??
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
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      currentMessages.length, // Use messages from Consumer
                  itemBuilder: (context, index) {
                    final message =
                        currentMessages[index]; // Use messages from Consumer
                    return Align(
                      alignment:
                          message.isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
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
                                      message.isMe
                                          ? Colors.white
                                          : Colors.black87,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
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
      },
    );
  }
}
