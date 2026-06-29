// lib/viewmodel/Events/clientProfileEvent.dart
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:super_project/model/clientModel.dart';

abstract class ClientProfileEvent extends Equatable {
  const ClientProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadClientProfile extends ClientProfileEvent {
  final String uid;
  const LoadClientProfile(this.uid);
  @override
  List<Object?> get props => [uid];
}

class UpdateClientProfile extends ClientProfileEvent {
  final ClientModel model;
  const UpdateClientProfile(this.model);
  @override
  List<Object?> get props => [model];
}

class UploadClientProfileImage extends ClientProfileEvent {
  final String uid;
  final File imageFile;
  const UploadClientProfileImage({required this.uid, required this.imageFile});
  @override
  List<Object?> get props => [uid];
}