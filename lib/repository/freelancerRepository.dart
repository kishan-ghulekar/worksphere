// lib/repository/freelancerRepository.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:super_project/model/freelancerModel.dart';

class FreelancerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _docRef(String uid) =>
      _firestore.collection('freelancers').doc(uid);

  // Stream profile — real-time updates
  Stream<FreelancerModel?> streamProfile(String uid) {
    return _docRef(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FreelancerModel.fromMap(doc.data()!);
    });
  }

  // Create or update profile
  Future<void> saveProfile(FreelancerModel model) async {
    await _docRef(model.uid).set(model.toMap(), SetOptions(merge: true));
  }

  // Upload profile image → returns download URL
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('profile_images/$uid.jpg');
    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  // Upload portfolio image → returns download URL
  Future<String> uploadPortfolioImage(String uid, File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('portfolio_images/$uid/$fileName');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }
}