// lib/viewmodel/Bloc/freelancerProfileBloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/model/freelancerModel.dart';
import 'package:super_project/repository/freelancerRepository.dart';
import 'package:super_project/viewmodel/Events/freelancerProfileEvent.dart';
import 'package:super_project/viewmodel/States/freelancerProfileState.dart';

class FreelancerProfileBloc
    extends Bloc<FreelancerProfileEvent, FreelancerProfileState> {
  final FreelancerRepository repository;

  FreelancerProfileBloc(this.repository) : super(FreelancerProfileInitial()) {
    on<LoadFreelancerProfile>(_onLoad);
    on<UpdateFreelancerProfile>(_onUpdate);
    on<UploadProfileImage>(_onUploadProfileImage);
    on<UploadPortfolioImage>(_onUploadPortfolioImage);
    on<RemovePortfolioItem>(_onRemovePortfolioItem);
  }

  Future<void> _onLoad(
    LoadFreelancerProfile event,
    Emitter<FreelancerProfileState> emit,
  ) async {
    emit(FreelancerProfileLoading());
    await emit.forEach<FreelancerModel?>(
      repository.streamProfile(event.uid),
      onData: (profile) {
        if (profile == null) {
          // First time — return empty profile
          return FreelancerProfileLoaded(FreelancerModel(
            uid: event.uid,
            name: '',
            title: '',
            location: '',
            about: '',
            profileImageUrl: '',
            responseTime: '2',
            skills: [],
            portfolio: [],
            rating: 0,
            totalReviews: 0,
            totalProjects: 0,
            totalEarnings: 0,
          ));
        }
        return FreelancerProfileLoaded(profile);
      },
      onError: (error, _) =>
          FreelancerProfileFailure("Failed to load profile: $error"),
    );
  }

  Future<void> _onUpdate(
    UpdateFreelancerProfile event,
    Emitter<FreelancerProfileState> emit,
  ) async {
    try {
      await repository.saveProfile(event.model);
      emit(FreelancerProfileSaveSuccess(event.model));
    } catch (e) {
      emit(FreelancerProfileFailure("Failed to save profile: $e"));
    }
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImage event,
    Emitter<FreelancerProfileState> emit,
  ) async {
    final current = state is FreelancerProfileLoaded
        ? (state as FreelancerProfileLoaded).freelancer
        : null;
    if (current == null) return;

    emit(FreelancerProfileImageUploading(current));
    try {
      final url =
          await repository.uploadProfileImage(event.uid, event.imageFile);
      final updated = current.copyWith(profileImageUrl: url);
      await repository.saveProfile(updated);
      emit(FreelancerProfileLoaded(updated));
    } catch (e) {
      emit(FreelancerProfileFailure("Failed to upload image: $e"));
    }
  }

  Future<void> _onUploadPortfolioImage(
    UploadPortfolioImage event,
    Emitter<FreelancerProfileState> emit,
  ) async {
    final current = state is FreelancerProfileLoaded
        ? (state as FreelancerProfileLoaded).freelancer
        : null;
    if (current == null) return;

    emit(FreelancerProfileImageUploading(current));
    try {
      final url =
          await repository.uploadPortfolioImage(event.uid, event.imageFile);
      final newItem = PortfolioItem(
        title: event.title,
        description: event.description,
        imageUrl: url,
      );
      final updatedPortfolio = [...current.portfolio, newItem];
      final updated = current.copyWith(portfolio: updatedPortfolio);
      await repository.saveProfile(updated);
      emit(FreelancerProfileLoaded(updated));
    } catch (e) {
      emit(FreelancerProfileFailure("Failed to upload portfolio: $e"));
    }
  }

  Future<void> _onRemovePortfolioItem(
    RemovePortfolioItem event,
    Emitter<FreelancerProfileState> emit,
  ) async {
    final current = state is FreelancerProfileLoaded
        ? (state as FreelancerProfileLoaded).freelancer
        : null;
    if (current == null) return;

    final updatedPortfolio = [...current.portfolio]..removeAt(event.index);
    final updated = current.copyWith(portfolio: updatedPortfolio);
    await repository.saveProfile(updated);
    emit(FreelancerProfileLoaded(updated));
  }
}