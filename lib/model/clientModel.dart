// lib/model/clientModel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ClientModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String companyName;
  final String industry;
  final String website;
  final String companySize;
  final String about;
  final List<String> skills;
  final String profileImageUrl;
  final DateTime? updatedAt;

  const ClientModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.companyName,
    required this.industry,
    required this.website,
    required this.companySize,
    required this.about,
    required this.skills,
    required this.profileImageUrl,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'location': location,
        'companyName': companyName,
        'industry': industry,
        'website': website,
        'companySize': companySize,
        'about': about,
        'skills': skills,
        'profileImageUrl': profileImageUrl,
        'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
      };

  factory ClientModel.fromMap(Map<String, dynamic> map) => ClientModel(
        uid: map['uid'] as String? ?? '',
        name: map['name'] as String? ?? '',
        email: map['email'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        location: map['location'] as String? ?? '',
        companyName: map['companyName'] as String? ?? '',
        industry: map['industry'] as String? ?? '',
        website: map['website'] as String? ?? '',
        companySize: map['companySize'] as String? ?? '',
        about: map['about'] as String? ?? '',
        skills: List<String>.from(map['skills'] ?? []),
        profileImageUrl: map['profileImageUrl'] as String? ?? '',
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] as Timestamp).toDate()
            : null,
      );

  ClientModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? companyName,
    String? industry,
    String? website,
    String? companySize,
    String? about,
    List<String>? skills,
    String? profileImageUrl,
  }) =>
      ClientModel(
        uid: uid,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        location: location ?? this.location,
        companyName: companyName ?? this.companyName,
        industry: industry ?? this.industry,
        website: website ?? this.website,
        companySize: companySize ?? this.companySize,
        about: about ?? this.about,
        skills: skills ?? this.skills,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        updatedAt: DateTime.now(),
      );

  @override
  List<Object?> get props => [uid, name, companyName, profileImageUrl];
}