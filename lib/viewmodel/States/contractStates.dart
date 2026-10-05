// lib/viewmodel/States/contractStates.dart
import 'package:equatable/equatable.dart';
import 'package:super_project/model/contractModel.dart';

abstract class ContractState extends Equatable {
  const ContractState();
  @override
  List<Object?> get props => [];
}

class ContractInitial extends ContractState {}
class ContractLoading extends ContractState {}

class ContractsLoaded extends ContractState {
  final List<ContractModel> contracts;
  const ContractsLoaded(this.contracts);
  @override
  List<Object?> get props => [contracts];
}

class ContractActionSuccess extends ContractState {
  final String message;

  /// Set only when a contract was just moved to COMPLETED,
  /// so the UI can navigate to PaymentScreen.
  final String? completedContractId;

  const ContractActionSuccess(this.message, {this.completedContractId});

  @override
  List<Object?> get props => [message, completedContractId];
}

class ContractFailure extends ContractState {
  final String message;
  const ContractFailure(this.message);
  @override
  List<Object?> get props => [message];
}