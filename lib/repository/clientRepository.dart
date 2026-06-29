// lib/repository/clientRepository.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:super_project/model/clientModel.dart';

class ClientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _docRef(String uid) =>
      _firestore.collection('clients').doc(uid);

  Stream<ClientModel?> streamProfile(String uid) {
    return _docRef(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ClientModel.fromMap(doc.data()!);
    });
  }

  Future<void> saveProfile(ClientModel model) async {
    await _docRef(model.uid).set(model.toMap(), SetOptions(merge: true));
  }

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('client_profile_images/$uid.jpg');
    final task = await ref.putFile(imageFile,
        SettableMetadata(contentType: 'image/jpeg'));
    return await task.ref.getDownloadURL();
  }
}