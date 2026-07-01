// lib/View/FreelancerDashboard/FreelancerContractsPage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:super_project/model/contractModel.dart';
import 'package:super_project/viewmodel/Bloc/contractBloc.dart';
import 'package:super_project/viewmodel/Events/contractEvents.dart';
import 'package:super_project/viewmodel/States/contractStates.dart';

class FreelancerContractsPage extends StatefulWidget {
  const FreelancerContractsPage({super.key});

  @override
  State<FreelancerContractsPage> createState() =>
      _FreelancerContractsPageState();
}

class _FreelancerContractsPageState extends State<FreelancerContractsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<ContractBloc>().add(LoadFreelancerContracts(uid));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: const Text('My Contracts',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF5B67F1),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF5B67F1),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Disputed'),
          ],
        ),
      ),
      body: BlocConsumer<ContractBloc, ContractState>(
        listener: (context, state) {
          if (state is ContractActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF00BFA5),
              ),
            );
          }
          if (state is ContractFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ContractLoading || state is ContractInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final contracts =
              state is ContractsLoaded ? state.contracts : <ContractModel>[];

          final active =
              contracts.where((c) => c.status == 'active').toList();
          final completed =
              contracts.where((c) => c.status == 'completed').toList();
          final disputed =
              contracts.where((c) => c.status == 'disputed').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(active),
              _buildList(completed),
              _buildList(disputed),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<ContractModel> contracts) {
    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No contracts here.',
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contracts.length,
      itemBuilder: (context, index) =>
          FreelancerContractCard(contract: contracts[index]),
    );
  }
}

class FreelancerContractCard extends StatelessWidget {
  final ContractModel contract;

  const FreelancerContractCard({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd MMM yyyy').format(contract.startDate);
    final progress = contract.progressValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00BFA5).withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(
                  bottom: BorderSide(
                      color: const Color(0xFF00BFA5).withOpacity(0.2))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contract.projectTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.currency_rupee,
                              size: 14,
                              color: Color(0xFF00BFA5)),
                          Text(
                            '${contract.agreedAmount.toStringAsFixed(0)} agreed',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00BFA5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: contract.status == 'active'
                        ? const Color(0xFF00BFA5).withOpacity(0.15)
                        : contract.status == 'completed'
                            ? const Color(0xFF5B67F1).withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    contract.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: contract.status == 'active'
                          ? const Color(0xFF00BFA5)
                          : contract.status == 'completed'
                              ? const Color(0xFF5B67F1)
                              : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info chips
                Row(
                  children: [
                    _chip(Icons.schedule, contract.duration,
                        Colors.orange),
                    const SizedBox(width: 8),
                    _chip(Icons.calendar_today_outlined, formattedDate,
                        Colors.blue),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progress',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BFA5)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF00BFA5)),
                  ),
                ),

                const SizedBox(height: 16),

                // Milestones — freelancer can check them
                const Text('Milestones',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...contract.milestones.asMap().entries.map((entry) {
                  final i = entry.key;
                  final m = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: contract.status == 'active'
                              ? () {
                                  context.read<ContractBloc>().add(
                                        UpdateMilestoneRequested(
                                          contractId: contract.contractId,
                                          milestoneIndex: i,
                                          isCompleted: !m.isCompleted,
                                        ),
                                      );
                                }
                              : null,
                          child: Icon(
                            m.isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 22,
                            color: m.isCompleted
                                ? const Color(0xFF00BFA5)
                                : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            m.title,
                            style: TextStyle(
                              fontSize: 13,
                              color: m.isCompleted
                                  ? Colors.grey[500]
                                  : Colors.black87,
                              decoration: m.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        Text(
                          m.isCompleted ? '✓ Done' : 'Pending',
                          style: TextStyle(
                            fontSize: 11,
                            color: m.isCompleted
                                ? const Color(0xFF00BFA5)
                                : Colors.grey[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Payment status
                if (contract.paymentReleased)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: Color(0xFF00BFA5), size: 18),
                        SizedBox(width: 8),
                        Text('Payment Received!',
                            style: TextStyle(
                                color: Color(0xFF00BFA5),
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                  ),

                // Action buttons for active contracts
                if (contract.status == 'active' &&
                    !contract.paymentReleased)
                  Row(
                    children: [
                      if (!contract.workSubmitted)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Submit Work'),
                                  content: const Text(
                                      'Are you sure you want to submit your work to the client for review?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        context
                                            .read<ContractBloc>()
                                            .add(SubmitWorkRequested(
                                                contract.contractId));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF5B67F1),
                                      ),
                                      child: const Text('Submit',
                                          style: TextStyle(
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.upload_outlined,
                                size: 16),
                            label: const Text('Submit Work'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B67F1),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      if (contract.workSubmitted)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.hourglass_top,
                                    color: Colors.orange, size: 16),
                                SizedBox(width: 6),
                                Text('Awaiting Client Review',
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline,
                            size: 16),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF5B67F1),
                          side: const BorderSide(
                              color: Color(0xFF5B67F1)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}