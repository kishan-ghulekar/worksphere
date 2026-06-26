// lib/model/freelancerModel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SkillModel {
  final String name;
  final int percentage;

  const SkillModel({required this.name, required this.percentage});

  Map<String, dynamic> toMap() => {'name': name, 'percentage': percentage};

  factory SkillModel.fromMap(Map<String, dynamic> map) => SkillModel(
        name: map['name'] as String? ?? '',
        percentage: (map['percentage'] as num?)?.toInt() ?? 0,
      );
}

class PortfolioItem {
  final String title;
  final String description;
  final String imageUrl;

  const PortfolioItem({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
      };

  factory PortfolioItem.fromMap(Map<String, dynamic> map) => PortfolioItem(
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
      );
}

class FreelancerModel extends Equatable {
  final String uid;
  final String name;
  final String title;
  final String location;
  final String about;
  final String profileImageUrl;
  final String responseTime;
  final List<SkillModel> skills;
  final List<PortfolioItem> portfolio;
  final double rating;
  final int totalReviews;
  final int totalProjects;
  final double totalEarnings;
  final DateTime? updatedAt;

  const FreelancerModel({
    required this.uid,
    required this.name,
    required this.title,
    required this.location,
    required this.about,
    required this.profileImageUrl,
    required this.responseTime,
    required this.skills,
    required this.portfolio,
    required this.rating,
    required this.totalReviews,
    required this.totalProjects,
    required this.totalEarnings,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'title': title,
        'location': location,
        'about': about,
        'profileImageUrl': profileImageUrl,
        'responseTime': responseTime,
        'skills': skills.map((s) => s.toMap()).toList(),
        'portfolio': portfolio.map((p) => p.toMap()).toList(),
        'rating': rating,
        'totalReviews': totalReviews,
        'totalProjects': totalProjects,
        'totalEarnings': totalEarnings,
        'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
      };

  factory FreelancerModel.fromMap(Map<String, dynamic> map) => FreelancerModel(
        uid: map['uid'] as String? ?? '',
        name: map['name'] as String? ?? '',
        title: map['title'] as String? ?? '',
        location: map['location'] as String? ?? '',
        about: map['about'] as String? ?? '',
        profileImageUrl: map['profileImageUrl'] as String? ?? '',
        responseTime: map['responseTime'] as String? ?? '2',
        skills: (map['skills'] as List<dynamic>? ?? [])
            .map((s) => SkillModel.fromMap(s as Map<String, dynamic>))
            .toList(),
        portfolio: (map['portfolio'] as List<dynamic>? ?? [])
            .map((p) => PortfolioItem.fromMap(p as Map<String, dynamic>))
            .toList(),
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: (map['totalReviews'] as num?)?.toInt() ?? 0,
        totalProjects: (map['totalProjects'] as num?)?.toInt() ?? 0,
        totalEarnings: (map['totalEarnings'] as num?)?.toDouble() ?? 0.0,
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] as Timestamp).toDate()
            : null,
      );

  FreelancerModel copyWith({
    String? name,
    String? title,
    String? location,
    String? about,
    String? profileImageUrl,
    String? responseTime,
    List<SkillModel>? skills,
    List<PortfolioItem>? portfolio,
    double? rating,
    int? totalReviews,
    int? totalProjects,
    double? totalEarnings,
  }) =>
      FreelancerModel(
        uid: uid,
        name: name ?? this.name,
        title: title ?? this.title,
        location: location ?? this.location,
        about: about ?? this.about,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        responseTime: responseTime ?? this.responseTime,
        skills: skills ?? this.skills,
        portfolio: portfolio ?? this.portfolio,
        rating: rating ?? this.rating,
        totalReviews: totalReviews ?? this.totalReviews,
        totalProjects: totalProjects ?? this.totalProjects,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        updatedAt: DateTime.now(),
      );

  @override
  List<Object?> get props => [uid, name, profileImageUrl, rating];
}