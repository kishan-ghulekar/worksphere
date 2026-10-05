// lib/repository/bidRepository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_project/model/bidModel.dart';
import 'package:super_project/model/notificationModel.dart';
import 'package:super_project/model/projectModel.dart';
import 'package:super_project/repository/notificationRepository.dart';

class BidRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ NEW — used to create notifications at each trigger point below.
  final NotificationRepository _notificationRepository =
      NotificationRepository();

  CollectionReference<Map<String, dynamic>> get _bidsRef =>
      _firestore.collection('bids');

  // Freelancer submits a bid
  Future<void> submitBid({
    required String projectId,
    required String freelancerId,
    required String projectTitle,
    required String freelancerName,
    required double bidAmount,
    required String estimatedDuration,
    required String coverLetter,
  }) async {
    final docRef = _bidsRef.doc();
    final bid = BidModel(
      bidId: docRef.id,
      projectId: projectId,
      projectTitle: projectTitle,
      freelancerId: freelancerId,
      freelancerName: freelancerName,
      bidAmount: bidAmount,
      estimatedDuration: estimatedDuration,
      coverLetter: coverLetter,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    await docRef.set(bid.toMap());

    // ✅ NEW — notify the client that a new proposal came in.
    final projectDoc =
        await _firestore.collection('projects').doc(projectId).get();
    final clientId = projectDoc.data()?['clientId'] as String?;

    if (clientId != null) {
      await _notificationRepository.createNotification(
        userId: clientId,
        type: NotificationType.newBid,
        title: 'New proposal received',
        message: '$freelancerName submitted a bid on "$projectTitle"',
        relatedProjectId: projectId,
        relatedBidId: docRef.id,
        actorName: freelancerName,
      );
    }
  }

  // Client streams all bids for a project
  Stream<List<BidModel>> streamBidsForProject(String projectId) {
    return _bidsRef
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => BidModel.fromMap(doc.data())).toList(),
        );
  }

  // Freelancer streams their own bids
  Stream<List<BidModel>> streamMyBids(String freelancerId) {
    return _bidsRef
        .where('freelancerId', isEqualTo: freelancerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => BidModel.fromMap(doc.data())).toList(),
        );
  }

  // Client accepts a bid
  // In BidRepository, update acceptBid method:
  Future<void> acceptBid(String bidId, String projectId) async {
    final batch = _firestore.batch();

    final bidDoc = await _bidsRef.doc(bidId).get();
    final bid = BidModel.fromMap(bidDoc.data()!);

    final projectDoc =
        await _firestore.collection('projects').doc(projectId).get();
    final project = ProjectModel.fromMap(projectDoc.data()!);

    // Get client name from clients collection
    final clientDoc =
        await _firestore.collection('clients').doc(project.clientId).get();
    final clientName =
        clientDoc.exists
            ? (clientDoc.data()!['name'] as String? ?? 'Client')
            : 'Client';

    batch.update(_bidsRef.doc(bidId), {'status': 'accepted'});

    final otherBids =
        await _bidsRef
            .where('projectId', isEqualTo: projectId)
            .where('status', isEqualTo: 'pending')
            .get();

    for (final doc in otherBids.docs) {
      if (doc.id != bidId) {
        batch.update(doc.reference, {'status': 'rejected'});
      }
    }

    // Project stays Open until client activates contract
    batch.update(_firestore.collection('projects').doc(projectId), {
      'status': 'Pending',
    });

    // Create contract with PENDING status
    final contractRef = _firestore.collection('contracts').doc(projectId);
    batch.set(contractRef, {
      'contractId': projectId,
      'projectId': projectId,
      'projectTitle': project.title,
      'clientId': project.clientId,
      'clientName': clientName,
      'freelancerId': bid.freelancerId,
      'freelancerName': bid.freelancerName,
      'agreedAmount': bid.bidAmount,
      'duration': bid.estimatedDuration,
      'status': 'pending', // ← starts as pending
      'milestones': [
        {'title': 'Project Kickoff', 'isCompleted': false},
        {'title': 'First Delivery', 'isCompleted': false},
        {'title': 'Review & Feedback', 'isCompleted': false},
        {'title': 'Final Delivery', 'isCompleted': false},
      ],
      'workSubmitted': false,
      'paymentReleased': false,
      'startDate': Timestamp.fromDate(DateTime.now()),
      'deadline': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 30)),
      ),
    });

    await batch.commit();

    // ✅ NEW — notify the hired freelancer.
    await _notificationRepository.createNotification(
      userId: bid.freelancerId,
      type: NotificationType.bidAccepted,
      title: "You're hired! 🎉",
      message: 'You were selected for "${project.title}"',
      relatedProjectId: projectId,
      relatedBidId: bidId,
      actorName: clientName,
    );

    // ✅ NEW — notify every rejected freelancer.
    for (final doc in otherBids.docs) {
      if (doc.id == bidId) continue;
      final rejectedBid = BidModel.fromMap(doc.data());
      await _notificationRepository.createNotification(
        userId: rejectedBid.freelancerId,
        type: NotificationType.bidRejected,
        title: 'Application update',
        message: 'Your proposal for "${project.title}" was not selected',
        relatedProjectId: projectId,
        relatedBidId: doc.id,
        actorName: clientName,
      );
    }
  }

  Future<void> withdrawBid(String bidId) async {
    final bidDoc = await _bidsRef.doc(bidId).get();
    final bid = BidModel.fromMap(bidDoc.data()!);

    await _bidsRef.doc(bidId).update({'status': 'withdrawn'});

    // ✅ NEW — notify the client that a freelancer pulled out.
    final projectDoc =
        await _firestore.collection('projects').doc(bid.projectId).get();
    final clientId = projectDoc.data()?['clientId'] as String?;

    if (clientId != null) {
      await _notificationRepository.createNotification(
        userId: clientId,
        type: NotificationType.bidWithDrawn,
        title: 'Proposal withdrawn',
        message:
            '${bid.freelancerName} withdrew their bid on "${bid.projectTitle}"',
        relatedProjectId: bid.projectId,
        relatedBidId: bidId,
        actorName: bid.freelancerName,
      );
    }
  }

  Future<void> updateBidStatus(String bidId, String status) async {
    final bidDoc = await _bidsRef.doc(bidId).get();
    final bid = BidModel.fromMap(bidDoc.data()!);

    await _bidsRef.doc(bidId).update({'status': status});

    // ✅ NEW — notify the freelancer of pipeline movement
    // (e.g. under_review / shortlisted).
    await _notificationRepository.createNotification(
      userId: bid.freelancerId,
      type: NotificationType.bidStatusChanged,
      title: 'Application status updated',
      message: 'Your proposal for "${bid.projectTitle}" is now $status',
      relatedProjectId: bid.projectId,
      relatedBidId: bidId,
    );
  }
}