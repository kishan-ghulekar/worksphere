import 'package:flutter/material.dart';

class ProjectDetailsPage extends StatelessWidget {
  const ProjectDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Project Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Job Title
                const Text(
                  'Looking for a Creative UI/UX Designer for WorkSphere App',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Company Name
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.business,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'CampusGigs Inc.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Project Overview
                const Text(
                  'Project Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'CampusGigs is developing a new mobile-first freelancing platform designed to connect students with project opportunities. We require an experienced UI/UX designer to craft an intuitive, visually appealing, and highly engaging user interface for our platform. The ideal candidate should specialize in have a strong portfolio demonstrating mobile app design expertise, a keen eye for modern aesthetics, and a solid understanding of user experience design principles. You will work closely with our product and development teams to translate wireframes and user stories into pixel-perfect designs. The project involves designing several key screens, including dashboards, project listings, bidding flows, and user profiles. We are looking for someone with a vibrant, professional aesthetic are',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                // Key Details
                const Text(
                  'Key Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                // Budget and Duration
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      size: 16,
                      color: Colors.black,
                    ),
                    const Text(
                      '1,000 - ₹8,000',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Fixed',
                        style: TextStyle(fontSize: 11, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.schedule, size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    const Text(
                      '2 Weeks (Flexible)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag('UI/UX Design', Colors.pink),
                    _buildTag('Figma', Colors.purple),
                    _buildTag('Mobile App', Colors.blue),
                    _buildTag('Freelancing', Colors.orange),
                  ],
                ),

                const SizedBox(height: 24),

                // Attachments
                const Text(
                  'Attachments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                _buildAttachment(
                  'CampusGigs_Wireframes.pdf',
                  '1.2 MB',
                  Icons.picture_as_pdf,
                ),
                _buildAttachment(
                  'Brand_Guidelines.zip',
                  '10 MB',
                  Icons.folder_zip,
                ),
                _buildAttachment(
                  'User_Flows.docx',
                  '1.8 MB',
                  Icons.description,
                ),

                const SizedBox(height: 24),

                // About the Client
                const Text(
                  'About the Client',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),

          // Bottom Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Save for Later Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Save for Later',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Bid Now Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B67F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.gavel, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Bid Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildAttachment(String name, String size, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  size,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, size: 20, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
