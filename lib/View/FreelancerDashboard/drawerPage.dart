// lib/View/FreelancerDashboard/FreelancerDrawer.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/View/FreelancerDashboard/FreelancerProfile.dart';
import 'package:super_project/View/FreelancerDashboard/contractScreen.dart';
import 'package:super_project/View/FreelancerDashboard/myApplicationPage.dart';
import 'package:super_project/viewmodel/Bloc/freelancerProfileBloc.dart';
import 'package:super_project/viewmodel/States/freelancerProfileState.dart';

class FreelancerDrawer extends StatefulWidget {
  const FreelancerDrawer({super.key});

  @override
  State<FreelancerDrawer> createState() => _FreelancerDrawerState();
}

class _FreelancerDrawerState extends State<FreelancerDrawer> {
  // Track which section is expanded
  final Map<String, bool> _expandedSections = {};

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: BlocBuilder<FreelancerProfileBloc, FreelancerProfileState>(
        builder: (context, state) {
          final imageUrl =
              state is FreelancerProfileLoaded
                  ? state.freelancer.profileImageUrl
                  : '';
          final name =
              state is FreelancerProfileLoaded
                  ? state.freelancer.name
                  : 'Freelancer';
          final title =
              state is FreelancerProfileLoaded ? state.freelancer.title : '';
          final rating =
              state is FreelancerProfileLoaded ? state.freelancer.rating : 0.0;

          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B67F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          backgroundImage:
                              imageUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(imageUrl)
                                  : null,
                          child:
                              imageUrl.isEmpty
                                  ? Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : 'F',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (title.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (rating > 0) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        child: const Text(
                          'View Profile →',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Dashboard
                    _buildSection(
                      context,
                      icon: Icons.dashboard_outlined,
                      title: '🏠 Dashboard',
                      color: const Color(0xFF5B67F1),
                      children: [
                        _buildSubItem(
                          context,
                          'Overview',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Statistics',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Recent Activity',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // My Projects
                    _buildSection(
                      context,
                      icon: Icons.work_outline,
                      title: '💼 My Projects',
                      color: Colors.orange,
                      children: [
                        _buildSubItem(
                          context,
                          'Active Projects',
                          onTap: () {
                            _close(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FreelancerContractsPage(),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          'Completed Projects',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Pending Projects',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Cancelled Projects',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Earnings
                    _buildSection(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      title: '💰 Earnings',
                      color: Colors.green,
                      children: [
                        _buildSubItem(
                          context,
                          'Total Earnings',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Withdraw Money',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Transaction History',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Razorpay Wallet',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Proposals
                    _buildSection(
                      context,
                      icon: Icons.description_outlined,
                      title: '📄 Proposals',
                      color: Colors.blue,
                      children: [
                        _buildSubItem(
                          context,
                          'Sent Proposals',
                          onTap: () {
                            _close(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MyApplicationsPage(),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          'Proposal Status',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Saved Jobs',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Reviews
                    _buildSection(
                      context,
                      icon: Icons.star_outline,
                      title: '⭐ Reviews',
                      color: Colors.amber,
                      children: [
                        _buildSubItem(
                          context,
                          'Client Reviews',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Ratings',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Testimonials',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Schedule
                    _buildSection(
                      context,
                      icon: Icons.calendar_today_outlined,
                      title: '📅 Schedule',
                      color: Colors.teal,
                      children: [
                        _buildSubItem(
                          context,
                          'Calendar',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Meetings',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Deadlines',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Messages
                    _buildSection(
                      context,
                      icon: Icons.chat_bubble_outline,
                      title: '💬 Messages',
                      color: const Color(0xFF5B67F1),
                      children: [
                        _buildSubItem(
                          context,
                          'Chats',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Video Meetings',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Portfolio
                    _buildSection(
                      context,
                      icon: Icons.folder_outlined,
                      title: '📁 Portfolio',
                      color: Colors.purple,
                      children: [
                        _buildSubItem(
                          context,
                          'Upload Portfolio',
                          onTap: () {
                            _close(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          'Certificates',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Resume / CV',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Analytics
                    _buildSection(
                      context,
                      icon: Icons.bar_chart_outlined,
                      title: '📊 Analytics',
                      color: Colors.indigo,
                      children: [
                        _buildSubItem(
                          context,
                          'Profile Views',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Proposal Success Rate',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Earnings Graph',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Job Success Score',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Skills
                    _buildSection(
                      context,
                      icon: Icons.psychology_outlined,
                      title: '🎯 Skills',
                      color: Colors.cyan,
                      children: [
                        _buildSubItem(
                          context,
                          'Add Skills',
                          onTap: () {
                            _close(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          'Experience',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Education',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Languages',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Bookmarks
                    _buildSection(
                      context,
                      icon: Icons.bookmark_outline,
                      title: '🔖 Bookmarks',
                      color: Colors.pink,
                      children: [
                        _buildSubItem(
                          context,
                          'Saved Jobs',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Favourite Clients',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Referral
                    _buildSection(
                      context,
                      icon: Icons.card_giftcard_outlined,
                      title: '🎁 Referral',
                      color: Colors.deepOrange,
                      children: [
                        _buildSubItem(
                          context,
                          'Invite Friends',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Referral Earnings',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Support
                    _buildSection(
                      context,
                      icon: Icons.support_agent_outlined,
                      title: '🛠 Support',
                      color: Colors.brown,
                      children: [
                        _buildSubItem(
                          context,
                          'Help Center',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Report Problem',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'FAQ',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    // Settings
                    _buildSection(
                      context,
                      icon: Icons.settings_outlined,
                      title: '⚙ Settings',
                      color: Colors.grey,
                      children: [
                        _buildSubItem(
                          context,
                          'Edit Profile',
                          onTap: () {
                            _close(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          'Change Password',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Notifications',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Privacy',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Theme (Dark / Light)',
                          onTap: () => _close(context),
                        ),
                        _buildSubItem(
                          context,
                          'Language',
                          onTap: () => _close(context),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Logout
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        '🚪 Logout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await FirebaseAuth.instance.signOut();
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    final isExpanded = _expandedSections[title] ?? false;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedSections[title] = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(left: 48, right: 16, bottom: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(children: children),
          ),
      ],
    );
  }

  Widget _buildSubItem(
    BuildContext context,
    String label, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF5B67F1),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _close(BuildContext context) => Navigator.pop(context);
}
