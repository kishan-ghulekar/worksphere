// lib/viewmodel/Bloc/contractBloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/model/contractModel.dart';
import 'package:super_project/repository/contractRepository.dart';
import 'package:super_project/viewmodel/Events/contractEvents.dart';
import 'package:super_project/viewmodel/States/contractStates.dart';

class ContractBloc extends Bloc<ContractEvent, ContractState> {
  final ContractRepository repository;

  ContractBloc(this.repository) : super(ContractInitial()) {
    on<LoadClientContracts>(_onLoadClientContracts);
    on<LoadFreelancerContracts>(_onLoadFreelancerContracts);
    on<UpdateMilestoneRequested>(_onUpdateMilestone);
    on<SubmitWorkRequested>(_onSubmitWork);
    on<ReleasePaymentRequested>(_onReleasePayment);
    on<RaiseDisputeRequested>(_onRaiseDispute);
  }

  Future<void> _onLoadClientContracts(
    LoadClientContracts event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractLoading());
    await emit.forEach<List<ContractModel>>(
      repository.streamClientContracts(event.clientId),
      onData: (contracts) => ContractsLoaded(contracts),
      onError: (error, _) =>
          ContractFailure("Failed to load contracts: $error"),
    );
  }

  Future<void> _onLoadFreelancerContracts(
    LoadFreelancerContracts event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractLoading());
    await emit.forEach<List<ContractModel>>(
      repository.streamFreelancerContracts(event.freelancerId),
      onData: (contracts) => ContractsLoaded(contracts),
      onError: (error, _) =>
          ContractFailure("Failed to load contracts: $error"),
    );
  }

  Future<void> _onUpdateMilestone(
    UpdateMilestoneRequested event,
    Emitter<ContractState> emit,
  ) async {
    try {
      await repository.updateMilestone(
        event.contractId,
        event.milestoneIndex,
        event.isCompleted,
      );
    } catch (e) {
      emit(ContractFailure("Failed to update milestone: $e"));
    }
  }

  Future<void> _onSubmitWork(
    SubmitWorkRequested event,
    Emitter<ContractState> emit,
  ) async {
    try {
      await repository.submitWork(event.contractId);
      emit(const ContractActionSuccess('Work submitted successfully!'));
    } catch (e) {
      emit(ContractFailure("Failed to submit work: $e"));
    }
  }

  Future<void> _onReleasePayment(
    ReleasePaymentRequested event,
    Emitter<ContractState> emit,
  ) async {
    try {
      await repository.releasePayment(event.contractId);
      emit(const ContractActionSuccess('Payment released! Project completed.'));
    } catch (e) {
      emit(ContractFailure("Failed to release payment: $e"));
    }
  }

  Future<void> _onRaiseDispute(
    RaiseDisputeRequested event,
    Emitter<ContractState> emit,
  ) async {
    try {
      await repository.raiseDispute(event.contractId);
      emit(const ContractActionSuccess('Dispute raised successfully.'));
    } catch (e) {
      emit(ContractFailure("Failed to raise dispute: $e"));
    }
  }
}