// lib/repository/bidRepository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_project/model/bidModel.dart';
import 'package:super_project/model/projectModel.dart';

class BidRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    // Get the bid data first
    final bidDoc = await _bidsRef.doc(bidId).get();
    final bid = BidModel.fromMap(bidDoc.data()!);

    // Get the project data
    final projectDoc =
        await _firestore.collection('projects').doc(projectId).get();
    final project = ProjectModel.fromMap(projectDoc.data()!);

    // Accept this bid
    batch.update(_bidsRef.doc(bidId), {'status': 'accepted'});

    // Reject all other pending bids
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

    // Update project status
    batch.update(_firestore.collection('projects').doc(projectId), {
      'status': 'In Progress',
    });

    // Create contract document
    final contractRef = _firestore.collection('contracts').doc(projectId);

    final defaultMilestones = [
      {'title': 'Project Kickoff', 'isCompleted': false},
      {'title': 'First Delivery', 'isCompleted': false},
      {'title': 'Review & Feedback', 'isCompleted': false},
      {'title': 'Final Delivery', 'isCompleted': false},
    ];

    batch.set(contractRef, {
      'contractId': projectId,
      'projectId': projectId,
      'projectTitle': project.title,
      'clientId': project.clientId,
      'freelancerId': bid.freelancerId,
      'freelancerName': bid.freelancerName,
      'agreedAmount': bid.bidAmount,
      'duration': bid.estimatedDuration,
      'status': 'active',
      'milestones': defaultMilestones,
      'workSubmitted': false,
      'paymentReleased': false,
      'startDate': Timestamp.fromDate(DateTime.now()),
    });

    await batch.commit();
  }

  Future<void> withdrawBid(String bidId) async {
  await _bidsRef.doc(bidId).update({'status': 'withdrawn'});
}
}
