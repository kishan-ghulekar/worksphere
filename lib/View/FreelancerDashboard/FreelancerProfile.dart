import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  final TextEditingController nameController = TextEditingController(
    text: 'Kishan Ghulekar',
  );
  final TextEditingController aboutController = TextEditingController(
    text:
        'Lorem ipsum dolor sit amet consectetur adipiscing elit Ut et massa mi. Praesent nec velit sit amet tortor feugiat malesuada eget eget metus.',
  );
  List<String> skills = ['Flutter', 'CSS', 'JavaScript', 'React', 'Node.js'];
  final TextEditingController newSkillController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    aboutController.dispose();
    newSkillController.dispose();
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
          onPressed: () {},
        ),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: () {},
            ),
          IconButton(
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: isEditing ? Colors.green : Colors.black,
            ),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFFE8D5C4),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.brown,
                        ),
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF6C5CE7),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Handle image change
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Change profile picture'),
                                  ),
                                );
                              },
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isEditing)
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    )
                  else
                    Text(
                      nameController.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (!isEditing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Contact Me',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: const Text(
                            'Follow',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // About Me Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Me',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (isEditing)
                    TextField(
                      controller: aboutController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    )
                  else
                    Text(
                      aboutController.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),

            // Skills Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isEditing)
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Color(0xFF6C5CE7),
                          ),
                          onPressed: () {
                            // _showAddSkillDialog(context);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        skills
                            .map(
                              (skill) => _buildSkillChip(
                                skill,
                                Colors.blue[50]!,
                                isEditing,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),

            // Portfolio Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Portfolio',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildPortfolioItem(
                    'Travel App',
                    'Mobile Application',
                    Colors.amber[100]!,
                  ),
                  const SizedBox(height: 16),
                  _buildPortfolioItem(
                    'Project Alpha',
                    'Website Design for client',
                    Colors.grey[100]!,
                  ),
                  const SizedBox(height: 16),
                  _buildPortfolioItem(
                    'E-Shop',
                    'Web application built with Mern stack',
                    Colors.white,
                    showImage: true,
                  ),
                  const SizedBox(height: 16),
                  _buildPortfolioItem(
                    'My Portfolio',
                    'Website template showcasing my work',
                    Colors.grey[900]!,
                    isLast: true,
                  ),
                ],
              ),
            ),

            // Reviews & Ratings Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reviews & Ratings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '4.8',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Based on 234 Reviews',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  _buildRatingBar(5, 0.8),
                  _buildRatingBar(4, 0.6),
                  _buildRatingBar(3, 0.3),
                  _buildRatingBar(2, 0.1),
                  _buildRatingBar(1, 0.05),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   selectedItemColor: const Color(0xFF6C5CE7),
      //   unselectedItemColor: Colors.grey,
      //   currentIndex: 3,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.chat_bubble_outline),
      //       label: '',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.description_outlined),
      //       label: '',
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      //     BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
      //   ],
      // ),
    );
  }

  Widget _buildSkillChip(String label, Color color, bool isEditing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.blue, fontSize: 14),
      ),
    );
  }

  Widget _buildPortfolioItem(
    String title,
    String subtitle,
    Color bgColor, {
    bool showImage = false,
    bool isLast = false,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Stack(
        children: [
          if (showImage)
            Center(
              child: Icon(Icons.grid_view, size: 60, color: Colors.green[700]),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLast ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLast ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
