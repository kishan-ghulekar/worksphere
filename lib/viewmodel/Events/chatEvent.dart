// lib/viewmodel/Events/chatEvent.dart
import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {
  final String uid;
  final bool isClient;
  const LoadChats({required this.uid, required this.isClient});
  @override
  List<Object?> get props => [uid, isClient];
}

class SendMessage extends ChatEvent {
  final String chatId;
  final String senderId;
  final String receiverId;
  final String message;
  final bool senderIsClient;

  const SendMessage({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.senderIsClient,
  });

  @override
  List<Object?> get props => [chatId, senderId, message];
}

class LoadMessages extends ChatEvent {
  final String chatId;
  const LoadMessages(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

class MarkMessagesRead extends ChatEvent {
  final String chatId;
  final String uid;
  final bool isClient;
  const MarkMessagesRead({
    required this.chatId,
    required this.uid,
    required this.isClient,
  });
  @override
  List<Object?> get props => [chatId, uid];
}

class SetTyping extends ChatEvent {
  final String chatId;
  final String uid;
  final bool isTyping;
  const SetTyping({
    required this.chatId,
    required this.uid,
    required this.isTyping,
  });
  @override
  List<Object?> get props => [chatId, uid, isTyping];
}