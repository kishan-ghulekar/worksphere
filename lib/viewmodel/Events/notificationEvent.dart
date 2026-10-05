import 'package:equatable/equatable.dart';
import 'package:super_project/model/notificationModel.dart';

abstract class Notificationevent extends Equatable {
  const Notificationevent();

  @override
  List<Object?> get props => [];
}

/// Starts listening to the current user's notification stream.
class LoadNotifications extends Notificationevent {
  final String userId;
  const LoadNotifications(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Internal event — fired whenever the Firestore stream emits new data.
class NotificationUpdated extends Notificationevent {
  final List<NotificationModel> notifications;
  const NotificationUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

 
class MarkNotificationRead extends Notificationevent {
  final String notificationId;
  const MarkNotificationRead(this.notificationId);
 
  @override
  List<Object?> get props => [notificationId];
}
 

class MarkAllNotificationsRead extends Notificationevent {
  final String userId;
  const MarkAllNotificationsRead(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DeleteNotification extends Notificationevent {
  final String notificationId;
  const DeleteNotification(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}
