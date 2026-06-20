import 'package:flutter/material.dart';
import 'package:super_project/View/ClientScreens/ClientDashboard.dart';
import 'package:super_project/View/ClientScreens/SignUpScreen.dart';
import 'package:super_project/View/FreelancerDashboard/freelancerDashboard.dart';

class ChoosePathPage extends StatefulWidget {
  const ChoosePathPage({super.key});

  @override
  State<ChoosePathPage> createState() => _ChoosePathPageState();
}

class _ChoosePathPageState extends State<ChoosePathPage> {
  String? selectedPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Choose Your Path',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      const Text(
                        'Tell us how you\'ll use CampusJobs to find\nopportunities or manage projects.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Freelancer Card
                      _PathCard(
                        icon: Icons.work_outline,
                        title: 'Freelancer',
                        description:
                            'Offer your skills, bid on projects, and earn\nmoney for your expertise.',
                        badgeText: 'Ease & Casual',
                        badgeColor: const Color(0xFF00BFA5),
                        isSelected: selectedPath == 'freelancer',
                        onTap: () {
                          setState(() {
                            selectedPath = 'freelancer';
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Client Card
                      _PathCard(
                        icon: Icons.business_outlined,
                        title: 'Client',
                        description:
                            'Post projects, hire talented students, and\nget your tasks done efficiently.',
                        badgeText: 'Hire Top Talent',
                        badgeColor: const Color(0xFF00BFA5),
                        isSelected: selectedPath == 'client',
                        onTap: () {
                          setState(() {
                            selectedPath = 'client';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        selectedPath != null
                            ? () {
                              if (selectedPath == 'freelancer') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Signupscreen(role: selectedPath!);
                                    },
                                  ),
                                );
                              } else if (selectedPath == "client") {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Signupscreen(role: selectedPath!);
                                    },
                                  ),
                                );
                              }
                              // Handle continue action
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Selected: ${selectedPath![0].toUpperCase()}${selectedPath!.substring(1)}',
                                  ),
                                  backgroundColor: const Color(0xFF5B67F1),
                                ),
                              );
                            }
                            : null,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B67F1),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String badgeText;
  final Color badgeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PathCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.badgeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF5B67F1) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF5B67F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: const Color(0xFF5B67F1)),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
