// lib/viewmodel/Bloc/chatBloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/model/chatModel.dart';
import 'package:super_project/model/messageModel.dart';
import 'package:super_project/repository/chatRepository.dart';
import 'package:super_project/viewmodel/Events/chatEvent.dart';
import 'package:super_project/viewmodel/States/chatStates.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  ChatBloc(this.repository) : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesRead>(_onMarkRead);
    on<SetTyping>(_onSetTyping);
  }

  Future<void> _onLoadChats(
    LoadChats event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    await emit.forEach<List<ChatModel>>(
      event.isClient
          ? repository.streamClientChats(event.uid)
          : repository.streamFreelancerChats(event.uid),
      onData: (chats) => ChatsLoaded(chats),
      onError: (e, _) => ChatFailure('Failed to load chats: $e'),
    );
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    await emit.forEach<List<MessageModel>>(
      repository.streamMessages(event.chatId),
      onData: (messages) => MessagesLoaded(messages),
      onError: (e, _) => ChatFailure('Failed to load messages: $e'),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await repository.sendMessage(
        chatId: event.chatId,
        senderId: event.senderId,
        receiverId: event.receiverId,
        message: event.message,
        senderIsClient: event.senderIsClient,
      );
    } catch (e) {
      emit(ChatFailure('Failed to send: $e'));
    }
  }

  Future<void> _onMarkRead(
    MarkMessagesRead event,
    Emitter<ChatState> emit,
  ) async {
    await repository.markAsRead(
        event.chatId, event.uid, event.isClient);
  }

  Future<void> _onSetTyping(
    SetTyping event,
    Emitter<ChatState> emit,
  ) async {
    await repository.setTyping(
        event.chatId, event.uid, event.isTyping);
  }
}