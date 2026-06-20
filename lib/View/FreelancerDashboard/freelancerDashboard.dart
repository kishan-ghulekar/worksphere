import 'package:flutter/material.dart';
import 'package:super_project/View/FreelancerDashboard/FreelancerProfile.dart';
import 'package:super_project/View/FreelancerDashboard/NotificationPage.dart';
import 'projectDetails.dart';

class Freelancerdashboard extends StatefulWidget {
  const Freelancerdashboard({super.key});

  @override
  State<Freelancerdashboard> createState() => _Freelancerdashboard();
}

class _Freelancerdashboard extends State<Freelancerdashboard> {
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
          'WorkSphere',
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
          IconButton(
            icon: Icon(Icons.person, color: Colors.grey[800]),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ProfileScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Chip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Weekend-only', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 4),
                      Icon(Icons.close, size: 16),
                    ],
                  ),
                  backgroundColor: Colors.grey[100],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
          ),

          // Job List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                JobCard(
                  title: 'Social Media\nContent Creator',
                  tag: 'Weekend Only',
                  description:
                      'Create engaging social media content for a local startup. Requires creativity and experience.',
                  salary: '₹5,000 - ₹8,000',
                  date: '28 May 2024',
                ),
                SizedBox(height: 16),
                JobCard(
                  title: 'Data Entry &\nAnalysis',
                  tag: 'Weekend Only',
                  description:
                      'Assist with data compilation and basic analysis for a market research project.',
                  salary: '₹3,000 - ₹4,500',
                  date: '01 June 2024',
                ),
                SizedBox(height: 16),
                JobCard(
                  title: 'Video Editor for\nShort Films',
                  tag: 'Weekend Only',
                  description:
                      'Edit short promotional videos for various campaigns. Experience with Adobe.',
                  salary: '₹7,000 - ₹10,000',
                  date: '20 June 2024',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            if (index == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ProfileScreen();
                  },
                ),
              );
            }
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5B67F1),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Dashboard',
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
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String tag;
  final String description;
  final String salary;
  final String date;

  const JobCard({
    super.key,
    required this.title,
    required this.tag,
    required this.description,
    required this.salary,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5B67F1), width: 1.5),
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
          // Title and Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tag,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // Salary and Date
          Row(
            children: [
              Icon(Icons.currency_rupee, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 2),
              Text(
                salary,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 24),
              Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // View Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ProjectDetailsPage();
                    },
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Viewing details for: $title'),
                    backgroundColor: const Color(0xFF5B67F1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B67F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
