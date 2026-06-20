import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Rahul Kumar',
  );
  final TextEditingController _titleController = TextEditingController(
    text: 'Full-Stack Developer & UI/UX Designer',
  );
  final TextEditingController _locationController = TextEditingController(
    text: 'Mumbai, India',
  );
  final TextEditingController _aboutController = TextEditingController(
    text:
        'Passionate computer science student with 3+ years of experience in web and mobile development. I specialize in creating modern, responsive applications using React, Flutter, and Node.js. Currently pursuing B.Tech in Computer Science at IIT Mumbai.',
  );
  final TextEditingController _responseTimeController = TextEditingController(
    text: '2',
  );

  // Skills
  final TextEditingController _skill1Controller = TextEditingController(
    text: 'React',
  );
  final TextEditingController _skill1PercentController = TextEditingController(
    text: '90',
  );
  final TextEditingController _skill2Controller = TextEditingController(
    text: 'Flutter',
  );
  final TextEditingController _skill2PercentController = TextEditingController(
    text: '85',
  );
  final TextEditingController _skill3Controller = TextEditingController(
    text: 'Node.js',
  );
  final TextEditingController _skill3PercentController = TextEditingController(
    text: '80',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    _responseTimeController.dispose();
    _skill1Controller.dispose();
    _skill1PercentController.dispose();
    _skill2Controller.dispose();
    _skill2PercentController.dispose();
    _skill3Controller.dispose();
    _skill3PercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Image with Edit Button
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFE8E8E8),
                  child: const Text(
                    'R',
                    style: TextStyle(
                      fontSize: 40,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Basic Information Section
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),
            _buildInputField(
              'Full Name',
              _nameController,
              Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              'Title/Position',
              _titleController,
              Icons.work_outline,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              'Location',
              _locationController,
              Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              'Response Time (hours)',
              _responseTimeController,
              Icons.access_time,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 32),

            // About Section
            _buildSectionTitle('About'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _aboutController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Tell us about yourself...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE8E8E8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6C5CE7),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Skills Section
            _buildSectionTitle('Skills'),
            const SizedBox(height: 12),
            _buildSkillInput(
              'Skill 1',
              _skill1Controller,
              _skill1PercentController,
            ),
            const SizedBox(height: 16),
            _buildSkillInput(
              'Skill 2',
              _skill2Controller,
              _skill2PercentController,
            ),
            const SizedBox(height: 16),
            _buildSkillInput(
              'Skill 3',
              _skill3Controller,
              _skill3PercentController,
            ),

            const SizedBox(height: 32),

            // Statistics Info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB74D)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFFF8A65),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your earnings (₹1,85,000) and projects (25) are calculated automatically based on your work history.',
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

            const SizedBox(height: 32),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle save - would navigate back to profile screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: Color(0xFF00D4AA),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
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
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE8E8E8),
                  width: 1,
                ),
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
      ),
    );
  }

  Widget _buildSkillInput(
    String label,
    TextEditingController nameController,
    TextEditingController percentController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
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
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Skill name',
                    hintStyle: const TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8E8E8),
                        width: 1,
                      ),
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
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: percentController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '%',
                    hintStyle: const TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8E8E8),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF6C5CE7),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
