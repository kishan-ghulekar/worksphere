// lib/viewmodel/States/bidState.dart
import 'package:equatable/equatable.dart';
import 'package:super_project/model/bidModel.dart';

abstract class BidState extends Equatable {
  const BidState();

  @override
  List<Object?> get props => [];
}

class BidInitial extends BidState {}

class BidLoading extends BidState {}

class BidSubmitSuccess extends BidState {}

class BidAcceptSuccess extends BidState {}

class BidFailure extends BidState {
  final String message;
  const BidFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class BidsForProjectLoaded extends BidState {
  final List<BidModel> bids;
  const BidsForProjectLoaded(this.bids);

  @override
  List<Object?> get props => [bids];
}

class MyBidsLoaded extends BidState {
  final List<BidModel> bids;
  const MyBidsLoaded(this.bids);

  @override
  List<Object?> get props => [bids];
}