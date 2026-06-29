// lib/viewmodel/Bloc/clientProfileBloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:super_project/model/clientModel.dart';
import 'package:super_project/repository/clientRepository.dart';
import 'package:super_project/viewmodel/Events/clientEvents.dart';
import 'package:super_project/viewmodel/States/clientStates.dart';


class ClientProfileBloc
    extends Bloc<ClientProfileEvent, ClientProfileState> {
  final ClientRepository repository;

  ClientProfileBloc(this.repository) : super(ClientProfileInitial()) {
    on<LoadClientProfile>(_onLoad);
    on<UpdateClientProfile>(_onUpdate);
    on<UploadClientProfileImage>(_onUploadImage);
  }

  Future<void> _onLoad(
    LoadClientProfile event,
    Emitter<ClientProfileState> emit,
  ) async {
    emit(ClientProfileLoading());
    await emit.forEach<ClientModel?>(
      repository.streamProfile(event.uid),
      onData: (client) {
        if (client == null) {
          final user = FirebaseAuth.instance.currentUser;
          return ClientProfileLoaded(ClientModel(
            uid: event.uid,
            name: user?.displayName ?? '',
            email: user?.email ?? '',
            phone: '',
            location: '',
            companyName: '',
            industry: '',
            website: '',
            companySize: '',
            about: '',
            skills: [],
            profileImageUrl: '',
          ));
        }
        return ClientProfileLoaded(client);
      },
      onError: (error, _) =>
          ClientProfileFailure("Failed to load profile: $error"),
    );
  }

  Future<void> _onUpdate(
    UpdateClientProfile event,
    Emitter<ClientProfileState> emit,
  ) async {
    try {
      await repository.saveProfile(event.model);
      emit(ClientProfileSaveSuccess(event.model));
    } catch (e) {
      emit(ClientProfileFailure("Failed to save: $e"));
    }
  }

  Future<void> _onUploadImage(
    UploadClientProfileImage event,
    Emitter<ClientProfileState> emit,
  ) async {
    final current = state is ClientProfileLoaded
        ? (state as ClientProfileLoaded).client
        : null;
    if (current == null) return;

    emit(ClientProfileImageUploading(current));
    try {
      final url = await repository.uploadProfileImage(
          event.uid, event.imageFile);
      final updated = current.copyWith(profileImageUrl: url);
      await repository.saveProfile(updated);
      emit(ClientProfileLoaded(updated));
    } catch (e) {
      emit(ClientProfileFailure("Failed to upload image: $e"));
    }
  }
}