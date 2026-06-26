// lib/View/FreelancerDashboard/FreelancerProfile.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_project/View/FreelancerDashboard/EditProfilePage.dart';
import 'package:super_project/model/freelancerModel.dart';
import 'package:super_project/viewmodel/Bloc/freelancerProfileBloc.dart';
import 'package:super_project/viewmodel/Events/freelancerProfileEvent.dart';
import 'package:super_project/viewmodel/States/freelancerProfileState.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<FreelancerProfileBloc>().add(LoadFreelancerProfile(uid));
    }
  }

  Future<void> _pickAndUploadImage() async {
    print(FirebaseAuth.instance.currentUser?.uid);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      context.read<FreelancerProfileBloc>().add(
        UploadProfileImage(uid: uid, imageFile: File(picked.path)),
      );
    } catch (e, s) {
      debugPrint("Image Error: $e");
      debugPrintStack(stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {
              final state = context.read<FreelancerProfileBloc>().state;
              if (state is FreelancerProfileLoaded) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => EditProfileScreen(freelancer: state.freelancer),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<FreelancerProfileBloc, FreelancerProfileState>(
        listener: (context, state) {
          if (state is FreelancerProfileFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is FreelancerProfileLoading ||
              state is FreelancerProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final freelancer =
              state is FreelancerProfileLoaded
                  ? state.freelancer
                  : state is FreelancerProfileImageUploading
                  ? state.current
                  : state is FreelancerProfileSaveSuccess
                  ? state.freelancer
                  : null;

          if (freelancer == null) {
            return const Center(child: Text('Profile not found'));
          }

          final isUploading = state is FreelancerProfileImageUploading;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Image
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                freelancer.profileImageUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                      freelancer.profileImageUrl,
                                    )
                                    : null,
                            child:
                                freelancer.profileImageUrl.isEmpty
                                    ? Text(
                                      freelancer.name.isNotEmpty
                                          ? freelancer.name[0].toUpperCase()
                                          : 'F',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6C5CE7),
                                      ),
                                    )
                                    : null,
                          ),
                          if (isUploading)
                            const Positioned.fill(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.black38,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: isUploading ? null : _pickAndUploadImage,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C5CE7),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        freelancer.name.isNotEmpty
                            ? freelancer.name
                            : 'Add your name',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        freelancer.title.isNotEmpty
                            ? freelancer.title
                            : 'Add your title',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            freelancer.location.isNotEmpty
                                ? freelancer.location
                                : 'Add location',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statItem('${freelancer.totalProjects}', 'Projects'),
                          _divider(),
                          _statItem(
                            '₹${(freelancer.totalEarnings / 1000).toStringAsFixed(0)}K',
                            'Earned',
                          ),
                          _divider(),
                          _statItem(
                            freelancer.rating > 0
                                ? freelancer.rating.toStringAsFixed(1)
                                : '—',
                            'Rating',
                          ),
                          _divider(),
                          _statItem('${freelancer.totalReviews}', 'Reviews'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // About
                _sectionCard(
                  title: 'About Me',
                  child: Text(
                    freelancer.about.isNotEmpty
                        ? freelancer.about
                        : 'No bio added yet.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Skills
                _sectionCard(
                  title: 'Skills',
                  child:
                      freelancer.skills.isEmpty
                          ? Text(
                            'No skills added yet.',
                            style: TextStyle(color: Colors.grey[500]),
                          )
                          : Column(
                            children:
                                freelancer.skills.map((skill) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              skill.name,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '${skill.percentage}%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: skill.percentage / 100,
                                            minHeight: 6,
                                            backgroundColor: Colors.grey[200],
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                  Color(0xFF6C5CE7),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                ),

                const SizedBox(height: 12),

                // Portfolio
                _sectionCard(
                  title: 'Portfolio',
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF6C5CE7),
                    ),
                    onPressed:
                        () => _showAddPortfolioDialog(context, freelancer),
                  ),
                  child:
                      freelancer.portfolio.isEmpty
                          ? Text(
                            'No portfolio items yet.',
                            style: TextStyle(color: Colors.grey[500]),
                          )
                          : Column(
                            children:
                                freelancer.portfolio.asMap().entries.map((
                                  entry,
                                ) {
                                  final i = entry.key;
                                  final item = entry.value;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[100],
                                      image:
                                          item.imageUrl.isNotEmpty
                                              ? DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                      item.imageUrl,
                                                    ),
                                                fit: BoxFit.cover,
                                                colorFilter: ColorFilter.mode(
                                                  Colors.black.withOpacity(0.3),
                                                  BlendMode.darken,
                                                ),
                                              )
                                              : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                item.title,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      item.imageUrl.isNotEmpty
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                              ),
                                              Text(
                                                item.description,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      item.imageUrl.isNotEmpty
                                                          ? Colors.white70
                                                          : Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              final uid =
                                                  FirebaseAuth
                                                      .instance
                                                      .currentUser
                                                      ?.uid;
                                              if (uid != null) {
                                                context
                                                    .read<
                                                      FreelancerProfileBloc
                                                    >()
                                                    .add(
                                                      RemovePortfolioItem(
                                                        uid: uid,
                                                        index: i,
                                                      ),
                                                    );
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                ),

                const SizedBox(height: 12),

                // Ratings
                _sectionCard(
                  title: 'Reviews & Ratings',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        freelancer.rating > 0
                            ? freelancer.rating.toStringAsFixed(1)
                            : '—',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Based on ${freelancer.totalReviews} Reviews',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      _buildRatingBar(5, 0.8),
                      _buildRatingBar(4, 0.6),
                      _buildRatingBar(3, 0.3),
                      _buildRatingBar(2, 0.1),
                      _buildRatingBar(1, 0.05),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddPortfolioDialog(
    BuildContext context,
    FreelancerModel freelancer,
  ) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    File? pickedFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setModalState) => Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Portfolio Item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Project Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            setModalState(() => pickedFile = File(picked.path));
                          }
                        },
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child:
                              pickedFile != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      pickedFile!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  )
                                  : const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 32,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Tap to add image',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null ||
                                titleCtrl.text.isEmpty ||
                                pickedFile == null)
                              return;
                            Navigator.pop(ctx);
                            context.read<FreelancerProfileBloc>().add(
                              UploadPortfolioImage(
                                uid: uid,
                                imageFile: pickedFile!,
                                title: titleCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Upload',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _divider() => Container(height: 30, width: 1, color: Colors.grey[200]);

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$stars', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
