// lib/model/contractModel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ContractStatus {
  pending,
  active,
  completed,
  cancelled;

  String get value => name; // 'pending', 'active', etc.

  static ContractStatus fromString(String s) {
    return ContractStatus.values.firstWhere(
      (e) => e.name == s.toLowerCase(),
      orElse: () => ContractStatus.pending,
    );
  }

  // Valid transitions
  List<ContractStatus> get allowedTransitions {
    switch (this) {
      case ContractStatus.pending:
        return [ContractStatus.active, ContractStatus.cancelled];
      case ContractStatus.active:
        return [ContractStatus.completed, ContractStatus.cancelled];
      case ContractStatus.completed:
        return [];
      case ContractStatus.cancelled:
        return [];
    }
  }

  bool canTransitionTo(ContractStatus next) =>
      allowedTransitions.contains(next);
}

class MilestoneModel {
  final String title;
  final bool isCompleted;

  const MilestoneModel({required this.title, required this.isCompleted});

  Map<String, dynamic> toMap() => {
        'title': title,
        'isCompleted': isCompleted,
      };

  factory MilestoneModel.fromMap(Map<String, dynamic> map) => MilestoneModel(
        title: map['title'] as String? ?? '',
        isCompleted: map['isCompleted'] as bool? ?? false,
      );
}

class ContractModel extends Equatable {
  final String contractId;
  final String projectId;
  final String projectTitle;
  final String clientId;
  final String clientName;
  final String freelancerId;
  final String freelancerName;
  final double agreedAmount;
  final String duration;
  final ContractStatus status;
  final List<MilestoneModel> milestones;
  final bool workSubmitted;
  final bool paymentReleased;
  final DateTime startDate;
  final DateTime? deadline;

  /// 'pending' | 'success'. Written ONLY by the backend after Razorpay
  /// verification. Different from [paymentReleased] ("released to freelancer").
  final String paymentStatus;

  const ContractModel({
    required this.contractId,
    required this.projectId,
    required this.projectTitle,
    required this.clientId,
    required this.clientName,
    required this.freelancerId,
    required this.freelancerName,
    required this.agreedAmount,
    required this.duration,
    required this.status,
    required this.milestones,
    required this.workSubmitted,
    required this.paymentReleased,
    required this.startDate,
    this.deadline,
    this.paymentStatus = 'pending',
  });

  bool get isPaid => paymentStatus == 'success';

  double get progressValue {
    if (milestones.isEmpty) return 0;
    final done = milestones.where((m) => m.isCompleted).length;
    return done / milestones.length;
  }

  Map<String, dynamic> toMap() => {
        'contractId': contractId,
        'projectId': projectId,
        'projectTitle': projectTitle,
        'clientId': clientId,
        'clientName': clientName,
        'freelancerId': freelancerId,
        'freelancerName': freelancerName,
        'agreedAmount': agreedAmount,
        'duration': duration,
        'status': status.value,
        'milestones': milestones.map((m) => m.toMap()).toList(),
        'workSubmitted': workSubmitted,
        'paymentReleased': paymentReleased,
        'paymentStatus': paymentStatus,
        'startDate': Timestamp.fromDate(startDate),
        'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      };

  factory ContractModel.fromMap(Map<String, dynamic> map) => ContractModel(
        contractId: map['contractId'] as String? ?? '',
        projectId: map['projectId'] as String? ?? '',
        projectTitle: map['projectTitle'] as String? ?? '',
        clientId: map['clientId'] as String? ?? '',
        clientName: map['clientName'] as String? ?? '',
        freelancerId: map['freelancerId'] as String? ?? '',
        freelancerName: map['freelancerName'] as String? ?? '',
        agreedAmount: (map['agreedAmount'] as num?)?.toDouble() ?? 0.0,
        duration: map['duration'] as String? ?? '',
        status: ContractStatus.fromString(map['status'] as String? ?? 'pending'),
        milestones: (map['milestones'] as List<dynamic>? ?? [])
            .map((m) => MilestoneModel.fromMap(m as Map<String, dynamic>))
            .toList(),
        workSubmitted: map['workSubmitted'] as bool? ?? false,
        paymentReleased: map['paymentReleased'] as bool? ?? false,
        paymentStatus: map['paymentStatus'] as String? ?? 'pending',
        startDate: map['startDate'] != null
            ? (map['startDate'] as Timestamp).toDate()
            : DateTime.now(),
        deadline: map['deadline'] != null
            ? (map['deadline'] as Timestamp).toDate()
            : null,
      );

  ContractModel copyWith({
    ContractStatus? status,
    List<MilestoneModel>? milestones,
    bool? workSubmitted,
    bool? paymentReleased,
    String? paymentStatus,
  }) =>
      ContractModel(
        contractId: contractId,
        projectId: projectId,
        projectTitle: projectTitle,
        clientId: clientId,
        clientName: clientName,
        freelancerId: freelancerId,
        freelancerName: freelancerName,
        agreedAmount: agreedAmount,
        duration: duration,
        status: status ?? this.status,
        milestones: milestones ?? this.milestones,
        workSubmitted: workSubmitted ?? this.workSubmitted,
        paymentReleased: paymentReleased ?? this.paymentReleased,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        startDate: startDate,
        deadline: deadline,
      );

  @override
  List<Object?> get props =>
      [contractId, status, workSubmitted, paymentReleased, paymentStatus];
}