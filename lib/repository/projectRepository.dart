import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_project/model/projectModel.dart';

class ProjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _projectsRef =>
      _firestore.collection('projects');

  /// Creates a new project document. The document ID is used as projectId
  /// so it's always consistent with Firestore's own identifier.
  Future<void> createProject({
    required String clientId,
    required String title,
    required String description,
    required String category,
    required double budget,
    required String duration,
  }) async {
    final docRef = _projectsRef.doc();

    final project = ProjectModel(
      projectId: docRef.id,
      clientId: clientId,
      title: title,
      description: description,
      category: category,
      budget: budget,
      duration: duration,
      status: "Open",
      createdAt: DateTime.now(),
    );

    await docRef.set(project.toMap());
  }

  /// Streams this client's own projects, newest first.
  /// Used by ClientDashboardPage to replace the hardcoded card list.
  Stream<List<ProjectModel>> streamProjects(String clientId) {
    return _projectsRef
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<ProjectModel>> streamAllProjects() {
  return _projectsRef
      .where('status', isEqualTo: 'Open')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ProjectModel.fromMap(doc.data()))
          .toList());
}
}