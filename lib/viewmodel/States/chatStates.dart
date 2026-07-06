// lib/viewmodel/States/chatState.dart
import 'package:equatable/equatable.dart';
import 'package:super_project/model/chatModel.dart';
import 'package:super_project/model/messageModel.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<ChatModel> chats;
  const ChatsLoaded(this.chats);
  @override
  List<Object?> get props => [chats];
}

class MessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  const MessagesLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class ChatFailure extends ChatState {
  final String message;
  const ChatFailure(this.message);
  @override
  List<Object?> get props => [message];
}