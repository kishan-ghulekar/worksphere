// lib/View/FreelancerScreens/freelancerPaymentHistoryScreen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:super_project/View/PaymentScreen/PaymentScreen.dart';
import 'package:super_project/model/paymentModel.dart';
import 'package:super_project/repository/paymentRepository.dart';

class FreelancerPaymentHistoryScreen extends StatelessWidget {
  const FreelancerPaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Payment History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text('Please log in to view payments.'))
            : StreamBuilder<List<PaymentModel>>(
                stream: PaymentRepository().watchFreelancerPayments(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Could not load payment history.',
                        style: TextStyle(color: AppColors.pinkText),
                      ),
                    );
                  }
                  final payments = snapshot.data ?? [];
                  if (payments.isEmpty) {
                    return const Center(
                      child: Text(
                        'No payments yet.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  final total = payments
                      .where((p) => p.status == PaymentStatus.success)
                      .fold<double>(0, (sum, p) => sum + p.amount);

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Total received',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...payments
                          .map((p) => _FreelancerPaymentCard(payment: p)),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _FreelancerPaymentCard extends StatelessWidget {
  final PaymentModel payment;
  const _FreelancerPaymentCard({required this.payment});

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
              _chip(payment.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Client: ${payment.clientName ?? 'Client'}',
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

  Widget _chip(PaymentStatus status) {
    late String label;
    late Color bg;
    late Color fg;
    switch (status) {
      case PaymentStatus.success:
        label = 'Payment Received';
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