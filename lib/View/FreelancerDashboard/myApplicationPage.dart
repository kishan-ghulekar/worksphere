// lib/View/FreelancerDashboard/MyApplicationsPage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:super_project/model/bidModel.dart';
import 'package:super_project/viewmodel/Bloc/bidBloc.dart';
import 'package:super_project/viewmodel/Events/bidEvents.dart';
import 'package:super_project/viewmodel/States/bidStates.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  final _searchController = TextEditingController();
  final List<Map<String, String>> _tabs = [
    {'label': 'All', 'value': 'all'},
    {'label': 'Applied', 'value': 'pending'},
    {'label': 'Under Review', 'value': 'under_review'},
    {'label': 'Shortlisted', 'value': 'shortlisted'},
    {'label': 'Hired', 'value': 'accepted'},
    {'label': 'Rejected', 'value': 'rejected'},
  ];

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<BidBloc>().add(LoadMyBids(currentUser.uid));
    }
  }

  Future<void> _onRefresh() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<BidBloc>().add(LoadMyBids(currentUser.uid));
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Applications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<BidBloc, BidState>(
        listener: (context, state) {
          if (state is BidWithdrawSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Application withdrawn successfully'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is BidFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BidLoading || state is BidInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBids = state is ApplicationsLoaded ? state.allBids : <BidModel>[];
          final filteredBids = state is ApplicationsLoaded ? state.filteredBids : <BidModel>[];
          final activeFilter = state is ApplicationsLoaded ? state.activeFilter : 'all';

          return Column(
            children: [
              // Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    context.read<BidBloc>().add(SearchApplications(query));
                  },
                  decoration: InputDecoration(
                    hintText: 'Search applications...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              context.read<BidBloc>().add(const SearchApplications(''));
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Status Tabs
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _tabs.map((tab) {
                      final isActive = activeFilter == tab['value'];
                      final count = tab['value'] == 'all'
                          ? allBids.length
                          : allBids.where((b) => b.status == tab['value']).length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            context.read<BidBloc>().add(
                                  FilterApplicationsByStatus(tab['value']!),
                                );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF5B67F1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  tab['label']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                                if (count > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.white.withOpacity(0.3)
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isActive
                                            ? Colors.white
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Applications List
              Expanded(
                child: filteredBids.isEmpty
                    ? _buildEmptyState(activeFilter)
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: const Color(0xFF5B67F1),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredBids.length,
                          itemBuilder: (context, index) {
                            return ApplicationCard(bid: filteredBids[index]);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            filter == 'all'
                ? "You haven't applied to any projects yet."
                : "No applications with this status.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          if (filter == 'all') ...[
            const SizedBox(height: 8),
            Text(
              'Browse projects and submit your first bid!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ApplicationCard extends StatelessWidget {
  final BidModel bid;

  const ApplicationCard({super.key, required this.bid});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'shortlisted':
        return const Color(0xFF5B67F1);
      case 'accepted':
        return const Color(0xFF00BFA5);
      case 'rejected':
        return Colors.red;
      case 'withdrawn':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Applied';
      case 'under_review':
        return 'Under Review';
      case 'shortlisted':
        return 'Shortlisted';
      case 'accepted':
        return 'Hired';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return status;
    }
  }

  double _progressValue(String status) {
    switch (status) {
      case 'pending':
        return 0.25;
      case 'under_review':
        return 0.50;
      case 'shortlisted':
        return 0.75;
      case 'accepted':
        return 1.0;
      case 'rejected':
        return 1.0;
      default:
        return 0.0;
    }
  }

  List<_StepItem> _buildSteps(String status) {
    final steps = ['Applied', 'Review', 'Shortlisted', 'Hired'];
    final activeIndex = {
      'pending': 0,
      'under_review': 1,
      'shortlisted': 2,
      'accepted': 3,
      'rejected': 1,
    }[status] ?? 0;

    return steps.asMap().entries.map((e) {
      return _StepItem(
        label: e.value,
        isActive: e.key == activeIndex,
        isDone: e.key < activeIndex,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(bid.status);
    final steps = _buildSteps(bid.status);
    final formattedDate = DateFormat('dd MMM').format(bid.createdAt);
    final isRejected = bid.status == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRejected ? Colors.red.withOpacity(0.3) : Colors.transparent,
        ),
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
          // Title + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  bid.projectTitle,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(bid.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Applied date + Bid amount
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'Applied $formattedDate',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.currency_rupee, size: 13, color: Colors.grey[500]),
              Text(
                bid.bidAmount.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress Bar
          if (bid.status != 'withdrawn') ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progressValue(bid.status),
                minHeight: 5,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isRejected ? Colors.red : statusColor,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Step indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: steps.map((step) {
                return Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: step.isActive
                        ? FontWeight.w700
                        : FontWeight.normal,
                    color: step.isActive
                        ? statusColor
                        : step.isDone
                            ? Colors.grey[600]
                            : Colors.grey[400],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Action Buttons
          Row(
            children: [
              if (bid.status == 'pending') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Withdraw Application'),
                          content: const Text(
                              'Are you sure you want to withdraw this application?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context
                                    .read<BidBloc>()
                                    .add(WithdrawBidRequested(bid.bidId));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Withdraw',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Withdraw',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (bid.status == 'accepted') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Message Client',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B67F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Details',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepItem {
  final String label;
  final bool isActive;
  final bool isDone;

  _StepItem({
    required this.label,
    required this.isActive,
    required this.isDone,
  });
}