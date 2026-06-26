// lib/viewmodel/States/freelancerProfileState.dart
import 'package:equatable/equatable.dart';
import 'package:super_project/model/freelancerModel.dart';

abstract class FreelancerProfileState extends Equatable {
  const FreelancerProfileState();

  @override
  List<Object?> get props => [];
}

class FreelancerProfileInitial extends FreelancerProfileState {}

class FreelancerProfileLoading extends FreelancerProfileState {}

class FreelancerProfileImageUploading extends FreelancerProfileState {
  final FreelancerModel current;
  const FreelancerProfileImageUploading(this.current);

  @override
  List<Object?> get props => [current];
}

class FreelancerProfileLoaded extends FreelancerProfileState {
  final FreelancerModel freelancer;
  const FreelancerProfileLoaded(this.freelancer);

  @override
  List<Object?> get props => [freelancer];
}

class FreelancerProfileSaveSuccess extends FreelancerProfileState {
  final FreelancerModel freelancer;
  const FreelancerProfileSaveSuccess(this.freelancer);

  @override
  List<Object?> get props => [freelancer];
}

class FreelancerProfileFailure extends FreelancerProfileState {
  final String message;
  const FreelancerProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}