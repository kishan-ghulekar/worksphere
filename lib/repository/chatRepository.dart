// lib/repository/chatRepository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_project/model/chatModel.dart';
import 'package:super_project/model/messageModel.dart';
import 'package:super_project/model/user_model.dart';


class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chatsRef =>
      _firestore.collection('chats');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  // Create or get chat room
  Future<String> getOrCreateChat({
    required String projectId,
    required String projectTitle,
    required String clientId,
    required String freelancerId,
  }) async {
    final chatId = projectId;
    final doc = await _chatsRef.doc(chatId).get();

    if (!doc.exists) {
      await _chatsRef.doc(chatId).set({
        'chatId': chatId,
        'clientId': clientId,
        'freelancerId': freelancerId,
        'projectTitle': projectTitle,
        'lastMessage': '',
        'lastMessageTime': null,
        'lastSenderId': '',
        'clientUnread': 0,
        'freelancerUnread': 0,
      });
    }
    return chatId;
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
    required bool senderIsClient,
  }) async {
    final batch = _firestore.batch();
    final msgRef =
        _chatsRef.doc(chatId).collection('messages').doc();

    batch.set(msgRef, {
      'messageId': msgRef.id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(DateTime.now()),
      'isRead': false,
    });

    // Update chat metadata
    batch.update(_chatsRef.doc(chatId), {
      'lastMessage': message,
      'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      'lastSenderId': senderId,
      // Increment unread for the receiver
      senderIsClient ? 'freelancerUnread' : 'clientUnread':
          FieldValue.increment(1),
    });

    await batch.commit();
  }

  // Mark messages as read
  Future<void> markAsRead(String chatId, String currentUserId,
      bool isClient) async {
    // Reset unread count
    await _chatsRef.doc(chatId).update({
      isClient ? 'clientUnread' : 'freelancerUnread': 0,
    });

    // Mark all messages as read
    final unread = await _chatsRef
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Stream messages
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _chatsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data()))
            .toList());
  }

  // Stream chats for client
  Stream<List<ChatModel>> streamClientChats(String clientId) {
    return _chatsRef
        .where('clientId', isEqualTo: clientId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatModel.fromMap(d.id, d.data()))
            .toList());
  }

  // Stream chats for freelancer
  Stream<List<ChatModel>> streamFreelancerChats(String freelancerId) {
    return _chatsRef
        .where('freelancerId', isEqualTo: freelancerId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatModel.fromMap(d.id, d.data()))
            .toList());
  }

  // Stream other user profile — auto updates
 Stream<UserModel?>? streamUserProfile(String uid) { 
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  // Update online status
  Future<void> setOnlineStatus(String uid, bool isOnline) async {
    await _usersRef.doc(uid).set({
      'isOnline': isOnline,
      'lastSeen': isOnline
          ? null
          : Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  // Update typing status
  Future<void> setTyping(
      String chatId, String uid, bool isTyping) async {
    await _chatsRef.doc(chatId).set({
      'typing_$uid': isTyping,
    }, SetOptions(merge: true));
  }

  // Stream typing
  Stream<bool> streamTyping(String chatId, String otherUserId) {
    return _chatsRef.doc(chatId).snapshots().map((doc) {
      if (!doc.exists) return false;
      return doc.data()!['typing_$otherUserId'] as bool? ?? false;
    });
  }

  // Ensure user doc exists
  Future<void> ensureUserDoc({
    required String uid,
    required String name,
    required String profileImage,
    required String role,
  }) async {
    await _usersRef.doc(uid).set({
      'uid': uid,
      'name': name,
      'profileImage': profileImage,
      'isOnline': true,
      'lastSeen': null,
      'role': role,
    }, SetOptions(merge: true));
  }
}