// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  bidAccepted, //freelancer hired
  bidRejected, //freelancer not selected
  newBid, // client received a new proposal
  bidWithDrawn, // client: freelancer withdrew a bid
  bidStatusChanged, // freelancer: under_review / shortlisted
  projectStatusChanged, // either side: project moved to In Progress / Completed
  message, // reserved for future chat feature
  generic,
}

NotificationType notificationTypeFromString(String value) {
  return NotificationType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => NotificationType.generic,
  );
}

class NotificationModel {
  final String notificationId;
  final String userId; // recipient — client uid or freelancer uid
  final NotificationType type;
  final String title;
  final String message;
  final String? relatedProjectId;
  final String? relatedBidId;
  final String? actorName; // e.g. the freelancer/client that triggered it
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedProjectId,
    this.relatedBidId,
    this.actorName,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: id,
      userId: map['userId'] as String,
      type: notificationTypeFromString(map['type'] as String? ?? 'generic'),
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      relatedProjectId: map['relatedProjectId'] as String?,
      relatedBidId: map['relatedBidId'] as String?,
      actorName: map['actorName'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'message': message,
      'relatedProjectId': relatedProjectId,
      'actorName': actorName,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      type: type,
      title: title,
      message: message,
      relatedProjectId: relatedProjectId,
      relatedBidId: relatedBidId,
      actorName: actorName,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
