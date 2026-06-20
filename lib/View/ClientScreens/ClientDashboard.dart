import 'package:flutter/material.dart';
import 'package:super_project/View/ClientScreens/ClientProfile.dart';
import 'package:super_project/View/ClientScreens/ViewBids.dart';
import 'package:super_project/View/FreelancerDashboard/NotificationPage.dart';

import 'PostProject.dart';

class ClientDashboardPage extends StatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  State<ClientDashboardPage> createState() => _ClientDashboardPage();
}

class _ClientDashboardPage extends State<ClientDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey[800]),
          onPressed: () {},
        ),
        title: const Text(
          'Worksphere',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[800]),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return NotificationScreen();
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ClientProfileScreen();
                    },
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[300],
                backgroundImage: const AssetImage("assets/AppLogo1.png"),
                // backgroundImage: const AssetImage("assets/MyImage.jpg"),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ProjectCard(
            title: 'Develop a Campus Navigation App',
            category: 'Mobile App Development',
            budget: '₹15,000',
            duration: '30 days',
            status: 'Receiving Bids',
            statusColor: Colors.pink,
          ),
          SizedBox(height: 16),
          ProjectCard(
            title: 'Design Marketing Collateral for Tech Fest',
            category: 'Graphic Design',
            budget: '₹8,000',
            duration: '15 days',
            status: 'Active',
            statusColor: Color(0xFF00BFA5),
          ),
          SizedBox(height: 16),
          ProjectCard(
            title: 'Content Writing for University Blog',
            category: 'Content Writing',
            budget: '₹12,000',
            duration: '20 days',
            status: 'Completed',
            statusColor: Color(0xFF5B67F1),
          ),
          SizedBox(height: 16),
          ProjectCard(
            title: 'Data Entry and Analysis for Research Project',
            category: 'Data Science',
            budget: '₹7,000',
            duration: '10 days',
            status: 'Active',
            statusColor: Color(0xFF00BFA5),
          ),
          SizedBox(height: 16),
          ProjectCard(
            title: 'Website Redesign for Student Club',
            category: 'Web Development',
            budget: '₹20,000',
            duration: '45 days',
            status: 'Closed',
            statusColor: Colors.red,
          ),
          SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return PostProjectScreen();
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create new project'),
              backgroundColor: Color(0xFF5B67F1),
            ),
          );
        },
        backgroundColor: const Color(0xFF5B67F1),
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          // if (_selectedIndex == 0) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) {
          //         return ClientDashboardPage();
          //       },
          //     ),
          //   );
          // } else if (_selectedIndex == 1) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) {
          //         return ClientDashboardPage();
          //       },
          //     ),
          //   );
          // } else if (_selectedIndex == 2) {
          //   //   Navigator.of(context).push(
          //   //     MaterialPageRoute(
          //   //       builder: (context) {
          //   //         // return ClientPr();
          //   //       },
          //   //     ),
          //   //   );
          // }
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5B67F1),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Contracts',
          ),
        ],
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String category;
  final String budget;
  final String duration;
  final String status;
  final Color statusColor;

  const ProjectCard({
    super.key,
    required this.title,
    required this.category,
    required this.budget,
    required this.duration,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Category
          Text(
            category,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),

          const SizedBox(height: 12),

          // Budget
          Row(
            children: [
              Icon(Icons.currency_rupee, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 2),
              Text(
                'Budget: $budget',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Duration
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 4),
              Text(
                'Duration: $duration',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ViewBidsPage();
                        },
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('View Bids for: $title'),
                        backgroundColor: const Color(0xFF5B67F1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B67F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Bids',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
