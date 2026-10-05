import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/model/notificationModel.dart';
import 'package:super_project/repository/notificationRepository.dart';
import 'package:super_project/viewmodel/Events/notificationEvent.dart';
import 'package:super_project/viewmodel/States/notificationState.dart';

class NotificationBloc extends Bloc<Notificationevent, Notificationstate> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(const Notificationstate()) {
    on<LoadNotifications>(_onLoadNotifiacions);
    on<NotificationUpdated>(_onNotificationUpdated);
     on<MarkNotificationRead>(_onMarkNotificationRead);
    on<MarkAllNotificationsRead>(_onMarkAllNotificationsRead);
    on<DeleteNotification>(_onDeleteNotifications);
  }

  Future<void> _onLoadNotifiacions(
    LoadNotifications event,
    Emitter<Notificationstate> emit
  )async{
    emit(state.copyWith(status: NotificationStatus.loading));
     // emit.forEach keeps listening to the stream for the lifetime of the
    // bloc — same pattern used by ProjectBloc for streamProjects.
    // NOTE: do not emit NotificationStatus.loading here again — doing so
    // would cancel the active stream subscription (the same bug that was
    // fixed in ProjectBloc's create handler).

    await emit.forEach<List<NotificationModel>>(
      _repository.streamNotifications(event.userId),
      onData:(notifications) =>state.copyWith(
        status: NotificationStatus.success,
        notifications: notifications,
      ),
      // ignore: avoid_types_as_parameter_names
      onError:(error,StackTrace) =>state.copyWith(
        status: NotificationStatus.failure,
        errorMessage:'Could not load notifications.',
      ),
    );
  }

  void _onNotificationUpdated(
    NotificationUpdated event,
    Emitter<Notificationstate> emit, 
  ){
    emit(state.copyWith(
      status: NotificationStatus.success,
      notifications: event.notifications,
    ));
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationRead event,
    Emitter<Notificationstate> emit
  )async{
    // Optimistic local update — the Firestore stream will confirm it shortly.
    final updated=state.notifications
    .map((n)=> n.notificationId ==event.notificationId
      ? n.copyWith(isRead: true)
      :n).toList();
      emit(state.copyWith(notifications: updated));
      await _repository.markAsRead(event.notificationId);
  }

  Future<void> _onMarkAllNotificationsRead(
    MarkAllNotificationsRead event,
    Emitter<Notificationstate> emit
  )async{
    final updated =state.notifications.map((n)=>n.copyWith(isRead: true)).toList();
    emit(state.copyWith(notifications: updated));
    await _repository.markAllAsRead(event.userId);
  }

  Future<void> _onDeleteNotifications(
    DeleteNotification event,
    Emitter<Notificationstate> emit
  )async{
    await _repository.deleteNotification(event.notificationId);
  }
}
