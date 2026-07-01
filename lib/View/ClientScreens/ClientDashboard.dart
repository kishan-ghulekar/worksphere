import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/View/ClientScreens/ClientProfile.dart';
import 'package:super_project/View/ClientScreens/ViewBids.dart';
import 'package:super_project/View/ClientScreens/contractScreen.dart';
import 'package:super_project/View/FreelancerDashboard/NotificationPage.dart';
import 'package:super_project/model/projectModel.dart';
import 'package:super_project/viewmodel/Bloc/projectBloc.dart';
import 'package:super_project/viewmodel/Events/projectEvent.dart';
import 'package:super_project/viewmodel/States/projectState.dart';

import 'PostProject.dart';

class ClientDashboardPage extends StatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  State<ClientDashboardPage> createState() => _ClientDashboardPage();
}

class _ClientDashboardPage extends State<ClientDashboardPage> {
  int _selectedIndex = 0;
  String _filterStatus = 'All';

  final List<String> _statusFilters = [
    'All',
    'Open',
    'Active',
    'Completed',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<ProjectBloc>().add(LoadProjectsRequested(currentUser.uid));
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.pink;
      case 'active':
      case 'in progress':
        return const Color(0xFF00BFA5);
      case 'completed':
        return const Color(0xFF5B67F1);
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Delete Project',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to delete "${project.title}"? This action cannot be undone.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<ProjectBloc>().add(
                    DeleteProjectRequest(project.projectId),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditBottomSheet(BuildContext context, ProjectModel project) {
    final titleCtrl = TextEditingController(text: project.title);
    final descCtrl = TextEditingController(text: project.description);
    final budgetCtrl = TextEditingController(
      text: project.budget.toStringAsFixed(0),
    );
    final durationCtrl = TextEditingController(text: project.duration);
    String selectedCategory = project.category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Edit Project',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            16,
                            20,
                            MediaQuery.of(ctx).viewInsets.bottom + 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _editLabel('Project Title'),
                              const SizedBox(height: 8),
                              _editField(titleCtrl, 'Enter project title'),
                              const SizedBox(height: 16),

                              _editLabel('Description'),
                              const SizedBox(height: 8),
                              _editField(
                                descCtrl,
                                'Enter description',
                                maxLines: 4,
                              ),
                              const SizedBox(height: 16),

                              _editLabel('Category'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedCategory,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items:
                                      [
                                            'Web Development',
                                            'Mobile Development',
                                            'Design',
                                            'Backend Development',
                                          ]
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(c),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (v) => setModalState(
                                        () => selectedCategory = v!,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _editLabel('Budget (₹)'),
                                        const SizedBox(height: 8),
                                        _editField(
                                          budgetCtrl,
                                          'e.g. 5000',
                                          keyboardType: TextInputType.number,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _editLabel('Duration'),
                                        const SizedBox(height: 8),
                                        _editField(
                                          durationCtrl,
                                          'e.g. 2 Weeks',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final budget = double.tryParse(
                                      budgetCtrl.text.trim(),
                                    );
                                    if (titleCtrl.text.trim().isEmpty ||
                                        budget == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please fill all required fields',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.pop(ctx);
                                    context.read<ProjectBloc>().add(
                                      UpdateProjectRequested(
                                        projectId: project.projectId,
                                        title: titleCtrl.text.trim(),
                                        description: descCtrl.text.trim(),
                                        category: selectedCategory,
                                        budget: budget,
                                        duration: durationCtrl.text.trim(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5B67F1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
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
    );
  }

  Widget _editLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF444444),
    ),
  );

  Widget _editField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5B67F1), width: 1.5),
        ),
      ),
    );
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
          // Padding(
          //   padding: const EdgeInsets.only(right: 12),
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.of(context).push(
          //         MaterialPageRoute(
          //           builder: (context) => ClientProfileScreen(),
          //         ),
          //       );
          //     },
          //     child: CircleAvatar(
          //       radius: 18,
          //       backgroundColor: Colors.grey[300],
          //       backgroundImage: const AssetImage("assets/AppLogo1.png"),
          //     ),
          //   ),
          // ),
        ],
      ),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectCreateSuccess ||
              state is ProjectDeleteSuccess ||
              state is ProjectUpdateSuccess) {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              context.read<ProjectBloc>().add(
                LoadProjectsRequested(currentUser.uid),
              );
            }
            if (state is ProjectDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is ProjectUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project updated successfully'),
                  backgroundColor: Color(0xFF00BFA5),
                ),
              );
            }
          }
        },
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

          final allProjects =
              state is ProjectLoadSuccess ? state.projects : <ProjectModel>[];

          // Apply filter
          final projects =
              _filterStatus == 'All'
                  ? allProjects
                  : allProjects
                      .where(
                        (p) =>
                            p.status.toLowerCase() ==
                            _filterStatus.toLowerCase(),
                      )
                      .toList();

          return Column(
            children: [
              // Stats Row
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    _statChip('${allProjects.length}', 'Total', Colors.grey),
                    const SizedBox(width: 8),
                    _statChip(
                      '${allProjects.where((p) => p.status.toLowerCase() == 'open').length}',
                      'Open',
                      Colors.pink,
                    ),
                    const SizedBox(width: 8),
                    _statChip(
                      '${allProjects.where((p) => p.status.toLowerCase() == 'active' || p.status.toLowerCase() == 'in progress').length}',
                      'Active',
                      const Color(0xFF00BFA5),
                    ),
                    const SizedBox(width: 8),
                    _statChip(
                      '${allProjects.where((p) => p.status.toLowerCase() == 'completed').length}',
                      'Done',
                      const Color(0xFF5B67F1),
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children:
                        _statusFilters.map((filter) {
                          final isActive = _filterStatus == filter;
                          return GestureDetector(
                            onTap: () => setState(() => _filterStatus = filter),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isActive
                                        ? const Color(0xFF5B67F1)
                                        : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isActive
                                          ? Colors.white
                                          : Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),

              // Project List
              Expanded(
                child:
                    projects.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _filterStatus == 'All'
                                    ? "You haven't posted any projects yet.\nTap + to post your first project."
                                    : "No $_filterStatus projects found.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: projects.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            return ProjectCard(
                              project: project,
                              statusColor: _statusColor(project.status),
                              onEdit:
                                  () => _showEditBottomSheet(context, project),
                              onDelete:
                                  () => _showDeleteDialog(context, project),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => PostProjectScreen()));
        },
        backgroundColor: const Color(0xFF5B67F1),
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Navigator.of(context).push(
              // ignore: inference_failure_on_instance_creation
              MaterialPageRoute(
                builder: (context) => const ClientDashboardPage(),
              ),
            );
          } else if (index == 3) {
            Navigator.of(
              context,
              // ignore: inference_failure_on_instance_creation
            ).push(
              MaterialPageRoute(builder: (_) => const ClientProfileScreen()),
            );
          }else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClientContractsPage()),
            );
          }
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
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Contracts',
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

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final Color statusColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.statusColor,
    required this.onEdit,
    required this.onDelete,
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
          // Title + Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.title,
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
                  project.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            project.category,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),

          const SizedBox(height: 6),

          // Description preview
          Text(
            project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // Budget + Duration
          Row(
            children: [
              Icon(Icons.currency_rupee, size: 13, color: Colors.grey[600]),
              Text(
                'Budget: ₹${project.budget.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.schedule, size: 13, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                project.duration,
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
                        builder: (context) => ViewBidsPage(project: project),
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
              // Edit Button
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Delete Button
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
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
