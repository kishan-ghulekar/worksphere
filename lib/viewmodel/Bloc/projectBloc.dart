import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/model/projectModel.dart';
import 'package:super_project/repository/projectRepository.dart';
import 'package:super_project/viewmodel/Events/projectEvent.dart';
import 'package:super_project/viewmodel/States/authState.dart';
import 'package:super_project/viewmodel/States/projectState.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository projectRepository;
  String? _currentClientId;
  StreamSubscription<List<ProjectModel>>? _projectsSubscription;

  ProjectBloc(this.projectRepository) : super(ProjectInitial()) {
    on<CreateProjectRequested>(_onCreateProjectRequested);
    on<LoadProjectsRequested>(_onLoadProjectsRequested);
    on<LoadAllProjectsRequested>(_onLoadAllProjectsRequested);
  }

  Future<void> _onLoadProjectsRequested(
    LoadProjectsRequested event,
    Emitter<ProjectState> emit,
  ) async {
    _currentClientId = event.clientId;
    emit(ProjectLoading());

    // Cancel any existing subscription before starting a new one
    await _projectsSubscription?.cancel();

    await emit.forEach<List<ProjectModel>>(
      projectRepository.streamProjects(event.clientId),
      onData: (projects) => ProjectLoadSuccess(projects),
      onError:
          (error, stackTrace) =>
              ProjectFailure("Failed to load projects: $error"),
    );
  }

  Future<void> _onCreateProjectRequested(
    CreateProjectRequested event,
    Emitter<ProjectState> emit,
  ) async {
    // ❌ Don't emit ProjectLoading here — it kills the stream
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

      // ✅ Restart the stream after successful creation
      if (_currentClientId != null) {
        await emit.forEach<List<ProjectModel>>(
          projectRepository.streamProjects(_currentClientId!),
          onData: (projects) => ProjectLoadSuccess(projects),
          onError:
              (error, stackTrace) =>
                  ProjectFailure("Failed to load projects: $error"),
        );
      }
    } catch (e) {
      emit(ProjectFailure("Failed to post project: $e"));
    }
  }

  Future<void> _onLoadAllProjectsRequested(
    LoadAllProjectsRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    await emit.forEach<List<ProjectModel>>(
      projectRepository.streamAllProjects(),
      onData: (projects) => AllProjectsLoadSuccess(projects),
      onError:
          (error, stackTrace) =>
              ProjectFailure("Failed to load projects: $error"),
    );
  }

  @override
  Future<void> close() {
    _projectsSubscription?.cancel();
    return super.close();
  }
}
