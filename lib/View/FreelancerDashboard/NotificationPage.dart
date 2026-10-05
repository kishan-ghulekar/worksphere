import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ✅ Use the REAL model — delete any local NotificationModel/NotificationType
// class from this file. This was the source of the earlier type-mismatch bug.
import 'package:super_project/model/notificationModel.dart';
import 'package:super_project/viewmodel/Bloc/notificationBloc.dart';
import 'package:super_project/viewmodel/Events/notificationEvent.dart';
import 'package:super_project/viewmodel/States/notificationState.dart';

/// Shared notification screen for BOTH Client and Freelancer.
/// Data comes from the same `notifications` Firestore collection,
/// filtered by [currentUserId] — so this one screen works for both roles.
/// Push it from either dashboard:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => NotificationScreen(currentUserId: currentUser.uid),
///   ));
class NotificationScreen extends StatefulWidget {
  final String currentUserId;

  /// Optional — handle navigation when a notification is tapped
  /// (e.g. open the related project or bid). If omitted, taps only
  /// mark the notification as read.
  final void Function(NotificationModel notification)? onNotificationTap;

  const NotificationScreen({
    super.key,
    required this.currentUserId,
    this.onNotificationTap,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(
      LoadNotifications(widget.currentUserId),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(
        MarkNotificationRead(notification.notificationId),
      );
    }
    if (widget.onNotificationTap != null) {
      widget.onNotificationTap!(notification);
      return;
    }
    _showSnackbar(notification.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          BlocBuilder<NotificationBloc, Notificationstate>(
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed:
                    () => context.read<NotificationBloc>().add(
                      MarkAllNotificationsRead(widget.currentUserId),
                    ),
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    color: Color(0xFF00D9D9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, Notificationstate>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading &&
              state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NotificationStatus.failure) {
            return Center(
              child: Text(state.errorMessage ?? 'Something went wrong'),
            );
          }

          if (state.notifications.isEmpty) {
            return _buildEmptyState();
          }

          final grouped = _groupByDate(state.notifications);

          return ListView(
            padding: const EdgeInsets.only(top: 8),
            children: [
              for (final group in grouped.entries) ...[
                _buildSectionHeader(group.key),
                ...group.value.map((n) => _buildNotificationCard(n)),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Groups notifications into Today / Yesterday / Earlier based on
  /// their real createdAt timestamp (replaces the old string-matching hack).
  Map<String, List<NotificationModel>> _groupByDate(
    List<NotificationModel> notifications,
  ) {
    final now = DateTime.now();
    final today = <NotificationModel>[];
    final yesterday = <NotificationModel>[];
    final earlier = <NotificationModel>[];

    for (final n in notifications) {
      final diff = now.difference(n.createdAt).inDays;
      final isSameDay =
          n.createdAt.year == now.year &&
          n.createdAt.month == now.month &&
          n.createdAt.day == now.day;
      if (isSameDay) {
        today.add(n);
      } else if (diff == 1) {
        yesterday.add(n);
      } else {
        earlier.add(n);
      }
    }

    return {
      if (today.isNotEmpty) 'Today': today,
      if (yesterday.isNotEmpty) 'Yesterday': yesterday,
      if (earlier.isNotEmpty) 'Earlier': earlier,
    };
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  /// Icon + colors per notification type — mirrors the original design's
  /// teal/grey/tan palette, extended to cover bid/project events.
  (IconData, Color, Color) _styleFor(NotificationType type) {
    switch (type) {
      case NotificationType.newBid:
        return (
          Icons.description_outlined,
          const Color(0xFF00D9D9),
          const Color(0xFFE0F7F7),
        );
      case NotificationType.message:
        return (
          Icons.chat_bubble_outline,
          const Color(0xFF00D9D9),
          const Color(0xFFE0F7F7),
        );
      case NotificationType.bidAccepted:
        return (
          Icons.celebration_outlined,
          const Color(0xFF2E7D32),
          const Color(0xFFE3F5E5),
        );
      case NotificationType.bidRejected:
        return (
          Icons.cancel_outlined,
          const Color(0xFFD32F2F),
          const Color(0xFFFCE4E4),
        );
      case NotificationType.bidWithDrawn:
        return (
          Icons.remove_circle_outline,
          const Color(0xFFEF6C00),
          const Color(0xFFFCEBD9),
        );
      case NotificationType.bidStatusChanged:
        return (
          Icons.trending_up_outlined,
          const Color(0xFF6A1B9A),
          const Color(0xFFEDE0F5),
        );
      case NotificationType.projectStatusChanged:
        return (
          Icons.edit_outlined,
          const Color(0xFF757575),
          const Color(0xFFEEEEEE),
        );
      case NotificationType.generic:
        return (
          Icons.notifications_outlined,
          const Color(0xFF757575),
          const Color(0xFFEEEEEE),
        );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "When you get notifications, they'll show up here",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF757575),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final (icon, iconColor, iconBgColor) = _styleFor(notification.type);

    return Dismissible(
      key: Key(notification.notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<NotificationBloc>().add(
          DeleteNotification(notification.notificationId),
        );
        _showSnackbar('Notification deleted');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleNotificationTap(notification),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      notification.isRead
                                          ? FontWeight.w500
                                          : FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Text(
                              _relativeTime(notification.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 8, top: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00D9D9),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Notification Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackbar('Opening notification settings...');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Clear All'),
                  onTap: () {
                    Navigator.pop(context);
                    final bloc = context.read<NotificationBloc>();
                    for (final n in bloc.state.notifications) {
                      bloc.add(DeleteNotification(n.notificationId));
                    }
                    _showSnackbar('All notifications cleared');
                  },
                ),
              ],
            ),
          ),
    );
  }
}
