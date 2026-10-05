import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_project/model/notificationModel.dart';

/// Handles all Firestore access for the `notifications` collection.
/// Both client and freelancer notifications live in the same collection,
/// scoped by `userId` — this mirrors how bids/projects are structured
/// in the rest of the app.
class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  /// Creates a notification document for [userId].
  /// Call this from BidRepository / ProjectRepository whenever a
  /// notifiable event happens (hire, new bid, status change, etc.)
  Future<void> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? relatedProjectId,
    String? relatedBidId,
    String? actorName,
    bool? isRead,
  }) async {
    final model = NotificationModel(
      notificationId: '', // Firestore assigns the id
      userId: userId,
      type: type,
      title: title,
      message: message,
      relatedProjectId: relatedProjectId,
      relatedBidId: relatedBidId,
      actorName: actorName,
      createdAt: DateTime.now(),
    );
    await _collection.add(model.toMap());
  }

  /// Real-time stream of notifications for the logged-in user,
  /// newest first. Requires a composite index: userId ↑, createdAt ↓.
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Real-time unread count — used for the bell-icon badge in the AppBar.
  Stream<int> streamUnreadCount(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAsRead(String notificationId) async {
    await _collection.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final unread = await _collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _collection.doc(notificationId).delete();
  }
}