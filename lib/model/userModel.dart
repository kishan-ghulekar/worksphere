import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a user document stored at users/{uid} in Firestore.
/// Used for both roles — 'role' field distinguishes client vs freelancer.
class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String role; // 'client' or 'freelancer'
  final String? profileImageUrl;
  final String? bio;
  final List<String> skills; // freelancer only, empty for clients
  final double rating; // average rating, 0 if no reviews yet
  final int reviewCount;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.profileImageUrl,
    this.bio,
    this.skills = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  /// Convert this model into a Map for writing to Firestore.
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "role": role,
      "profileImageUrl": profileImageUrl,
      "bio": bio,
      "skills": skills,
      "rating": rating,
      "reviewCount": reviewCount,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  /// Build a UserModel from a Firestore document snapshot.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: (map['role'] as String? ?? '').trim().toLowerCase(),
      profileImageUrl: map['profileImageUrl'] as String?,
      bio: map['bio'] as String?,
      skills: map['skills'] != null
          ? List<String>.from(map['skills'] as List)
          : const [],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convenience getters used throughout the UI
  bool get isFreelancer => role == 'freelancer';
  bool get isClient => role == 'client';

  /// Creates a copy of this user with some fields replaced.
  /// Useful when updating profile info without rebuilding the whole object.
  UserModel copyWith({
    String? name,
    String? profileImageUrl,
    String? bio,
    List<String>? skills,
    double? rating,
    int? reviewCount,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        role,
        profileImageUrl,
        bio,
        skills,
        rating,
        reviewCount,
        createdAt,
      ];
}