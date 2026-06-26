// lib/repository/bidRepository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_project/model/bidModel.dart';

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
        .map((snapshot) => snapshot.docs
            .map((doc) => BidModel.fromMap(doc.data()))
            .toList());
  }

  // Freelancer streams their own bids
  Stream<List<BidModel>> streamMyBids(String freelancerId) {
    return _bidsRef
        .where('freelancerId', isEqualTo: freelancerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BidModel.fromMap(doc.data()))
            .toList());
  }

  // Client accepts a bid
  Future<void> acceptBid(String bidId, String projectId) async {
    final batch = _firestore.batch();

    // Update bid status to accepted
    batch.update(_bidsRef.doc(bidId), {'status': 'accepted'});

    // Reject all other bids for this project
    final otherBids = await _bidsRef
        .where('projectId', isEqualTo: projectId)
        .where('status', isEqualTo: 'pending')
        .get();

    for (final doc in otherBids.docs) {
      if (doc.id != bidId) {
        batch.update(doc.reference, {'status': 'rejected'});
      }
    }

    // Update project status to In Progress
    batch.update(
      _firestore.collection('projects').doc(projectId),
      {'status': 'In Progress'},
    );

    await batch.commit();
  }
  // Freelancer withdraws their bid
Future<void> withdrawBid(String bidId) async {
  await _bidsRef.doc(bidId).update({'status': 'withdrawn'});
}

// Stream bids for a specific freelancer (already have this — no change needed)
// Stream<List<BidModel>> streamMyBids(String freelancerId) {
//   return _bidsRef
//       .where('freelancerId', isEqualTo: freelancerId)
//       .orderBy('createdAt', descending: true)
//       .snapshots()
//       .map((snapshot) => snapshot.docs
//           .map((doc) => BidModel.fromMap(doc.data()))
//           .toList());
// }
}