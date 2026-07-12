// lib/View/Chat/ChatRoomScreen.dart
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:super_project/model/messageModel.dart';
import 'package:super_project/model/user_model.dart';
import 'package:super_project/repository/chatRepository.dart';
import 'package:super_project/viewmodel/Bloc/message_bloc.dart';
import 'package:super_project/viewmodel/Events/chatEvent.dart';
import 'package:super_project/viewmodel/States/chatStates.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final bool isClient;
  final String receiverId;
  final String projectTitle;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.isClient,
    required this.receiverId,
    required this.projectTitle,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Always reload messages fresh when screen opens
    context.read<MessageBloc>().add(LoadMessages(widget.chatId));
    context.read<MessageBloc>().add(
      MarkMessagesRead(
        chatId: widget.chatId,
        uid: widget.currentUserId,
        isClient: widget.isClient,
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<MessageBloc>().add(
      SendMessage(
        chatId: widget.chatId,
        senderId: widget.currentUserId,
        receiverId: widget.receiverId,
        message: text,
        senderIsClient: widget.isClient,
      ),
    );

    _messageController.clear();
    _stopTyping();
    _scrollToBottom();
  }

  void _onTyping(String value) {
    if (!_isTyping) {
      _isTyping = true;
      context.read<MessageBloc>().add(
        SetTyping(
          chatId: widget.chatId,
          uid: widget.currentUserId,
          isTyping: true,
        ),
      );
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), _stopTyping);
  }

  void _stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      context.read<MessageBloc>().add(
        SetTyping(
          chatId: widget.chatId,
          uid: widget.currentUserId,
          isTyping: false,
        ),
      );
    }
  }

  void _scrollToBottom() {
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

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    ChatRepository().setTyping(widget.chatId, widget.currentUserId, false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), // WhatsApp bg
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessageBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading || state is ChatInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages =
                    state is MessagesLoaded ? state.messages : <MessageModel>[];

                if (messages.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow[100]!.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🔒 Messages are related to: ${widget.projectTitle}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // Auto scroll to bottom on new messages
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMine = msg.senderId == widget.currentUserId;

                    // Date separator
                    final showDate =
                        index == 0 ||
                        !_isSameDay(
                          messages[index - 1].timeStamp,
                          msg.timeStamp,
                        );

                    return Column(
                      children: [
                        if (showDate) _buildDateSeparator(msg.timeStamp),
                        _buildMessageBubble(msg, isMine),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        backgroundColor: const Color(0xFF075E54),
        leadingWidth: 30,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<UserModel?>(
          stream:
              ChatRepository().streamUserProfile(widget.receiverId)
                  as Stream<UserModel?>,
          builder: (context, snap) {
            final UserModel? user = snap.data;
            final String name = user?.name ?? 'Loading...';
            final String imageUrl = user?.profileImage ?? '';
            final bool isOnline = user?.isOnline ?? false;

            // Typing indicator
            return StreamBuilder<bool>(
              stream: ChatRepository().streamTyping(
                widget.chatId,
                widget.receiverId,
              ),
              builder: (context, typingSnap) {
                final isTyping = typingSnap.data ?? false;

                return InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            backgroundImage:
                                imageUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(imageUrl)
                                    : null,
                            child:
                                imageUrl.isEmpty
                                    ? Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                    : null,
                          ),
                          if (isOnline)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF075E54),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isTyping
                                ? 'typing...'
                                : isOnline
                                ? 'online'
                                : _lastSeen(user?.lastSeen),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMine) {
    final time = DateFormat('hh:mm a').format(msg.timeStamp);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: isMine ? 60 : 8,
          right: isMine ? 8 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isMine
                  ? const Color(0xFFDCF8C6) // WhatsApp green sent
                  : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMine ? 12 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.message,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all : Icons.done,
                    size: 15,
                    color:
                        msg.isRead ? const Color(0xFF53BDEB) : Colors.grey[500],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String label;
    if (_isSameDay(date, now)) {
      label = 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      label = DateFormat('dd MMM yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.yellow[100]!.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: const Color(0xFFECE5DD),
      child: Row(
        children: [
          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: _onTyping,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send / Mic button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: hasText ? _sendMessage : null,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF075E54),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasText ? Icons.send : Icons.mic,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _lastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'last seen recently';
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 60) return 'last seen ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'last seen ${diff.inHours}h ago';
    return 'last seen ${DateFormat('dd MMM').format(lastSeen)}';
  }
}
