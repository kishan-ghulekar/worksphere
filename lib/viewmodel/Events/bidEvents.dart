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
  final String projectTitle; // ADD THIS
  final String freelancerName;
  final double bidAmount;
  final String estimatedDuration;
  final String coverLetter;

  const SubmitBidRequested({
    required this.projectId,
    required this.freelancerId,
    required this.projectTitle, 
    required this.freelancerName,
    required this.bidAmount,
    required this.estimatedDuration,
    required this.coverLetter
  });

  @override
  List<Object?> get props =>
      [projectId,projectTitle, freelancerId, bidAmount, estimatedDuration, coverLetter];
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

class WithdrawBidRequested extends BidEvent {
  final String bidId;
  const WithdrawBidRequested(this.bidId);

  @override
  List<Object?> get props => [bidId];
}

class FilterApplicationsByStatus extends BidEvent {
  final String status; // 'all', 'pending', 'under_review', 'shortlisted', 'accepted', 'rejected'
  const FilterApplicationsByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class SearchApplications extends BidEvent {
  final String query;
  const SearchApplications(this.query);

  @override
  List<Object?> get props => [query];
}