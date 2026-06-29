import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class CreateProjectRequested extends ProjectEvent {
  final String clientId;
  final String title;
  final String description;
  final String category;
  final double budget;
  final String duration;

  const CreateProjectRequested({
    required this.clientId,
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.duration,
  });

  @override
  List<Object?> get props => [
    clientId,
    title,
    description,
    category,
    budget,
    duration,
  ];
}

/// Starts (or restarts) listening to this client's projects stream.
class LoadProjectsRequested extends ProjectEvent {
  final String clientId;
  const LoadProjectsRequested(this.clientId);

  @override
  List<Object?> get props => [clientId];
}

/// Internal event fired each time the Firestore stream emits new data.
/// Not dispatched manually from the UI — the Bloc adds this to itself.
class ProjectsStreamUpdated extends ProjectEvent {
  final List<dynamic> projects;
  const ProjectsStreamUpdated(this.projects);

  @override
  List<Object?> get props => [projects];
}

// Add this to your existing events file
class LoadAllProjectsRequested extends ProjectEvent {
  const LoadAllProjectsRequested();

  @override
  List<Object?> get props => [];
}

class DeleteProjectRequest extends ProjectEvent {
  final String projectId;
  const DeleteProjectRequest(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class UpdateProjectRequested extends ProjectEvent {
  final String projectId;
  final String title;
  final String description;
  final String category;
  final double budget;
  final String duration;

  const UpdateProjectRequested({
    required this.projectId,
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.duration,
  });

  @override
  List<Object?> get props => [projectId, title, budget];
}
