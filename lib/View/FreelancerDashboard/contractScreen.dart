// lib/View/FreelancerDashboard/FreelancerContractsPage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:super_project/View/ClientScreens/contractorStatusHelper.dart';
import 'package:super_project/View/chats/charRoomScreen.dart';
import 'package:super_project/model/contractModel.dart';
import 'package:super_project/repository/chatRepository.dart';
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
    _tabController = TabController(length: 4, vsync: this);
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
          isScrollable: true,
          tabs: ContractStatus.values
              .map((s) => Tab(
                    child: Row(
                      children: [
                        Icon(ContractStatusHelper.icon(s), size: 14),
                        const SizedBox(width: 4),
                        Text(ContractStatusHelper.label(s)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      body: BlocConsumer<ContractBloc, ContractState>(
        listener: (context, state) {
          if (state is ContractActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF00BFA5),
            ));
          }
          if (state is ContractFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ContractLoading || state is ContractInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = state is ContractsLoaded
              ? state.contracts
              : <ContractModel>[];

          return Column(
            children: [
              // Summary
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: ContractStatus.values.map((s) {
                    final count =
                        all.where((c) => c.status == s).length;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            right: s != ContractStatus.cancelled
                                ? 8
                                : 0),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: ContractStatusHelper.color(s)
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text('$count',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        ContractStatusHelper.color(s))),
                            Text(ContractStatusHelper.label(s),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: ContractStatus.values.map((status) {
                    final filtered =
                        all.where((c) => c.status == status).toList();
                    return _buildList(filtered, status);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(
      List<ContractModel> contracts, ContractStatus status) {
    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ContractStatusHelper.icon(status),
                size: 64,
                color: ContractStatusHelper.color(status)
                    .withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No ${ContractStatusHelper.label(status)} contracts.',
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contracts.length,
      itemBuilder: (context, index) => FreelancerContractCard(
        contract: contracts[index],
        onSubmitWork: () {
          context.read<ContractBloc>().add(
              SubmitWorkRequested(contracts[index].contractId));
        },
        onMilestoneToggle: (i, val) {
          context.read<ContractBloc>().add(UpdateMilestoneRequested(
                contractId: contracts[index].contractId,
                milestoneIndex: i,
                isCompleted: val,
              ));
        },
      ),
    );
  }
}

class FreelancerContractCard extends StatelessWidget {
  final ContractModel contract;
  final VoidCallback onSubmitWork;
  final void Function(int, bool) onMilestoneToggle;

  const FreelancerContractCard({
    super.key,
    required this.contract,
    required this.onSubmitWork,
    required this.onMilestoneToggle,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = ContractStatusHelper.color(contract.status);
    final formattedDate =
        DateFormat('dd MMM yyyy').format(contract.startDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + badge
            Row(
              children: [
                Expanded(
                  child: Text(contract.projectTitle,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                ContractStatusHelper.badge(contract.status),
              ],
            ),

            const SizedBox(height: 8),

            Text('Client: ${contract.clientName}',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.currency_rupee,
                    size: 13, color: Colors.grey[600]),
                Text(
                  '${contract.agreedAmount.toStringAsFixed(0)}  •  $formattedDate',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            // Milestones only for active
            if (contract.status == ContractStatus.active) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Milestones',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    '${(contract.progressValue * 100).toInt()}%',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: contract.progressValue,
                  minHeight: 5,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 10),
              ...contract.milestones.asMap().entries.map((entry) {
                final i = entry.key;
                final m = entry.value;
                return GestureDetector(
                  onTap: () => onMilestoneToggle(i, !m.isCompleted),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          m.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 20,
                          color: m.isCompleted
                              ? const Color(0xFF00BFA5)
                              : Colors.grey[400],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(m.title,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: m.isCompleted
                                      ? Colors.grey[500]
                                      : Colors.black87,
                                  decoration: m.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null)),
                        ),
                        Text(
                          m.isCompleted ? '✓ Done' : 'Pending',
                          style: TextStyle(
                              fontSize: 11,
                              color: m.isCompleted
                                  ? const Color(0xFF00BFA5)
                                  : Colors.grey[400],
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 14),

            // Actions by status
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (contract.status) {
      case ContractStatus.pending:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top, color: Colors.orange, size: 16),
              SizedBox(width: 8),
              Text('Waiting for Client Approval',
                  style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        );

      case ContractStatus.active:
        return Row(
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
                            'Submit your work for client review?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onSubmitWork();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF5B67F1)),
                            child: const Text('Submit',
                                style:
                                    TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_outlined, size: 16),
                  label: const Text('Submit Work'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B67F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
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
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () async {
  final chatId = await ChatRepository().getOrCreateChat(
    projectId: contract.projectId,
    projectTitle: contract.projectTitle,
    clientId: contract.clientId,
    freelancerId: contract.freelancerId,
  );
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => ChatRoomScreen(
      chatId: chatId,
      currentUserId: FirebaseAuth.instance.currentUser!.uid,
      isClient: false,
      receiverId: contract.clientId,
      projectTitle: contract.projectTitle,
    ),
  ));
},
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5B67F1),
                side: const BorderSide(color: Color(0xFF5B67F1)),
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );

      case ContractStatus.completed:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.payments_outlined, size: 16),
                label: const Text('View Payment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00BFA5),
                  side:
                      const BorderSide(color: Color(0xFF00BFA5)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.star_outline, size: 16),
                label: const Text('View Review'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber[700],
                  side: BorderSide(color: Colors.amber[700]!),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        );

      case ContractStatus.cancelled:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: const Text('View Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey,
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        );
    }
  }
}