import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String profileImage;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime? createdAt;

  // Extra fields for freelancer profile
  final String? bio;
  final List<String> skills;
  final double rating;
  final int reviewCount;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage = '',
    this.isOnline = false,
    this.lastSeen,
    this.createdAt,
    this.bio,
    this.skills = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'profileImage': profileImage,
        'isOnline': isOnline,
        'lastSeen':
            lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
        'createdAt':
            createdAt != null ? Timestamp.fromDate(createdAt!) : null,
        'bio': bio,
        'skills': skills,
        'rating': rating,
        'reviewCount': reviewCount,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: (map['uid'] ?? '') as String,
        name: (map['name'] ?? '') as String,
        email: (map['email'] ?? '') as String,
        role: ((map['role'] ?? '') as String).trim().toLowerCase(),
        profileImage: (map['profileImage'] ?? 
                       map['profileImageUrl'] ?? '') as String,
        isOnline: (map['isOnline'] ?? false) as bool,
        lastSeen: map['lastSeen'] != null
            ? (map['lastSeen'] as Timestamp).toDate()
            : null,
        createdAt: map['createdAt'] != null
            ? (map['createdAt'] as Timestamp).toDate()
            : null,
        bio: map['bio'] as String?,
        skills: (map['skills'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      );

  bool get isFreelancer => role == 'freelancer';
  bool get isClient => role == 'client';

  UserModel copyWith({
    String? name,
    String? profileImage,
    String? bio,
    List<String>? skills,
    double? rating,
    int? reviewCount,
    bool? isOnline,
    DateTime? lastSeen,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email,
        role: role,
        profileImage: profileImage ?? this.profileImage,
        isOnline: isOnline ?? this.isOnline,
        lastSeen: lastSeen ?? this.lastSeen,
        createdAt: createdAt,
        bio: bio ?? this.bio,
        skills: skills ?? this.skills,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
      );

  @override
  List<Object?> get props =>
      [uid, name, email, role, profileImage, isOnline, rating];
}