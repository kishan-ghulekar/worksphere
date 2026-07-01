// lib/repository/contractRepository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_project/model/contractModel.dart';

class ContractRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _contractsRef =>
      _firestore.collection('contracts');

  // Called when client hires a freelancer — creates contract automatically
  Future<void> createContract({
    required String projectId,
    required String projectTitle,
    required String clientId,
    required String freelancerId,
    required String freelancerName,
    required double agreedAmount,
    required String duration,
  }) async {
    final defaultMilestones = [
      MilestoneModel(title: 'Project Kickoff', isCompleted: false),
      MilestoneModel(title: 'First Delivery', isCompleted: false),
      MilestoneModel(title: 'Review & Feedback', isCompleted: false),
      MilestoneModel(title: 'Final Delivery', isCompleted: false),
    ];

    final contract = ContractModel(
      contractId: projectId,
      projectId: projectId,
      projectTitle: projectTitle,
      clientId: clientId,
      freelancerId: freelancerId,
      freelancerName: freelancerName,
      agreedAmount: agreedAmount,
      duration: duration,
      status: 'active',
      milestones: defaultMilestones,
      workSubmitted: false,
      paymentReleased: false,
      startDate: DateTime.now(),
    );

    await _contractsRef.doc(projectId).set(contract.toMap());
  }

  // Stream contracts for client
  Stream<List<ContractModel>> streamClientContracts(String clientId) {
    return _contractsRef
        .where('clientId', isEqualTo: clientId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ContractModel.fromMap(doc.data()))
            .toList());
  }

  // Stream contracts for freelancer
  Stream<List<ContractModel>> streamFreelancerContracts(
      String freelancerId) {
    return _contractsRef
        .where('freelancerId', isEqualTo: freelancerId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ContractModel.fromMap(doc.data()))
            .toList());
  }

  // Freelancer marks milestone done
  Future<void> updateMilestone(
      String contractId, int index, bool isCompleted) async {
    final doc = await _contractsRef.doc(contractId).get();
    final contract = ContractModel.fromMap(doc.data()!);
    final updated = List<MilestoneModel>.from(contract.milestones);
    updated[index] = MilestoneModel(
      title: updated[index].title,
      isCompleted: isCompleted,
    );
    await _contractsRef
        .doc(contractId)
        .update({'milestones': updated.map((m) => m.toMap()).toList()});
  }

  // Freelancer submits work
  Future<void> submitWork(String contractId) async {
    await _contractsRef
        .doc(contractId)
        .update({'workSubmitted': true});
  }

  // Client releases payment and marks completed
  Future<void> releasePayment(String contractId) async {
    final batch = _firestore.batch();
    batch.update(_contractsRef.doc(contractId), {
      'paymentReleased': true,
      'status': 'completed',
    });
    // Also update the project status
    final contract = ContractModel.fromMap(
        (await _contractsRef.doc(contractId).get()).data()!);
    batch.update(
      _firestore.collection('projects').doc(contract.projectId),
      {'status': 'Completed'},
    );
    await batch.commit();
  }

  // Raise dispute
  Future<void> raiseDispute(String contractId) async {
    await _contractsRef
        .doc(contractId)
        .update({'status': 'disputed'});
  }
}