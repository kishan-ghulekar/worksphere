import 'package:equatable/equatable.dart';
import 'package:super_project/model/notificationModel.dart';

enum NotificationStatus { initial, loading, success, failure }

class Notificationstate extends Equatable {
  final NotificationStatus status;
  final List<NotificationModel> notifications;
  final String? errorMessage;

  const Notificationstate({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Notificationstate copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    String? errorMessage,
  }) {
    return Notificationstate(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage];
}
