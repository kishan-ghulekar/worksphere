// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timeStamp;
  final bool isRead;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timeStamp,
    required this.isRead,
  });

  Map<String, dynamic> toMap() => {
    'messageId': messageId,
    'senderId': senderId,
    'receiverId': receiverId,
    'message': message,
    'timestamp': Timestamp.fromDate(timeStamp),
    'isRead': isRead,
  };

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
    messageId: map['messageId'] as String? ?? '',
    senderId: map['senderId'] as String? ?? '',
    receiverId: map['receiverId'] as String? ?? '',
    message: map['message'] as String? ?? '',
    timeStamp:
        map['timestamp'] != null
            ? (map['timestamp'] as Timestamp).toDate()
            : DateTime.now(),
    isRead: map['isRead'] as bool? ?? false,
  );
}
