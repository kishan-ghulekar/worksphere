import 'package:flutter/material.dart';

// Model for Project
class Project {
  final String title;
  final String duration;
  final double budget;

  Project({required this.title, required this.duration, required this.budget});
}

// Model for Freelancer (reuse from previous file)
class FreelancerDetail {
  final String name;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isVerified;

  FreelancerDetail({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
  });
}

// Hire Confirmation Page
class HireConfirmationPage extends StatelessWidget {
  final Project project;
  final FreelancerDetail freelancer;

  const HireConfirmationPage({
    super.key,
    required this.project,
    required this.freelancer,
  });

  @override
  Widget build(BuildContext context) {
    final double escrowDeposit = project.budget;
    final double platformFee = 0.0;
    final double finalAmount = escrowDeposit + platformFee;

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
          "Confirm Hire",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Details Section
              _buildSectionTitle("Project Details"),
              const SizedBox(height: 12),
              _buildProjectDetailsCard(),
              const SizedBox(height: 24),

              // Selected Freelancer Section
              _buildSectionTitle("Selected Freelancer"),
              const SizedBox(height: 12),
              _buildFreelancerCard(),
              const SizedBox(height: 24),

              // Payment Summary Section
              _buildSectionTitle("Payment Summary"),
              const SizedBox(height: 12),
              _buildPaymentSummaryCard(escrowDeposit, platformFee, finalAmount),
              const SizedBox(height: 20),

              // Information Note
              _buildInfoNote(),
              const SizedBox(height: 24),

              // Confirm Hire Button
              _buildConfirmButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProjectDetailsCard() {
    return Container(
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
        children: [
          _buildDetailRow("Title:", project.title),
          const SizedBox(height: 12),
          _buildDetailRow("Duration:", project.duration),
          const SizedBox(height: 12),
          _buildDetailRow("Budget:", "₹${project.budget.toStringAsFixed(0)}"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFreelancerCard() {
    return Container(
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
      child: Row(
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
          // Freelancer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  freelancer.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFA726), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${freelancer.rating}",
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "(${freelancer.reviewCount})",
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
                if (freelancer.isVerified) ...[
                  const SizedBox(height: 4),
                  Text(
                    "College Verified",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(
    double escrowDeposit,
    double platformFee,
    double finalAmount,
  ) {
    return Container(
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
        children: [
          _buildPaymentRow(
            "Total Project Value:",
            "₹${escrowDeposit.toStringAsFixed(0)}",
            isRegular: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentRow(
            "Escrow Deposit:",
            "₹${escrowDeposit.toStringAsFixed(0)}",
            isRegular: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentRow(
            "Platform Fee:",
            "₹${platformFee.toStringAsFixed(0)}",
            isRegular: true,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildPaymentRow(
            "Final Amount Due:",
            "₹${finalAmount.toStringAsFixed(0)}",
            isRegular: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    String amount, {
    required bool isRegular,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isRegular ? 14 : 15,
            color: isRegular ? Colors.grey[600] : const Color(0xFF6366F1),
            fontWeight: isRegular ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isRegular ? 14 : 16,
            color: isRegular ? Colors.black87 : const Color(0xFF6366F1),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: const Color(0xFF6366F1), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                children: const [
                  TextSpan(
                    text:
                        "By confirming, the payment will be held in escrow by ",
                  ),
                  TextSpan(
                    text: "CampusGigs",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text:
                        " until the project is completed to your satisfaction. This ensures a secure transaction for ",
                  ),
                  TextSpan(
                    text: "both parties",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: "."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showConfirmationDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Confirm Hire",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirm Hire?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: Text(
            "Are you sure you want to hire ${freelancer.name} for this project? The payment will be held in escrow.",
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _showSuccessScreen(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Hire Confirmed!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "You have successfully hired ${freelancer.name}. The payment has been held in escrow.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Back to Projects",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Example usage - Navigation from View Bids page
class FreelancerCardWithNavigation extends StatelessWidget {
  final String name;
  final String title;
  final double rating;

  const FreelancerCardWithNavigation({
    super.key,
    required this.name,
    required this.title,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => HireConfirmationPage(
                  project: Project(
                    title: "Develop a Dynamic Portfolio Website",
                    duration: "4 weeks",
                    budget: 15000,
                  ),
                  freelancer: FreelancerDetail(
                    name: name,
                    imageUrl: "assets/freelancer.jpg",
                    rating: rating,
                    reviewCount: 48,
                    isVerified: true,
                  ),
                ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      child: const Text("Hire"),
    );
  }
}

// Demo Main
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusGigs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: HireConfirmationPage(
        project: Project(
          title: "Develop a Dynamic Portfolio Website",
          duration: "4 weeks",
          budget: 15000,
        ),
        freelancer: FreelancerDetail(
          name: "Ananya Sharma",
          imageUrl: "assets/ananya.jpg",
          rating: 4.8,
          reviewCount: 48,
          isVerified: true,
        ),
      ),
    );
  }
}
