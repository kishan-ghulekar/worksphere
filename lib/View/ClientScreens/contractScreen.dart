// lib/View/ClientScreens/ClientContractsPage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:super_project/View/ClientScreens/contractorStatusHelper.dart';
import 'package:super_project/View/PaymentScreen/PaymentScreen.dart';
import 'package:super_project/model/contractModel.dart';
import 'package:super_project/viewmodel/Bloc/contractBloc.dart';
import 'package:super_project/viewmodel/Events/contractEvents.dart';
import 'package:super_project/viewmodel/States/contractStates.dart';

/// Opens the existing PaymentScreen. Used after "Complete" and by "Pay Now".
void _openPaymentScreen(BuildContext context, String contractId) {
  final user = FirebaseAuth.instance.currentUser;
  final contact = user?.phoneNumber;
  final email = user?.email;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PaymentScreen(
        contractId: contractId,
        clientContact: (contact == null || contact.isEmpty) ? null : contact,
        clientEmail: (email == null || email.isEmpty) ? null : email,
      ),
    ),
  );
}

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
    _tabController = TabController(length: 4, vsync: this);
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
          isScrollable: true,
          tabs: [
            ContractStatus.pending,
            ContractStatus.active,
            ContractStatus.completed,
            ContractStatus.cancelled,
          ].map((s) => Tab(
                child: Row(
                  children: [
                    Icon(ContractStatusHelper.icon(s), size: 14),
                    const SizedBox(width: 4),
                    Text(ContractStatusHelper.label(s)),
                  ],
                ),
              )).toList(),
        ),
      ),
      body: BlocConsumer<ContractBloc, ContractState>(
        listener: (context, state) {
          if (state is ContractActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF00BFA5),
            ));

            // Contract just became COMPLETED -> show the payment details
            // screen. Razorpay does NOT open here; the user taps "Pay Now".
            final completedId = state.completedContractId;
            if (completedId != null) {
              _openPaymentScreen(context, completedId);
            }
          }
          if (state is ContractFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)));
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
              // Summary cards
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: ContractStatus.values.map((s) {
                    final count = all.where((c) => c.status == s).length;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            right: s != ContractStatus.cancelled ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: ContractStatusHelper.color(s)
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ContractStatusHelper.color(s),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ContractStatusHelper.label(s),
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[600]),
                            ),
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

  Widget _buildList(List<ContractModel> contracts, ContractStatus status) {
    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ContractStatusHelper.icon(status),
                size: 64,
                color: ContractStatusHelper.color(status).withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No ${ContractStatusHelper.label(status)} contracts.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contracts.length,
      itemBuilder: (context, index) => ClientContractCard(
        contract: contracts[index],
        onTransition: (newStatus) {
          context.read<ContractBloc>().add(TransitionContractStatus(
                contractId: contracts[index].contractId,
                currentStatus: contracts[index].status,
                newStatus: newStatus,
              ));
        },
        onSubmitWork: () {},
        onReleasePayment: () {
          context.read<ContractBloc>().add(
              ReleasePaymentRequested(contracts[index].contractId));
        },
      ),
    );
  }
}

class ClientContractCard extends StatelessWidget {
  final ContractModel contract;
  final void Function(ContractStatus) onTransition;
  final VoidCallback onSubmitWork;
  final VoidCallback onReleasePayment;

  const ClientContractCard({
    super.key,
    required this.contract,
    required this.onTransition,
    required this.onSubmitWork,
    required this.onReleasePayment,
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
            // Title + Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    contract.projectTitle,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                ContractStatusHelper.badge(contract.status),
              ],
            ),

            const SizedBox(height: 8),

            // Freelancer + amount + date
            Text('Freelancer: ${contract.freelancerName}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.currency_rupee, size: 13, color: Colors.grey[600]),
                Text(
                  '${contract.agreedAmount.toStringAsFixed(0)}  •  $formattedDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            // Progress bar for active
            if (contract.status == ContractStatus.active) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text(
                    '${(contract.progressValue * 100).toInt()}%',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: contract.progressValue,
                  minHeight: 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons based on status
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (contract.status) {
      case ContractStatus.pending:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _confirmTransition(
                  context,
                  ContractStatus.active,
                  'Activate Contract',
                  'Start this contract with ${contract.freelancerName}?',
                ),
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Activate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmTransition(
                  context,
                  ContractStatus.cancelled,
                  'Cancel Contract',
                  'Are you sure you want to cancel this contract?',
                ),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        );

      case ContractStatus.active:
        return Column(
          children: [
            if (contract.workSubmitted && !contract.paymentReleased)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Text(
                  '⚠️ Freelancer submitted work. Review and complete.',
                  style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmTransition(
                      context,
                      ContractStatus.completed,
                      'Mark as Completed',
                      'Mark this project as completed and continue to payment for ${contract.freelancerName}?',
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Complete'),
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
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => _confirmTransition(
                    context,
                    ContractStatus.cancelled,
                    'Cancel Contract',
                    'Cancel this active contract?',
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        );

      case ContractStatus.completed:
        return Column(
          children: [
            // Payment status line
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: contract.isPaid ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: contract.isPaid
                        ? Colors.green[200]!
                        : Colors.orange[200]!),
              ),
              child: Text(
                contract.isPaid
                    ? 'Payment Status: Paid ✔'
                    : 'Payment Status: Pending',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: contract.isPaid
                        ? Colors.green[800]
                        : Colors.orange[800]),
              ),
            ),

            // Pay Now: completed but not yet paid
            if (!contract.isPaid)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _openPaymentScreen(context, contract.contractId),
                  icon: const Icon(Icons.payment, size: 16),
                  label: const Text('Pay Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),

            // Existing buttons, unchanged
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5B67F1),
                      side: const BorderSide(color: Color(0xFF5B67F1)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.star_outline, size: 16),
                    label: const Text('Leave Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
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

  void _confirmTransition(
    BuildContext context,
    ContractStatus newStatus,
    String title,
    String message,
  ) {
    final color = ContractStatusHelper.color(newStatus);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(ContractStatusHelper.icon(newStatus), color: color),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.grey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onTransition(newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(ContractStatusHelper.label(newStatus),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}