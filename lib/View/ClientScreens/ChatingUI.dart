import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freelancer Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ChatListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF6C5CE7),
      ),
      body: ListView(
        children: [
          ChatListTile(
            name: 'Liam Harper',
            lastMessage: 'Sure, how about we schedule a quick call...',
            time: '10:32 AM',
            avatarUrl:
                'https://ui-avatars.com/api/?name=Liam+Harper&background=6C5CE7&color=fff',
            unreadCount: 0,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => const ChatScreen(
                        name: 'Liam Harper',
                        avatarUrl:
                            'https://ui-avatars.com/api/?name=Liam+Harper&background=6C5CE7&color=fff',
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
        radius: 28,
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF6C5CE7),
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;

  const ChatScreen({super.key, required this.name, required this.avatarUrl});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hey there! I've reviewed your proposal and it looks great. I'm excited to move forward with this project.",
      isMe: false,
      time: '10:30 AM',
    ),
    ChatMessage(
      text:
          "That's fantastic to hear, Liam! I'm equally excited. Let's discuss the next steps.",
      isMe: true,
      time: '10:31 AM',
    ),
    ChatMessage(
      text:
          "Sure, how about we schedule a quick call tomorrow to align on the project timeline and deliverables?",
      isMe: false,
      time: '10:32 AM',
    ),
    ChatMessage(
      text:
          "Sounds perfect. I'm available anytime after 2 PM EST. Let me know what works best for you.",
      isMe: true,
      time: '10:33 AM',
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text,
          isMe: true,
          time: TimeOfDay.now().format(context),
        ),
      );
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.avatarUrl),
              radius: 18,
            ),
            const SizedBox(width: 12),
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  message: message,
                  avatarUrl: message.isMe ? null : widget.avatarUrl,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF2D2D2D),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D3D3D),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.image, color: Colors.grey),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF8B7FE8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String? avatarUrl;

  const MessageBubble({super.key, required this.message, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isMe && avatarUrl != null) ...[
            CircleAvatar(backgroundImage: NetworkImage(avatarUrl!), radius: 16),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  message.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        message.isMe
                            ? const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF8B7FE8)],
                            )
                            : null,
                    color: message.isMe ? null : const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isMe ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${!message.isMe ? '${message.isMe ? "You" : "Liam Harper"} · ' : ''}${message.time}',
                        style: TextStyle(
                          color:
                              message.isMe
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (message.isMe && avatarUrl != null) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF4CAF50),
              radius: 16,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}
