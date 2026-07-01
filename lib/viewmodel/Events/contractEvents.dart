// lib/viewmodel/Events/contractEvent.dart
import 'package:equatable/equatable.dart';

abstract class ContractEvent extends Equatable {
  const ContractEvent();
  @override
  List<Object?> get props => [];
}

class LoadClientContracts extends ContractEvent {
  final String clientId;
  const LoadClientContracts(this.clientId);
  @override
  List<Object?> get props => [clientId];
}

class LoadFreelancerContracts extends ContractEvent {
  final String freelancerId;
  const LoadFreelancerContracts(this.freelancerId);
  @override
  List<Object?> get props => [freelancerId];
}

class UpdateMilestoneRequested extends ContractEvent {
  final String contractId;
  final int milestoneIndex;
  final bool isCompleted;
  const UpdateMilestoneRequested({
    required this.contractId,
    required this.milestoneIndex,
    required this.isCompleted,
  });
  @override
  List<Object?> get props => [contractId, milestoneIndex, isCompleted];
}

class SubmitWorkRequested extends ContractEvent {
  final String contractId;
  const SubmitWorkRequested(this.contractId);
  @override
  List<Object?> get props => [contractId];
}

class ReleasePaymentRequested extends ContractEvent {
  final String contractId;
  const ReleasePaymentRequested(this.contractId);
  @override
  List<Object?> get props => [contractId];
}

class RaiseDisputeRequested extends ContractEvent {
  final String contractId;
  const RaiseDisputeRequested(this.contractId);
  @override
  List<Object?> get props => [contractId];
}