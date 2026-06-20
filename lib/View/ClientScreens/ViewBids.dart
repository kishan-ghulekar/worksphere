import 'package:flutter/material.dart';

// Model for Freelancer
class Freelancer {
  final String name;
  final String title;
  final String imageUrl;
  final double rating;
  final List<String> skills;
  final String category;

  Freelancer({
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.skills,
    required this.category,
  });
}

// View Bids Page
class ViewBidsPage extends StatelessWidget {
  final String projectTitle;

  const ViewBidsPage({
    super.key,
    this.projectTitle = "Develop a Campus Event Management V",
  });

  @override
  Widget build(BuildContext context) {
    final List<Freelancer> freelancers = [
      Freelancer(
        name: "Ananya Sharma",
        title: "Expert UI/UX Designer",
        imageUrl: "assets/ananya.jpg",
        rating: 4.9,
        skills: ["Figma", "Sketch", "Prototyping"],
        category: "User Research",
      ),
      Freelancer(
        name: "Rahul Kumar",
        title: "Full-Stack Web Developer",
        imageUrl: "assets/rahul.jpg",
        rating: 4.7,
        skills: ["React", "Node.js", "MongoDB", "AWS"],
        category: "Python",
      ),
      Freelancer(
        name: "Priya Singh",
        title: "Content Writer & SEO Specialist",
        imageUrl: "assets/priya.jpg",
        rating: 4.8,
        skills: ["Copywriting", "SEO", "Blog Posts"],
        category: "Editing",
      ),
      Freelancer(
        name: "Vivek Gupta",
        title: "Data Analyst & Visualization",
        imageUrl: "assets/vivek.jpg",
        rating: 4.8,
        skills: ["SQL", "Python", "Tableau", "Excel"],
        category: "Statistics",
      ),
      Freelancer(
        name: "Shreya Das",
        title: "Social Media Marketing",
        imageUrl: "assets/shreya.jpg",
        rating: 4.9,
        skills: ["Instagram", "Facebook", "Content Strategy"],
        category: "Analytics",
      ),
    ];

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
          "View Bids",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: freelancers.length,
        itemBuilder: (context, index) {
          return FreelancerCard(freelancer: freelancers[index]);
        },
      ),
    );
  }
}

// Freelancer Card Widget
class FreelancerCard extends StatelessWidget {
  final Freelancer freelancer;

  const FreelancerCard({super.key, required this.freelancer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue[100],
                child: Text(
                  freelancer.name[0],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      freelancer.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      freelancer.title,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4081),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      freelancer.rating.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Skills Section
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                freelancer.skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 12),
          // Category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              freelancer.category,
              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle hire action
                    // // Navigator.of(context).push(
                    // //   MaterialPageRoute(
                    // //     builder: (context) {
                    // //       return HireConfirmationPage(
                    // //         project: Project(
                    // //           title: "",
                    // //           duration: "",
                    // //           budget: 0,
                    // //         ),
                    // //         freelancer: FreelancerDetail(
                    // //           name: "",
                    // //           imageUrl: "",
                    // //           rating: 0,
                    // //           reviewCount: 0,
                    // //           isVerified: true,
                    // //         ),
                    // //       );
                    // //     },
                    // //   ),
                    // );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hiring ${freelancer.name}...'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Hire",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle chat action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Opening chat with ${freelancer.name}...',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text(
                    "Chat",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

// Example usage in your project list screen
class ProjectCard extends StatelessWidget {
  final String title;
  final String category;
  final String budget;
  final String duration;

  const ProjectCard({
    super.key,
    required this.title,
    required this.category,
    required this.budget,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              Text(
                "Budget: $budget",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              Text(
                "Duration: $duration",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewBidsPage(projectTitle: ""),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text("View Bids"),
          ),
        ],
      ),
    );
  }
}
