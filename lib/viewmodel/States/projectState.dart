import 'package:equatable/equatable.dart';
import 'package:super_project/model/projectModel.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

/// Shown while creating a project (Post Project button spinner).
class ProjectLoading extends ProjectState {}

class ProjectCreateSuccess extends ProjectState {}

class ProjectFailure extends ProjectState {
  final String message;
  const ProjectFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Carries the live list of this client's projects — emitted every time
/// the Firestore stream updates, so the dashboard auto-refreshes.
class ProjectLoadSuccess extends ProjectState {
  final List<ProjectModel> projects;
  const ProjectLoadSuccess(this.projects);

  @override
  List<Object?> get props => [projects];
}

class ProjectDeleteSuccess extends ProjectState {}

class ProjectUpdateSuccess extends ProjectState {}
