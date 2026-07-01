// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MilestoneModel {
  final String title;
  final bool isCompleted;
  const MilestoneModel({required this.title, required this.isCompleted});

  Map<String, dynamic> toMap() => {'title': title, 'isCompleted': isCompleted};

  factory MilestoneModel.fromMap(Map<String, dynamic> map) => MilestoneModel(
    title: map['title'] as String? ?? '',
    isCompleted: map['isCompleted'] as bool ?? false,
  );
}

class ContractModel  extends Equatable {
  final String contractId; // same as projectId
  final String projectId;
  final String projectTitle;
  final String clientId;
  final String freelancerId;
  final String freelancerName;
  final double agreedAmount;
  final String duration;
  final String status; // active, completed, disputed
  final List<MilestoneModel> milestones;
  final bool workSubmitted;
  final bool paymentReleased;
  final DateTime startDate;
  ContractModel ({
    required this.contractId,
    required this.projectId,
    required this.projectTitle,
    required this.clientId,
    required this.freelancerId,
    required this.freelancerName,
    required this.agreedAmount,
    required this.duration,
    required this.status,
    required this.milestones,
    required this.workSubmitted,
    required this.paymentReleased,
    required this.startDate,
  });

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
    'freelancerId': freelancerId,
    'freelancerName': freelancerName,
    'agreedAmount': agreedAmount,
    'duration': duration,
    'status': status,
    'milestones': milestones.map((m) => m.toMap()).toList(),
    'workSubmitted': workSubmitted,
    'paymentReleased': paymentReleased,
    'startDate': Timestamp.fromDate(startDate),
  };

  factory ContractModel.fromMap(Map<String, dynamic> map) => ContractModel(
    contractId: map['contractId'] as String? ?? '',
    projectId: map['projectId'] as String? ?? '',
    projectTitle: map['projectTitle'] as String? ?? '',
    clientId: map['clientId'] as String? ?? '',
    freelancerId: map['freelancerId'] as String? ?? '',
    freelancerName: map['freelancerName'] as String? ?? '',
    agreedAmount: (map['agreedAmount'] as num?)?.toDouble() ?? 0.0,
    duration: map['duration'] as String? ?? '',
    status: map['status'] as String? ?? 'active',
    milestones:
        (map['milestones'] as List<dynamic>? ?? [])
            .map((m) => MilestoneModel.fromMap(m as Map<String, dynamic>))
            .toList(),
    workSubmitted: map['workSubmitted'] as bool? ?? false,
    paymentReleased: map['paymentReleased'] as bool? ?? false,
    startDate:
        map['startDate'] != null
            ? (map['startDate'] as Timestamp).toDate()
            : DateTime.now(),
  );

   ContractModel  copyWith({
    String? status,
    List<MilestoneModel>? milestones,
    bool? workSubmitted,
    bool? paymentReleased,
  }) =>
      ContractModel(
        contractId: contractId,
        projectId: projectId,
        projectTitle: projectTitle,
        clientId: clientId,
        freelancerId: freelancerId,
        freelancerName: freelancerName,
        agreedAmount: agreedAmount,
        duration: duration,
        status: status ?? this.status,
        milestones: milestones ?? this.milestones,
        workSubmitted: workSubmitted ?? this.workSubmitted,
        paymentReleased: paymentReleased ?? this.paymentReleased,
        startDate: startDate,
      );

      @override
  List<Object?> get props => [contractId, status, workSubmitted, paymentReleased];
}
