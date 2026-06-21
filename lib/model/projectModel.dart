import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ProjectModel extends Equatable {
  final String projectId;
  final String clientId;
  final String title;
  final String description;
  final String category;
  final double budget;
  final String duration;
  final String status;
  final DateTime createdAt;

  const ProjectModel({
    required this.projectId,
    required this.clientId,
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.duration,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "projectId": projectId,
      "clientId": clientId,
      "title": title,
      "description": description,
      "category": category,
      "budget": budget,
      "duration": duration,
      "status": status,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      projectId: map['projectId'] as String? ?? '',
      clientId: map['clientId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      duration: map['duration'] as String? ?? '',
      status: map['status'] as String? ?? 'Open',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        projectId,
        clientId,
        title,
        description,
        category,
        budget,
        duration,
        status,
        createdAt,
      ];
}