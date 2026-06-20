import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isRead;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isRead = false,
    required this.type,
  });
}

enum NotificationType { proposal, message, projectUpdate, payment }

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      title: 'Project Proposal Received',
      description: 'You have a new proposal for your Website Design...',
      time: '10m',
      icon: Icons.description_outlined,
      iconColor: const Color(0xFF00D9D9),
      iconBgColor: const Color(0xFFE0F7F7),
      type: NotificationType.proposal,
    ),
    NotificationModel(
      id: '2',
      title: 'Message from Alex',
      description: 'Alex sent you a message regarding your proposal...',
      time: '2h',
      icon: Icons.chat_bubble_outline,
      iconColor: const Color(0xFF00D9D9),
      iconBgColor: const Color(0xFFE0F7F7),
      type: NotificationType.message,
    ),
    NotificationModel(
      id: '3',
      title: 'Project Update',
      description: 'Your Social Media Marketing Campaign project...',
      time: '1d',
      icon: Icons.edit_outlined,
      iconColor: const Color(0xFF757575),
      iconBgColor: const Color(0xFFEEEEEE),
      isRead: true,
      type: NotificationType.projectUpdate,
    ),
    NotificationModel(
      id: '4',
      title: 'Payment Received',
      description: 'You have received a payment of \$250 for your...',
      time: '1d',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: const Color(0xFFD4A574),
      iconBgColor: const Color(0xFFF5EDE0),
      isRead: true,
      type: NotificationType.payment,
    ),
  ];

  void _markAsRead(String id) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          title: notifications[index].title,
          description: notifications[index].description,
          time: notifications[index].time,
          icon: notifications[index].icon,
          iconColor: notifications[index].iconColor,
          iconBgColor: notifications[index].iconBgColor,
          isRead: true,
          type: notifications[index].type,
        );
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      notifications =
          notifications
              .map(
                (n) => NotificationModel(
                  id: n.id,
                  title: n.title,
                  description: n.description,
                  time: n.time,
                  icon: n.icon,
                  iconColor: n.iconColor,
                  iconBgColor: n.iconBgColor,
                  isRead: true,
                  type: n.type,
                ),
              )
              .toList();
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((n) => n.id == id);
    });
  }

  void _handleNotificationTap(NotificationModel notification) {
    _markAsRead(notification.id);

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.proposal:
        // Navigate to proposals screen
        _showSnackbar('Opening proposal details...');
        break;
      case NotificationType.message:
        // Navigate to messages screen
        _showSnackbar('Opening message...');
        break;
      case NotificationType.projectUpdate:
        // Navigate to project details
        _showSnackbar('Opening project details...');
        break;
      case NotificationType.payment:
        // Navigate to payment/wallet screen
        _showSnackbar('Opening payment details...');
        break;
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayNotifications =
        notifications
            .where((n) => n.time.contains('m') || n.time.contains('h'))
            .toList();
    final yesterdayNotifications =
        notifications.where((n) => n.time.contains('d')).toList();
    final unreadCount = notifications.where((n) => !n.isRead).length;

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
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFF00D9D9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
      body:
          notifications.isEmpty
              ? _buildEmptyState()
              : ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  if (todayNotifications.isNotEmpty) ...[
                    _buildSectionHeader('Today'),
                    ...todayNotifications.map((n) => _buildNotificationCard(n)),
                  ],
                  if (yesterdayNotifications.isNotEmpty) ...[
                    _buildSectionHeader('Yesterday'),
                    ...yesterdayNotifications.map(
                      (n) => _buildNotificationCard(n),
                    ),
                  ],
                ],
              ),
    );
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
            'When you get notifications, they\'ll show up here',
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
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
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
                      color: notification.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.iconColor,
                      size: 24,
                    ),
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
                              notification.time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.description,
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
                    setState(() {
                      notifications.clear();
                    });
                    _showSnackbar('All notifications cleared');
                  },
                ),
              ],
            ),
          ),
    );
  }
}
