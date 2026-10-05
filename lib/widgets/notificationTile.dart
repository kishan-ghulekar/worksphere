import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:super_project/model/notificationModel.dart';


class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _iconFor(notification.type);
    final iconColor = _colorFor(notification.type);

    final tile = InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? Colors.transparent : iconColor.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(iconData, color: iconColor, size: 20),
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
                            fontWeight:
                                notification.isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onDismiss == null) return tile;

    return Dismissible(
      key: ValueKey(notification.notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss!(),
      child: tile,
    );
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.bidAccepted:
        return Icons.celebration_outlined;
      case NotificationType.bidRejected:
        return Icons.cancel_outlined;
      case NotificationType.newBid:
        return Icons.person_add_alt_outlined;
      case NotificationType.bidWithDrawn:
        return Icons.remove_circle_outline;
      case NotificationType.bidStatusChanged:
        return Icons.trending_up_outlined;
      case NotificationType.projectStatusChanged:
        return Icons.work_outline;
      case NotificationType.message:
        return Icons.chat_bubble_outline;
      case NotificationType.generic:
        return Icons.notifications_outlined;
    }
  }

  Color _colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.bidAccepted:
        return Colors.green;
      case NotificationType.bidRejected:
        return Colors.red;
      case NotificationType.newBid:
        return Colors.blue;
      case NotificationType.bidWithDrawn:
        return Colors.orange;
      case NotificationType.bidStatusChanged:
        return Colors.purple;
      case NotificationType.projectStatusChanged:
        return Colors.teal;
      case NotificationType.message:
        return Colors.indigo;
      case NotificationType.generic:
        return Colors.grey;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(date);
  }
}