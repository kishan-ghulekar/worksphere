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
    on<WithdrawBidRequested>(_onWithdrawBid);
    on<FilterApplicationsByStatus>(_onFilterApplications);
    on<SearchApplications>(_onSearchApplications);
  }

  Future<void> _onSubmitBid(
    SubmitBidRequested event,
    Emitter<BidState> emit,
  ) async {
    emit(BidLoading());
    try {
      await bidRepository.submitBid(
        projectId: event.projectId,
        
        projectTitle: event.projectTitle,
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

  // Future<void> _onLoadMyBids(LoadMyBids event, Emitter<BidState> emit) async {
  //   emit(BidLoading());
  //   await emit.forEach<List<BidModel>>(
  //     bidRepository.streamMyBids(event.freelancerId),
  //     onData: (bids) => MyBidsLoaded(bids),
  //     onError: (error, _) => BidFailure("Failed to load bids: $error"),
  //   );
  // }

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
  List<BidModel> _allBids = [];
String _activeFilter = 'all';

Future<void> _onLoadMyBids(
  LoadMyBids event,
  Emitter<BidState> emit,
) async {
  emit(BidLoading());
  await emit.forEach<List<BidModel>>(
    bidRepository.streamMyBids(event.freelancerId),
    onData: (bids) {
      _allBids = bids;
      final filtered = _applyFilter(bids, _activeFilter);
      return ApplicationsLoaded(
        allBids: bids,
        filteredBids: filtered,
        activeFilter: _activeFilter,
      );
    },
    onError: (error, _) => BidFailure("Failed to load applications: $error"),
  );
}

Future<void> _onWithdrawBid(
  WithdrawBidRequested event,
  Emitter<BidState> emit,
) async {
  try {
    await bidRepository.withdrawBid(event.bidId);
    emit(BidWithdrawSuccess());
  } catch (e) {
    emit(BidFailure("Failed to withdraw: $e"));
  }
}

Future<void> _onFilterApplications(
  FilterApplicationsByStatus event,
  Emitter<BidState> emit,
) async {
  _activeFilter = event.status;
  final filtered = _applyFilter(_allBids, event.status);
  emit(ApplicationsLoaded(
    allBids: _allBids,
    filteredBids: filtered,
    activeFilter: event.status,
  ));
}

Future<void> _onSearchApplications(
  SearchApplications event,
  Emitter<BidState> emit,
) async {
  final query = event.query.toLowerCase();
  final filtered = _allBids.where((bid) {
    final matchesSearch = bid.projectTitle.toLowerCase().contains(query);
    final matchesFilter = _activeFilter == 'all' || bid.status == _activeFilter;
    return matchesSearch && matchesFilter;
  }).toList();
  emit(ApplicationsLoaded(
    allBids: _allBids,
    filteredBids: filtered,
    activeFilter: _activeFilter,
  ));
}

List<BidModel> _applyFilter(List<BidModel> bids, String filter) {
  if (filter == 'all') return bids;
  return bids.where((b) => b.status == filter).toList();
}
}
