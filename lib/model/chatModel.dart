// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final String clientId;
  final String freelancerId;
  final String projectTitle;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String lastSenderId;
  final int clientUnread;
  final int freelancerUnread;

  ChatModel({
    required this.chatId,
    required this.clientId,
    required this.freelancerId,
    required this.projectTitle,
    required this.lastMessage,
    this.lastMessageTime,
    required this.lastSenderId,
    required this.clientUnread,
    required this.freelancerUnread,
  });

  factory ChatModel.fromMap(String id, Map<String, dynamic> map) => ChatModel(
    chatId: id,
    clientId: map['clientId'] as String? ?? '',
    freelancerId: map['freelancerId'] as String? ?? '',
    projectTitle: map['projectTitle'] as String? ?? '',
    lastMessage: map['lastMessage'] as String? ?? '',
    lastMessageTime:
        map['lastMessageTime'] != null
            ? (map['lastMessageTime'] as Timestamp).toDate()
            : null,
    lastSenderId: map['lastSenderId'] as String? ?? '',
    clientUnread: (map['clientUnread'] as num?)?.toInt() ?? 0,
    freelancerUnread: (map['freelancerUnread'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'chatId': chatId,
    'clientId': clientId,
    'freelancerId': freelancerId,
    'projectTitle': projectTitle,
    'lastMessage': lastMessage,
    'lastMessageTime':
        lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
    'lastSenderId': lastSenderId,
    'clientUnread': clientUnread,
    'freelancerUnread': freelancerUnread,
  };

  
}
