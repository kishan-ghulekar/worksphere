// lib/model/paymentModel.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { pending, processing, success, failed, cancelled }

PaymentStatus paymentStatusFromString(String? s) {
  switch (s) {
    case 'processing':
      return PaymentStatus.processing;
    case 'success':
      return PaymentStatus.success;
    case 'failed':
      return PaymentStatus.failed;
    case 'cancelled':
      return PaymentStatus.cancelled;
    case 'pending':
    default:
      return PaymentStatus.pending;
  }
}

String paymentStatusToString(PaymentStatus s) => s.name;

DateTime? _toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

/// Mirrors payments/{paymentId} in Firestore (one doc per contract).
class PaymentModel {
  final String paymentId;
  final String contractId;
  final String? projectId;
  final String clientId;
  final String freelancerId;
  final double amount; // rupees
  final String currency;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final PaymentStatus status;
  final DateTime? createdAt;
  final DateTime? paidAt;

  // Denormalized display fields written by the backend.
  final String? projectTitle;
  final String? clientName;
  final String? freelancerName;
  final String? milestoneTitle;

  const PaymentModel({
    required this.paymentId,
    required this.contractId,
    this.projectId,
    required this.clientId,
    required this.freelancerId,
    required this.amount,
    this.currency = 'INR',
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.status = PaymentStatus.pending,
    this.createdAt,
    this.paidAt,
    this.projectTitle,
    this.clientName,
    this.freelancerName,
    this.milestoneTitle,
  });

  factory PaymentModel.fromMap(String id, Map<String, dynamic> map) {
    return PaymentModel(
      paymentId: id,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      contractId: map['contractId'] as String? ?? '',
      clientId: map['clientId'] as String? ?? '',
      freelancerId: map['freelancerId'] as String? ?? '',
      projectId: map['projectId'] as String?,
      razorpayOrderId: map['razorpayOrderId'] as String?,
      razorpayPaymentId: map['razorpayPaymentId'] as String?,
      currency: map['currency'] as String? ?? 'INR',
      status: paymentStatusFromString(map['status'] as String?),
      createdAt: _toDate(map['createdAt']),
      paidAt: _toDate(map['paidAt']),
      projectTitle: map['projectTitle'] as String?,
      clientName: map['clientName'] as String?,
      freelancerName: map['freelancerName'] as String?,
      milestoneTitle: map['milestoneTitle'] as String?,
    );
  }
}