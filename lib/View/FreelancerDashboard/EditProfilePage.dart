// lib/View/FreelancerDashboard/EditProfile.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/model/freelancerModel.dart';
import 'package:super_project/viewmodel/Bloc/freelancerProfileBloc.dart';
import 'package:super_project/viewmodel/Events/freelancerProfileEvent.dart';
import 'package:super_project/viewmodel/States/freelancerProfileState.dart';

class EditProfileScreen extends StatefulWidget {
  final FreelancerModel freelancer;
  const EditProfileScreen({super.key, required this.freelancer});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _aboutController;
  late final TextEditingController _responseTimeController;
  late List<SkillModel> _skills;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.freelancer.name);
    _titleController = TextEditingController(text: widget.freelancer.title);
    _locationController = TextEditingController(
      text: widget.freelancer.location,
    );
    _aboutController = TextEditingController(text: widget.freelancer.about);
    _responseTimeController = TextEditingController(
      text: widget.freelancer.responseTime,
    );
    _skills =
        widget.freelancer.skills
            .map((s) => SkillModel(name: s.name, percentage: s.percentage))
            .toList();
    if (_skills.isEmpty) {
      _skills = [const SkillModel(name: '', percentage: 0)];
    }
  }

  void _addSkill() {
    setState(() {
      _skills.add(const SkillModel(name: '', percentage: 0));
    });
  }

  void _removeSkill(int index) {
    setState(() => _skills.removeAt(index));
  }

  void _onSave() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final updated = widget.freelancer.copyWith(
      name: _nameController.text.trim(),
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      about: _aboutController.text.trim(),
      responseTime: _responseTimeController.text.trim(),
      skills: _skills.where((s) => s.name.isNotEmpty).toList(),
    );

    context.read<FreelancerProfileBloc>().add(UpdateFreelancerProfile(updated));
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
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<FreelancerProfileBloc, FreelancerProfileState>(
        listener: (context, state) {
          if (state is FreelancerProfileSaveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Color(0xFF00D4AA),
              ),
            );
            Navigator.pop(context);
          }
          if (state is FreelancerProfileFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is FreelancerProfileLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Basic Information'),
                const SizedBox(height: 12),
                _inputField('Full Name', _nameController, Icons.person_outline),
                const SizedBox(height: 14),
                _inputField(
                  'Title / Position',
                  _titleController,
                  Icons.work_outline,
                ),
                const SizedBox(height: 14),
                _inputField(
                  'Location',
                  _locationController,
                  Icons.location_on_outlined,
                ),
                const SizedBox(height: 14),
                _inputField(
                  'Response Time (hours)',
                  _responseTimeController,
                  Icons.access_time,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 28),

                _sectionTitle('About'),
                const SizedBox(height: 12),
                TextField(
                  controller: _aboutController,
                  maxLines: 5,
                  decoration: _inputDecoration('Tell us about yourself...'),
                ),
                const SizedBox(height: 28),

                // Skills
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle('Skills'),
                    TextButton.icon(
                      onPressed: _addSkill,
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: Color(0xFF6C5CE7),
                      ),
                      label: const Text(
                        'Add Skill',
                        style: TextStyle(
                          color: Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._skills.asMap().entries.map((entry) {
                  final i = entry.key;
                  final skillNameCtrl = TextEditingController(
                    text: _skills[i].name,
                  );
                  final skillPctCtrl = TextEditingController(
                    text: _skills[i].percentage.toString(),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: skillNameCtrl,
                            onChanged: (v) {
                              _skills[i] = SkillModel(
                                name: v,
                                percentage: _skills[i].percentage,
                              );
                            },
                            decoration: _inputDecoration('Skill name'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: skillPctCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (v) {
                              _skills[i] = SkillModel(
                                name: _skills[i].name,
                                percentage: int.tryParse(v) ?? 0,
                              );
                            },
                            decoration: _inputDecoration('%'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeSkill(i),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 28),

                // Info box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFB74D)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFFF8A65),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Earnings and project count are calculated automatically from your work history.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      disabledBackgroundColor: const Color(
                        0xFF6C5CE7,
                      ).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF888888), size: 20),
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6C5CE7),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    _responseTimeController.dispose();
    super.dispose();
  }
}
