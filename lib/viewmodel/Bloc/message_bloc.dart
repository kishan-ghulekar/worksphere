import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/model/messageModel.dart';
import 'package:super_project/repository/chatRepository.dart';
import 'package:super_project/viewmodel/Events/chatEvent.dart';
import 'package:super_project/viewmodel/States/chatStates.dart';

class MessageBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  MessageBloc(this.repository) : super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessages);
    on<MarkMessagesRead>(_onMarkedRead);
    on<SetTyping>(_onSetTyping);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    await emit.forEach<List<MessageModel>>(
      repository.streamMessages(event.chatId),
      onData: (messages) => MessagesLoaded(messages),
      onError: (e, _) => ChatFailure("Failed to load messages: $e"),
    );
  }

  Future<void> _onSendMessages(
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
      emit(ChatFailure("Failed to send: $e"));
    }
  }

  Future<void> _onMarkedRead(
    MarkMessagesRead event,
    Emitter<ChatState> emit,
  ) async {
    await repository.markAsRead(event.chatId, event.uid, event.isClient);
  }

  Future<void> _onSetTyping(SetTyping event, Emitter<ChatState> emit) async {
    await repository.setTyping(event.chatId, event.uid, event.isTyping);
  }
}
