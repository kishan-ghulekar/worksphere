import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:super_project/View/FreelancerDashboard/FreelancerProfile.dart';
import 'package:super_project/View/FreelancerDashboard/NotificationPage.dart';
import 'package:super_project/View/FreelancerDashboard/myApplicationPage.dart';
import 'package:super_project/model/projectModel.dart';
import 'package:super_project/viewmodel/Bloc/freelancerProfileBloc.dart';
import 'package:super_project/viewmodel/Bloc/projectBloc.dart';
import 'package:super_project/viewmodel/Events/freelancerProfileEvent.dart';
import 'package:super_project/viewmodel/Events/projectEvent.dart';
import 'package:super_project/viewmodel/States/authState.dart';
import 'package:super_project/viewmodel/States/freelancerProfileState.dart';
import 'package:super_project/viewmodel/States/projectState.dart';
import 'projectDetails.dart';

class Freelancerdashboard extends StatefulWidget {
  const Freelancerdashboard({super.key});

  @override
  State<Freelancerdashboard> createState() => _FreelancerdashboardState();
}

class _FreelancerdashboardState extends State<Freelancerdashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(const LoadAllProjectsRequested());
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<FreelancerProfileBloc>().add(LoadFreelancerProfile(uid));
    }
  }

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
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
          BlocBuilder<FreelancerProfileBloc, FreelancerProfileState>(
            builder: (context, state) {
              String imageUrl = '';
              String name = 'F';

              if (state is FreelancerProfileLoaded) {
                imageUrl = state.freelancer.profileImageUrl;
                if (state.freelancer.name.isNotEmpty) {
                  name = state.freelancer.name[0].toUpperCase();
                }
              }

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        imageUrl.isNotEmpty
                            ? CachedNetworkImageProvider(imageUrl)
                            : null,
                    child:
                        imageUrl.isEmpty
                            ? Text(
                              name,
                              style: const TextStyle(
                                color: Color(0xFF6C5CE7),
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          if (state is ProjectLoading || state is ProjectInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final projects =
              state is AllProjectsLoadSuccess
                  ? state.projects
                  : <ProjectModel>[];

          if (projects.isEmpty) {
            return const Center(
              child: Text(
                'No open projects available right now.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return Column(
            children: [
              // Filter chip row — keep your existing UI
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Chip(
                      label: Text(
                        '${projects.length} Open Projects',
                        style: const TextStyle(fontSize: 13),
                      ),
                      backgroundColor: Colors.grey[100],
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: projects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return JobCard(project: project);
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            if (index == 3) {
              BlocBuilder<FreelancerProfileBloc, FreelancerProfileState>(
                builder: (context, state) {
                  final imageUrl =
                      state is FreelancerProfileLoaded
                          ? state.freelancer.profileImageUrl
                          : '';
                  final name =
                      state is FreelancerProfileLoaded
                          ? state.freelancer.name
                          : '';
                  return GestureDetector(
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(
                          0xFF6C5CE7,
                        ).withOpacity(0.15),
                        backgroundImage:
                            imageUrl.isNotEmpty
                                ? CachedNetworkImageProvider(imageUrl)
                                : null,
                        child:
                            imageUrl.isEmpty
                                ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'F',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6C5CE7),
                                  ),
                                )
                                : null,
                      ),
                    ),
                  );
                },
              );
            } else if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyApplicationsPage(),
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
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final ProjectModel project;

  const JobCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(project.createdAt);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.title,
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
                project.category,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.currency_rupee, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 2),
              Text(
                'Budget: ₹${project.budget.toStringAsFixed(0)}',
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
                formattedDate,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 4),
              Text(
                'Duration: ${project.duration}',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailsPage(project: project),
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
