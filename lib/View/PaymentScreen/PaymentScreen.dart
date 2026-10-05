// lib/View/ClientScreens/paymentScreen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:super_project/model/paymentModel.dart';
import 'package:super_project/repository/paymentRepository.dart';
import 'package:super_project/viewmodel/Bloc/paymentBloc.dart';
import 'package:super_project/viewmodel/Events/paymentEvent.dart';
import 'package:super_project/viewmodel/States/paymentState.dart';

/// Matches WorkSphere's existing visual language.
class AppColors {
  static const primary = Color(0xFF5B5FEF);
  static const background = Color(0xFFF5F6FA);
  static const cardGrey = Color(0xFFF1F1F5);
  static const successBg = Color(0xFFE3F8EF);
  static const successText = Color(0xFF12B76A);
  static const pinkBg = Color(0xFFFCE9EC);
  static const pinkText = Color(0xFFE53E6D);
  static const amberBg = Color(0xFFFFF4E0);
  static const amberText = Color(0xFFB98900);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF8A8A9E);
}

/// Two ways to open this screen:
///
///   const PaymentScreen()
///     -> "Payments" bottom-nav tab: pending payments + payment history.
///
///   PaymentScreen(contractId: ..., clientContact: ..., clientEmail: ...)
///     -> shows project/freelancer/amount and the Pay Now button.
class PaymentScreen extends StatelessWidget {
  final String? contractId;
  final String? clientContact;
  final String? clientEmail;

  const PaymentScreen({
    super.key,
    this.contractId,
    this.clientContact,
    this.clientEmail,
  });

  @override
  Widget build(BuildContext context) {
    if (contractId == null) {
      return _PaymentHubView(
        clientContact: clientContact,
        clientEmail: clientEmail,
      );
    }

    return BlocProvider(
      create: (_) => PaymentBloc(repository: PaymentRepository())
        ..add(PaymentContractRequested(contractId!)),
      child: _PaymentDetailView(
        contractId: contractId!,
        clientContact: clientContact,
        clientEmail: clientEmail,
      ),
    );
  }
}

// =====================================================================
// HUB VIEW (contractId == null)
// =====================================================================

class _PaymentHubView extends StatelessWidget {
  final String? clientContact;
  final String? clientEmail;

  const _PaymentHubView({this.clientContact, this.clientEmail});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final repository = PaymentRepository();

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Please log in to view payments.')),
      );
    }
    final clientId = user.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Payments',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Pending Payments',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: repository.watchClientPendingContracts(clientId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }
                final pending = snapshot.data ?? [];
                if (pending.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No pending payments.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return Column(
                  children: pending
                      .map(
                        (c) => _PendingContractCard(
                          contract: c,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                contractId: c['contractId'] as String,
                                clientContact: clientContact,
                                clientEmail: clientEmail,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 28),
            const Text(
              'Payment History',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<PaymentModel>>(
              stream: repository.watchClientPayments(clientId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Could not load payment history.',
                      style: TextStyle(color: AppColors.pinkText),
                    ),
                  );
                }
                final history = snapshot.data ?? [];
                if (history.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No payments yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return Column(
                  children:
                      history.map((p) => _HistoryCard(payment: p)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingContractCard extends StatelessWidget {
  final Map<String, dynamic> contract;
  final VoidCallback onTap;
  const _PendingContractCard({required this.contract, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final amount =
        ((contract['agreedAmount'] ?? contract['amount']) as num?)
                ?.toDouble() ??
            0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (contract['projectTitle'] as String?) ?? 'Project',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (contract['freelancerName'] as String?) ??
                            'Freelancer',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final PaymentModel payment;
  const _HistoryCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final when = payment.paidAt ?? payment.createdAt;
    final date = when == null ? '—' : DateFormat('dd MMM yyyy').format(when);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  payment.projectTitle ?? 'Project',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(payment.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Freelancer: ${payment.freelancerName ?? 'Freelancer'}',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '₹${payment.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(PaymentStatus status) {
    late String label;
    late Color bg;
    late Color fg;
    switch (status) {
      case PaymentStatus.success:
        label = 'Payment Successful';
        bg = AppColors.successBg;
        fg = AppColors.successText;
        break;
      case PaymentStatus.processing:
        label = 'Processing';
        bg = AppColors.amberBg;
        fg = AppColors.amberText;
        break;
      case PaymentStatus.failed:
        label = 'Payment Failed';
        bg = AppColors.pinkBg;
        fg = AppColors.pinkText;
        break;
      case PaymentStatus.cancelled:
        label = 'Payment Cancelled';
        bg = AppColors.cardGrey;
        fg = AppColors.textSecondary;
        break;
      case PaymentStatus.pending:
        label = 'Payment Pending';
        bg = AppColors.cardGrey;
        fg = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// =====================================================================
// DETAIL VIEW (contractId != null): project, freelancer, amount, Pay Now
// =====================================================================

class _PaymentDetailView extends StatelessWidget {
  final String contractId;
  final String? clientContact;
  final String? clientEmail;

  const _PaymentDetailView({
    required this.contractId,
    this.clientContact,
    this.clientEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state.status == PaymentUiStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.pinkText,
                ),
              );
            }
            if (state.status == PaymentUiStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment successful!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == PaymentUiStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state.contract == null) {
              return const Center(child: Text('Unable to load contract.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailCard(state),
                  const SizedBox(height: 24),
                  _amountCard(state),
                  const SizedBox(height: 28),
                  _payButton(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _detailCard(PaymentState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Project', state.projectTitle),
          const SizedBox(height: 14),
          _kv('Freelancer', state.freelancerName),
          const SizedBox(height: 14),
          _kv('Milestone', state.milestoneTitle),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Status',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const Spacer(),
              _statusChip(state.paymentStatus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    late String label;
    late Color bg;
    late Color fg;
    switch (status) {
      case 'success':
        label = 'Paid';
        bg = AppColors.successBg;
        fg = AppColors.successText;
        break;
      case 'processing':
        label = 'Processing';
        bg = AppColors.amberBg;
        fg = AppColors.amberText;
        break;
      case 'failed':
        label = 'Failed';
        bg = AppColors.pinkBg;
        fg = AppColors.pinkText;
        break;
      case 'cancelled':
        label = 'Cancelled';
        bg = AppColors.cardGrey;
        fg = AppColors.textSecondary;
        break;
      default:
        label = 'Pending';
        bg = AppColors.cardGrey;
        fg = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _amountCard(PaymentState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            'Amount',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${state.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _payButton(BuildContext context, PaymentState state) {
    final bloc = context.read<PaymentBloc>();
    final canPay = state.isPayable && !state.isBusy;

    String label;
    if (state.paymentStatus == 'success') {
      label = 'Payment Complete ✓';
    } else if (state.isBusy) {
      label = 'Processing…';
    } else if (state.contractStatus != 'completed') {
      label = 'Project not completed yet';
    } else {
      label = 'Pay Now';
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canPay
            ? () => bloc.add(
                  PaymentStarted(
                    contractId,
                    clientContact: clientContact,
                    clientEmail: clientEmail,
                  ),
                )
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPay ? AppColors.primary : AppColors.cardGrey,
          foregroundColor: canPay ? Colors.white : AppColors.textSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: state.isBusy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}