// lib/viewmodel/Events/bidEvent.dart
import 'package:equatable/equatable.dart';

abstract class BidEvent extends Equatable {
  const BidEvent();

  @override
  List<Object?> get props => [];
}

class SubmitBidRequested extends BidEvent {
  final String projectId;
  final String freelancerId;
  final String freelancerName;
  final double bidAmount;
  final String estimatedDuration;
  final String coverLetter;

  const SubmitBidRequested({
    required this.projectId,
    required this.freelancerId,
    required this.freelancerName,
    required this.bidAmount,
    required this.estimatedDuration,
    required this.coverLetter,
  });

  @override
  List<Object?> get props =>
      [projectId, freelancerId, bidAmount, estimatedDuration, coverLetter];
}

class LoadBidsForProject extends BidEvent {
  final String projectId;
  const LoadBidsForProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class LoadMyBids extends BidEvent {
  final String freelancerId;
  const LoadMyBids(this.freelancerId);

  @override
  List<Object?> get props => [freelancerId];
}

class AcceptBidRequested extends BidEvent {
  final String bidId;
  final String projectId;
  const AcceptBidRequested({required this.bidId, required this.projectId});

  @override
  List<Object?> get props => [bidId, projectId];
}