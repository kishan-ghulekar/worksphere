// lib/viewmodel/States/clientProfileState.dart
import 'package:equatable/equatable.dart';
import 'package:super_project/model/clientModel.dart';

abstract class ClientProfileState extends Equatable {
  const ClientProfileState();
  @override
  List<Object?> get props => [];
}

class ClientProfileInitial extends ClientProfileState {}
class ClientProfileLoading extends ClientProfileState {}
class ClientProfileImageUploading extends ClientProfileState {
  final ClientModel current;
  const ClientProfileImageUploading(this.current);
  @override
  List<Object?> get props => [current];
}

class ClientProfileLoaded extends ClientProfileState {
  final ClientModel client;
  const ClientProfileLoaded(this.client);
  @override
  List<Object?> get props => [client];
}

class ClientProfileSaveSuccess extends ClientProfileState {
  final ClientModel client;
  const ClientProfileSaveSuccess(this.client);
  @override
  List<Object?> get props => [client];
}

class ClientProfileFailure extends ClientProfileState {
  final String message;
  const ClientProfileFailure(this.message);
  @override
  List<Object?> get props => [message];
}