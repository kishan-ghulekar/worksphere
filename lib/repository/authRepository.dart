import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:super_project/model/userModel.dart';

/// Wraps all Firebase Auth + Firestore calls related to user accounts.
/// The Bloc layer talks to this class — it never calls FirebaseAuth or
/// FirebaseFirestore directly.
class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a Firebase Auth account, then writes the profile to Firestore.
  /// Throws FirebaseAuthException on auth failure (caught by the Bloc).
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      role: role.trim().toLowerCase(),
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(user.toMap());

    return user;
  }

  /// Signs in with email/password, then fetches the matching profile
  /// from Firestore. Throws if the profile document doesn't exist.
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = credential.user!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception(
        "No profile found for this account. Please sign up again or contact support.",
      );
    }

    return UserModel.fromMap(doc.data()!);
  }

  /// Signs the current user out.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Returns the currently signed-in user's profile, or null if
  /// nobody is signed in. Useful for splash-screen auto-login checks.
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromMap(doc.data()!);
  }
}