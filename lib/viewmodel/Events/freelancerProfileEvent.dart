// lib/viewmodel/Events/freelancerProfileEvent.dart
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:super_project/model/freelancerModel.dart';

abstract class FreelancerProfileEvent extends Equatable {
  const FreelancerProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadFreelancerProfile extends FreelancerProfileEvent {
  final String uid;
  const LoadFreelancerProfile(this.uid);

  @override
  List<Object?> get props => [uid];
}

class UpdateFreelancerProfile extends FreelancerProfileEvent {
  final FreelancerModel model;
  const UpdateFreelancerProfile(this.model);

  @override
  List<Object?> get props => [model];
}

class UploadProfileImage extends FreelancerProfileEvent {
  final String uid;
  final File imageFile;
  const UploadProfileImage({required this.uid, required this.imageFile});

  @override
  List<Object?> get props => [uid];
}

class UploadPortfolioImage extends FreelancerProfileEvent {
  final String uid;
  final File imageFile;
  final String title;
  final String description;
  const UploadPortfolioImage({
    required this.uid,
    required this.imageFile,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [uid, title];
}

class RemovePortfolioItem extends FreelancerProfileEvent {
  final String uid;
  final int index;
  const RemovePortfolioItem({required this.uid, required this.index});

  @override
  List<Object?> get props => [uid, index];
}