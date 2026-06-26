// Add projectTitle to BidModel so we can display it without fetching the project

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BidModel extends Equatable {
  final String bidId;
  final String projectId;
  final String projectTitle; // ADD THIS
  final String freelancerId;
  final String freelancerName;
  final double bidAmount;
  final String estimatedDuration;
  final String coverLetter;
  final String status;
  final DateTime createdAt;

  const BidModel({
    required this.bidId,
    required this.projectId,
    required this.projectTitle, // ADD THIS
    required this.freelancerId,
    required this.freelancerName,
    required this.bidAmount,
    required this.estimatedDuration,
    required this.coverLetter,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bidId': bidId,
      'projectId': projectId,
      'projectTitle': projectTitle, // ADD THIS
      'freelancerId': freelancerId,
      'freelancerName': freelancerName,
      'bidAmount': bidAmount,
      'estimatedDuration': estimatedDuration,
      'coverLetter': coverLetter,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BidModel.fromMap(Map<String, dynamic> map) {
    return BidModel(
      bidId: map['bidId'] as String? ?? '',
      projectId: map['projectId'] as String? ?? '',
      projectTitle: map['projectTitle'] as String? ?? '', // ADD THIS
      freelancerId: map['freelancerId'] as String? ?? '',
      freelancerName: map['freelancerName'] as String? ?? '',
      bidAmount: (map['bidAmount'] as num?)?.toDouble() ?? 0.0,
      estimatedDuration: map['estimatedDuration'] as String? ?? '',
      coverLetter: map['coverLetter'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  BidModel copyWith({String? status}) {
    return BidModel(
      bidId: bidId,
      projectId: projectId,
      projectTitle: projectTitle,
      freelancerId: freelancerId,
      freelancerName: freelancerName,
      bidAmount: bidAmount,
      estimatedDuration: estimatedDuration,
      coverLetter: coverLetter,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [bidId, projectId, freelancerId, status];
}