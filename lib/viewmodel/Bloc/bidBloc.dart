// lib/viewmodel/Bloc/bidBloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/model/bidModel.dart';
import 'package:super_project/repository/bidRepository.dart';
import 'package:super_project/viewmodel/Events/bidEvents.dart';
import 'package:super_project/viewmodel/States/bidStates.dart';

class BidBloc extends Bloc<BidEvent, BidState> {
  final BidRepository bidRepository;

  BidBloc(this.bidRepository) : super(BidInitial()) {
    on<SubmitBidRequested>(_onSubmitBid);
    on<LoadBidsForProject>(_onLoadBidsForProject);
    on<LoadMyBids>(_onLoadMyBids);
    on<AcceptBidRequested>(_onAcceptBid);
  }

  Future<void> _onSubmitBid(
    SubmitBidRequested event,
    Emitter<BidState> emit,
  ) async {
    emit(BidLoading());
    try {
      await bidRepository.submitBid(
        projectId: event.projectId,
        freelancerId: event.freelancerId,
        freelancerName: event.freelancerName,
        bidAmount: event.bidAmount,
        estimatedDuration: event.estimatedDuration,
        coverLetter: event.coverLetter,
      );
      emit(BidSubmitSuccess());
    } catch (e) {
      emit(BidFailure("Failed to submit bid: $e"));
    }
  }

  Future<void> _onLoadBidsForProject(
    LoadBidsForProject event,
    Emitter<BidState> emit,
  ) async {
    emit(BidLoading());
    await emit.forEach<List<BidModel>>(
      bidRepository.streamBidsForProject(event.projectId),
      onData: (bids) => BidsForProjectLoaded(bids),
      onError: (error, _) => BidFailure("Failed to load bids: $error"),
    );
  }

  Future<void> _onLoadMyBids(
    LoadMyBids event,
    Emitter<BidState> emit,
  ) async {
    emit(BidLoading());
    await emit.forEach<List<BidModel>>(
      bidRepository.streamMyBids(event.freelancerId),
      onData: (bids) => MyBidsLoaded(bids),
      onError: (error, _) => BidFailure("Failed to load bids: $error"),
    );
  }

  Future<void> _onAcceptBid(
    AcceptBidRequested event,
    Emitter<BidState> emit,
  ) async {
    try {
      await bidRepository.acceptBid(event.bidId, event.projectId);
      emit(BidAcceptSuccess());
    } catch (e) {
      emit(BidFailure("Failed to accept bid: $e"));
    }
  }
}