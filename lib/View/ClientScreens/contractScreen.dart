import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:super_project/model/contractModel.dart';
import 'package:super_project/viewmodel/Bloc/contractBloc.dart';
import 'package:super_project/viewmodel/Events/contractEvents.dart';
import 'package:super_project/viewmodel/States/contractStates.dart';

class ClientContractsPage extends StatefulWidget {
  const ClientContractsPage({super.key});

  @override
  State<ClientContractsPage> createState() => _ClientContractsPageState();
}

class _ClientContractsPageState extends State<ClientContractsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<ContractBloc>().add(LoadClientContracts(uid));
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
        title: const Text('Contracts',
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
              _buildList(active, isClient: true),
              _buildList(completed, isClient: true),
              _buildList(disputed, isClient: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<ContractModel> contracts,
      {required bool isClient}) {
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
      itemBuilder: (context, index) => ClientContractCard(
        contract: contracts[index],
      ),
    );
  }
}

class ClientContractCard extends StatelessWidget {
  final ContractModel contract;

  const ClientContractCard({super.key, required this.contract});

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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B67F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(14)),
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
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Freelancer: ${contract.freelancerName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    contract.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                // Amount + Date + Duration
                Row(
                  children: [
                    _chip(Icons.currency_rupee,
                        '₹${contract.agreedAmount.toStringAsFixed(0)}',
                        const Color(0xFF00BFA5)),
                    const SizedBox(width: 8),
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
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B67F1)),
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
                        Color(0xFF5B67F1)),
                  ),
                ),

                const SizedBox(height: 16),

                // Milestones
                const Text('Milestones',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...contract.milestones.asMap().entries.map((entry) {
                  final m = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          m.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: m.isCompleted
                              ? const Color(0xFF00BFA5)
                              : Colors.grey[400],
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

                // Work submitted badge
                if (contract.workSubmitted && !contract.paymentReleased)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange[700], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Freelancer has submitted work. Review and release payment.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.orange[800]),
                        ),
                      ],
                    ),
                  ),

                // Action buttons
                if (contract.status == 'active')
                  Row(
                    children: [
                      if (contract.workSubmitted &&
                          !contract.paymentReleased)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Release Payment'),
                                  content: Text(
                                    'Release ₹${contract.agreedAmount.toStringAsFixed(0)} to ${contract.freelancerName}?',
                                  ),
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
                                            .add(ReleasePaymentRequested(
                                                contract.contractId));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF00BFA5),
                                      ),
                                      child: const Text('Release',
                                          style: TextStyle(
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.payment, size: 16),
                            label: const Text('Release Payment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00BFA5),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      if (!contract.workSubmitted) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.read<ContractBloc>().add(
                                    RaiseDisputeRequested(
                                        contract.contractId),
                                  );
                            },
                            icon: const Icon(Icons.warning_amber_outlined,
                                size: 16),
                            label: const Text('Raise Issue'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.chat_bubble_outline,
                                size: 16),
                            label: const Text('Message'),
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
                      ],
                    ],
                  ),

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
                        Text('Payment Released — Project Completed',
                            style: TextStyle(
                                color: Color(0xFF00BFA5),
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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