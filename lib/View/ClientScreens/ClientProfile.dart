// lib/View/ClientScreens/ClientProfile.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_project/model/clientModel.dart';
import 'package:super_project/viewmodel/Bloc/clientbloc.dart';
import 'package:super_project/viewmodel/Events/clientEvents.dart';
import 'package:super_project/viewmodel/States/clientStates.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<ClientProfileBloc>().add(LoadClientProfile(uid));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (mounted) {
      context.read<ClientProfileBloc>().add(
        UploadClientProfileImage(uid: uid, imageFile: File(picked.path)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<ClientProfileBloc, ClientProfileState>(
        listener: (context, state) {
          if (state is ClientProfileSaveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Color(0xFF00BFA5),
              ),
            );
          }
          if (state is ClientProfileFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ClientProfileLoading || state is ClientProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final client =
              state is ClientProfileLoaded
                  ? state.client
                  : state is ClientProfileImageUploading
                  ? state.current
                  : state is ClientProfileSaveSuccess
                  ? state.client
                  : null;

          if (client == null) {
            return const Center(child: Text('Profile not found'));
          }

          final isUploading = state is ClientProfileImageUploading;

          return CustomScrollView(
            slivers: [
              // SliverAppBar with profile header
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: const Color(0xFF5B67F1),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () => _showEditBottomSheet(context, client),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5B67F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              backgroundImage:
                                  client.profileImageUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                        client.profileImageUrl,
                                      )
                                      : null,
                              child:
                                  client.profileImageUrl.isEmpty
                                      ? Text(
                                        client.name.isNotEmpty
                                            ? client.name[0].toUpperCase()
                                            : 'C',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                      : null,
                            ),
                            if (isUploading)
                              const Positioned.fill(
                                child: CircleAvatar(
                                  radius: 46,
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
                                onTap: isUploading ? null : _pickImage,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF5B67F1),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Color(0xFF5B67F1),
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          client.name.isNotEmpty
                              ? client.name
                              : 'Add your name',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (client.companyName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            client.companyName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed:
                              () => _showEditBottomSheet(context, client),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information
                      _sectionCard(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        child: Column(
                          children: [
                            _infoRow(
                              Icons.person_outline,
                              'Name',
                              client.name,
                              'Add name',
                            ),
                            _divider(),
                            _infoRow(
                              Icons.email_outlined,
                              'Email',
                              client.email,
                              'Add email',
                            ),
                            _divider(),
                            _infoRow(
                              Icons.phone_outlined,
                              'Phone',
                              client.phone,
                              'Add phone',
                            ),
                            _divider(),
                            _infoRow(
                              Icons.location_on_outlined,
                              'Location',
                              client.location,
                              'Add location',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Company Information
                      _sectionCard(
                        title: 'Company Information',
                        icon: Icons.business_outlined,
                        child: Column(
                          children: [
                            _infoRow(
                              Icons.business_outlined,
                              'Company',
                              client.companyName,
                              'Add company',
                            ),
                            _divider(),
                            _infoRow(
                              Icons.category_outlined,
                              'Industry',
                              client.industry,
                              'Add industry',
                            ),
                            _divider(),
                            _infoRow(
                              Icons.language_outlined,
                              'Website',
                              client.website,
                              'Add website',
                            ),
                            _divider(),
                            _infoRow(
                              Icons.people_outline,
                              'Company Size',
                              client.companySize,
                              'Add size',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // About
                      _sectionCard(
                        title: 'About',
                        icon: Icons.info_outline,
                        child: Text(
                          client.about.isNotEmpty
                              ? client.about
                              : 'No description added yet. Tap Edit Profile to add one.',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                client.about.isNotEmpty
                                    ? Colors.grey[700]
                                    : Colors.grey[400],
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Skills
                      _sectionCard(
                        title: 'Skills / Tech Stack',
                        icon: Icons.code_outlined,
                        child:
                            client.skills.isEmpty
                                ? Text(
                                  'No skills added yet.',
                                  style: TextStyle(color: Colors.grey[400]),
                                )
                                : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      client.skills.map((skill) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF5B67F1,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFF5B67F1,
                                              ).withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            skill,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF5B67F1),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                      ),

                      const SizedBox(height: 16),

                      // Account Settings
                      _sectionCard(
                        title: 'Account',
                        icon: Icons.settings_outlined,
                        child: Column(
                          children: [
                            _menuRow(
                              Icons.edit_outlined,
                              'Edit Profile',
                              const Color(0xFF5B67F1),
                              () {
                                _showEditBottomSheet(context, client);
                              },
                            ),
                            _divider(),
                            _menuRow(
                              Icons.lock_outline,
                              'Change Password',
                              Colors.orange,
                              () {},
                            ),
                            _divider(),
                            _menuRow(
                              Icons.notifications_outlined,
                              'Notifications',
                              Colors.green,
                              () {},
                            ),
                            _divider(),
                            _menuRow(
                              Icons.privacy_tip_outlined,
                              'Privacy',
                              Colors.purple,
                              () {},
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Support
                      _sectionCard(
                        title: 'Support',
                        icon: Icons.support_agent_outlined,
                        child: Column(
                          children: [
                            _menuRow(
                              Icons.help_outline,
                              'Help Center',
                              Colors.blue,
                              () {},
                            ),
                            _divider(),
                            _menuRow(
                              Icons.contact_support_outlined,
                              'Contact Support',
                              Colors.teal,
                              () {},
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Logout
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text('Logout'),
                                  content: const Text(
                                    'Are you sure you want to logout?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text(
                                        'Logout',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            await FirebaseAuth.instance.signOut();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.logout, color: Colors.red, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context, ClientModel client) {
    final nameCtrl = TextEditingController(text: client.name);
    final emailCtrl = TextEditingController(text: client.email);
    final phoneCtrl = TextEditingController(text: client.phone);
    final locationCtrl = TextEditingController(text: client.location);
    final companyCtrl = TextEditingController(text: client.companyName);
    final industryCtrl = TextEditingController(text: client.industry);
    final websiteCtrl = TextEditingController(text: client.website);
    final companySizeCtrl = TextEditingController(text: client.companySize);
    final aboutCtrl = TextEditingController(text: client.about);
    final skillCtrl = TextEditingController();
    List<String> skills = List.from(client.skills);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.92,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            16,
                            20,
                            MediaQuery.of(ctx).viewInsets.bottom + 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sheetSection('Personal Information'),
                              _sheetField(
                                'Full Name',
                                nameCtrl,
                                Icons.person_outline,
                              ),
                              const SizedBox(height: 12),
                              _sheetField(
                                'Email',
                                emailCtrl,
                                Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),
                              _sheetField(
                                'Phone',
                                phoneCtrl,
                                Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),
                              _sheetField(
                                'Location',
                                locationCtrl,
                                Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 20),

                              _sheetSection('Company Information'),
                              _sheetField(
                                'Company Name',
                                companyCtrl,
                                Icons.business_outlined,
                              ),
                              const SizedBox(height: 12),
                              _sheetField(
                                'Industry',
                                industryCtrl,
                                Icons.category_outlined,
                              ),
                              const SizedBox(height: 12),
                              _sheetField(
                                'Website',
                                websiteCtrl,
                                Icons.language_outlined,
                                keyboardType: TextInputType.url,
                              ),
                              const SizedBox(height: 12),
                              _sheetField(
                                'Company Size',
                                companySizeCtrl,
                                Icons.people_outline,
                                hint: 'e.g. 1-10, 11-50, 51-200',
                              ),
                              const SizedBox(height: 20),

                              _sheetSection('About'),
                              TextField(
                                controller: aboutCtrl,
                                maxLines: 4,
                                decoration: _inputDec(
                                  'Describe your company...',
                                  null,
                                ),
                              ),
                              const SizedBox(height: 20),

                              _sheetSection('Skills / Tech Stack'),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: skillCtrl,
                                      decoration: _inputDec(
                                        'Add a skill',
                                        null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (skillCtrl.text.trim().isNotEmpty) {
                                        setModalState(() {
                                          skills.add(skillCtrl.text.trim());
                                          skillCtrl.clear();
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5B67F1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 16,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    skills.map((skill) {
                                      return Chip(
                                        label: Text(
                                          skill,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        deleteIcon: const Icon(
                                          Icons.close,
                                          size: 14,
                                        ),
                                        onDeleted:
                                            () => setModalState(
                                              () => skills.remove(skill),
                                            ),
                                        backgroundColor: const Color(
                                          0xFF5B67F1,
                                        ).withOpacity(0.1),
                                        side: BorderSide(
                                          color: const Color(
                                            0xFF5B67F1,
                                          ).withOpacity(0.3),
                                        ),
                                        labelStyle: const TextStyle(
                                          color: Color(0xFF5B67F1),
                                        ),
                                      );
                                    }).toList(),
                              ),

                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    final updated = client.copyWith(
                                      name: nameCtrl.text.trim(),
                                      email: emailCtrl.text.trim(),
                                      phone: phoneCtrl.text.trim(),
                                      location: locationCtrl.text.trim(),
                                      companyName: companyCtrl.text.trim(),
                                      industry: industryCtrl.text.trim(),
                                      website: websiteCtrl.text.trim(),
                                      companySize: companySizeCtrl.text.trim(),
                                      about: aboutCtrl.text.trim(),
                                      skills: skills,
                                    );
                                    context.read<ClientProfileBloc>().add(
                                      UpdateClientProfile(updated),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5B67F1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _sheetSection(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );

  Widget _sheetField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) => TextField(
    controller: ctrl,
    keyboardType: keyboardType,
    decoration: _inputDec(hint ?? label, icon),
  );

  InputDecoration _inputDec(String hint, IconData? icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
    prefixIcon:
        icon != null ? Icon(icon, color: Colors.grey[400], size: 20) : null,
    filled: true,
    fillColor: Colors.grey[50],
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF5B67F1), width: 1.5),
    ),
  );

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF5B67F1)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );

  Widget _infoRow(IconData icon, String label, String value, String empty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : empty,
                  style: TextStyle(
                    fontSize: 14,
                    color: value.isNotEmpty ? Colors.black87 : Colors.grey[300],
                    fontWeight:
                        value.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey[100]);
}
