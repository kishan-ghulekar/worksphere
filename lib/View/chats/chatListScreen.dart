// lib/View/Chat/ChatListScreen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:super_project/View/chats/charRoomScreen.dart';
import 'package:super_project/model/chatModel.dart';
import 'package:super_project/model/user_model.dart';
import 'package:super_project/repository/chatRepository.dart';
import 'package:super_project/viewmodel/Bloc/chatBloc.dart';
import 'package:super_project/viewmodel/Events/chatEvent.dart';
import 'package:super_project/viewmodel/States/chatStates.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final String _uid;
  bool _isClient = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      context.read<ChatBloc>().add(LoadChats(uid: _uid, isClient: _isClient));
    }
  }

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _loadChats();

    // Determine role from Firestore
    ChatRepository().streamUserProfile(_uid)?.first.then((profile) {
      _isClient = profile?.role == 'client';
      if (mounted) {
        context.read<ChatBloc>().add(LoadChats(uid: _uid, isClient: _isClient));
      }
    });
    _isClient = false; // default, will update
  }

  Future<void> _loadChats() async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(_uid).get();

      if (doc.exists && doc.data() != null) {
        final role = (doc.data()!['role'] as String? ?? '').toLowerCase();
        _isClient = role == 'client';
      } else {
        final clientDoc =
            await FirebaseFirestore.instance
                .collection('clients')
                .doc(_uid)
                .get();
        _isClient = clientDoc.exists;
      }
    } catch (e) {
      debugPrint('Error loading role: $e');
    } finally {
      if (mounted) {
        setState(() => _initialized = true);
        context.read<ChatBloc>().add(LoadChats(uid: _uid, isClient: _isClient));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body:
          !_initialized
              ? const Center(child: CircularProgressIndicator())
              : BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading || state is ChatInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatFailure) {
                    return Center(child: Text(state.message));
                  }

                  if (state is MessagesLoaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _initialized) {
                        context.read<ChatBloc>().add(
                          LoadChats(uid: _uid, isClient: _isClient),
                        );
                      }
                    });
                    return const Center(child: CircularProgressIndicator());
                  }

                  final chats =
                      state is ChatsLoaded ? state.chats : <ChatModel>[];

                  if (chats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start chatting from a project or contract',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: chats.length,
                    separatorBuilder:
                        (_, __) => Divider(
                          height: 1,
                          indent: 80,
                          color: Colors.grey[100],
                        ),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final otherUserId =
                          _isClient ? chat.freelancerId : chat.clientId;
                      final unreadCount =
                          _isClient ? chat.clientUnread : chat.freelancerUnread;

                      return StreamBuilder<UserModel?>(
                        stream: ChatRepository().streamUserProfile(otherUserId),
                        builder: (context, snap) {
                          final other = snap.data;
                          final name = other?.name ?? 'User';
                          final imageUrl = other?.profileImage ?? '';
                          final isOnline = other?.isOnline ?? false;

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => ChatRoomScreen(
                                        chatId: chat.chatId,
                                        currentUserId: _uid,
                                        isClient: _isClient,
                                        receiverId: otherUserId,
                                        projectTitle: chat.projectTitle,
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: const Color(
                                          0xFF5B67F1,
                                        ).withOpacity(0.15),
                                        backgroundImage:
                                            imageUrl.isNotEmpty
                                                ? CachedNetworkImageProvider(
                                                  imageUrl,
                                                )
                                                : null,
                                        child:
                                            imageUrl.isEmpty
                                                ? Text(
                                                  name.isNotEmpty
                                                      ? name[0].toUpperCase()
                                                      : 'U',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF5B67F1),
                                                  ),
                                                )
                                                : null,
                                      ),
                                      if (isOnline)
                                        Positioned(
                                          bottom: 1,
                                          right: 1,
                                          child: Container(
                                            width: 13,
                                            height: 13,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF25D366),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    unreadCount > 0
                                                        ? FontWeight.bold
                                                        : FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              chat.lastMessageTime != null
                                                  ? _formatTime(
                                                    chat.lastMessageTime!,
                                                  )
                                                  : '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    unreadCount > 0
                                                        ? const Color(
                                                          0xFF25D366,
                                                        )
                                                        : Colors.grey[500],
                                                fontWeight:
                                                    unreadCount > 0
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (chat.lastSenderId == _uid)
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  right: 4,
                                                ),
                                                child: Icon(
                                                  Icons.done_all,
                                                  size: 16,
                                                  color: Color(0xFF53BDEB),
                                                ),
                                              ),
                                            Expanded(
                                              child: Text(
                                                chat.lastMessage.isNotEmpty
                                                    ? chat.lastMessage
                                                    : chat.projectTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      unreadCount > 0
                                                          ? Colors.black87
                                                          : Colors.grey[500],
                                                  fontWeight:
                                                      unreadCount > 0
                                                          ? FontWeight.w500
                                                          : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            if (unreadCount > 0)
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  5,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF25D366),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  '$unreadCount',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) return DateFormat('hh:mm a').format(time);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(time);
    return DateFormat('dd/MM/yy').format(time);
  }
}
