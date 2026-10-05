// lib/viewmodel/States/paymentStage.dart
import 'package:equatable/equatable.dart';

enum PaymentUiStatus {
  loading,
  ready,
  processingOrder,
  awaitingCheckout,
  verifying,
  success,
  error,
}

class PaymentState extends Equatable {
  final PaymentUiStatus status;
  final Map<String, dynamic>? contract; // contract doc for display
  final String? paymentDocId; // set once createOrder succeeds
  final String? errorMessage;

  const PaymentState({
    this.status = PaymentUiStatus.loading,
    this.contract,
    this.paymentDocId,
    this.errorMessage,
  });

  // Contract documents store the price as `agreedAmount`.
  double get amount =>
      ((contract?['agreedAmount'] ?? contract?['amount']) as num?)
          ?.toDouble() ??
      0;

  String get projectTitle =>
      contract?['projectTitle'] as String? ?? 'Untitled Project';

  String get freelancerName => contract?['freelancerName'] as String? ?? '—';

  String get milestoneTitle =>
      contract?['milestoneTitle'] as String? ?? 'Full Payment';

  String get contractStatus => contract?['status'] as String? ?? 'pending';

  String get paymentStatus =>
      contract?['paymentStatus'] as String? ?? 'pending';

  // Pay Now only after the project is completed and not yet paid.
  bool get isPayable =>
      contractStatus == 'completed' &&
      paymentStatus != 'success' &&
      paymentStatus != 'processing';

  bool get isBusy => [
        PaymentUiStatus.processingOrder,
        PaymentUiStatus.awaitingCheckout,
        PaymentUiStatus.verifying,
      ].contains(status);

  PaymentState copyWith({
    PaymentUiStatus? status,
    Map<String, dynamic>? contract,
    String? paymentDocId,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      contract: contract ?? this.contract,
      paymentDocId: paymentDocId ?? this.paymentDocId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, contract, paymentDocId, errorMessage];
}