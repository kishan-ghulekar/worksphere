// lib/repository/contractRepository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_project/model/contractModel.dart';

class ContractRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection('contracts');

  // Create contract with pending status when bid is accepted
  Future<void> createContract({
    required String projectId,
    required String projectTitle,
    required String clientId,
    required String clientName,
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
      clientName: clientName,
      freelancerId: freelancerId,
      freelancerName: freelancerName,
      agreedAmount: agreedAmount,
      duration: duration,
      status: ContractStatus.pending, // always starts as pending
      milestones: defaultMilestones,
      workSubmitted: false,
      paymentReleased: false,
      startDate: DateTime.now(),
      deadline: DateTime.now().add(const Duration(days: 30)),
    );

    await _ref.doc(projectId).set(contract.toMap());
  }

  // Generic status transition with validation
  Future<void> transitionStatus(
    String contractId,
    ContractStatus currentStatus,
    ContractStatus newStatus,
  ) async {
    if (!currentStatus.canTransitionTo(newStatus)) {
      throw Exception(
          'Invalid transition: ${currentStatus.value} → ${newStatus.value}');
    }

    final batch = _firestore.batch();

    batch.update(_ref.doc(contractId), {'status': newStatus.value});

    // Also update project status in sync
    final contract =
        ContractModel.fromMap((await _ref.doc(contractId).get()).data()!);

    String projectStatus;
    switch (newStatus) {
      case ContractStatus.active:
        projectStatus = 'In Progress';
        break;
      case ContractStatus.completed:
        projectStatus = 'Completed';
        break;
      case ContractStatus.cancelled:
        projectStatus = 'Closed';
        break;
      default:
        projectStatus = 'Open';
    }

    batch.update(
      _firestore.collection('projects').doc(contract.projectId),
      {'status': projectStatus},
    );

    await batch.commit();
  }

  // Stream by clientId
  Stream<List<ContractModel>> streamClientContracts(String clientId) {
    return _ref
        .where('clientId', isEqualTo: clientId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => ContractModel.fromMap(d.data())).toList());
  }

  // Stream by freelancerId
  Stream<List<ContractModel>> streamFreelancerContracts(
      String freelancerId) {
    return _ref
        .where('freelancerId', isEqualTo: freelancerId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => ContractModel.fromMap(d.data())).toList());
  }

  Future<void> updateMilestone(
      String contractId, int index, bool isCompleted) async {
    final doc = await _ref.doc(contractId).get();
    final contract = ContractModel.fromMap(doc.data()!);
    final updated = List<MilestoneModel>.from(contract.milestones);
    updated[index] =
        MilestoneModel(title: updated[index].title, isCompleted: isCompleted);
    await _ref.doc(contractId).update(
        {'milestones': updated.map((m) => m.toMap()).toList()});
  }

  Future<void> submitWork(String contractId) async {
    await _ref.doc(contractId).update({'workSubmitted': true});
  }

  Future<void> releasePayment(String contractId) async {
    await _ref.doc(contractId).update({'paymentReleased': true});
  }
}