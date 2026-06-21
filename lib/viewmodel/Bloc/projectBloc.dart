import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/model/projectModel.dart';
import 'package:super_project/repository/projectRepository.dart';
import 'package:super_project/viewmodel/Events/projectEvent.dart';
import 'package:super_project/viewmodel/States/projectState.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository projectRepository;

  ProjectBloc(this.projectRepository) : super(ProjectInitial()) {
    on<CreateProjectRequested>(_onCreateProjectRequested);
    on<LoadProjectsRequested>(_onLoadProjectsRequested);
  }

  Future<void> _onCreateProjectRequested(
    CreateProjectRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      await projectRepository.createProject(
        clientId: event.clientId,
        title: event.title,
        description: event.description,
        category: event.category,
        budget: event.budget,
        duration: event.duration,
      );
      emit(ProjectCreateSuccess());
    } catch (e) {
      emit(ProjectFailure("Failed to post project: $e"));
    }
  }

  /// Bridges the Firestore stream into Bloc states. emit.forEach keeps
  /// listening for the lifetime of this handler — every new snapshot
  /// from Firestore produces a fresh ProjectLoadSuccess state, which is
  /// what gives the dashboard its auto-refresh / real-time behavior.
  Future<void> _onLoadProjectsRequested(
    LoadProjectsRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    await emit.forEach<List<ProjectModel>>(
      projectRepository.streamProjects(event.clientId),
      onData: (projects) => ProjectLoadSuccess(projects),
      onError: (error, stackTrace) =>
          ProjectFailure("Failed to load projects: $error"),
    );
  }
}