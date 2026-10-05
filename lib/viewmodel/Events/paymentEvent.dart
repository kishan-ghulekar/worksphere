import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object?> get props => [];
}

/// Fired when PaymentScreen opens — starts listening to the contract doc.
class PaymentContractRequested extends PaymentEvent {
  final String contractId;
  const PaymentContractRequested(this.contractId);
  @override
  List<Object?> get props => [contractId];
}

/// Internal: contract stream emitted a new value.
class PaymentContractUpdated extends PaymentEvent {
  final Map<String, dynamic>? contract;
  const PaymentContractUpdated(this.contract);
  @override
  List<Object?> get props => [contract];
}

/// "Pay Now" tapped.
class PaymentStarted extends PaymentEvent {
  final String contractId;
  final String? clientContact;
  final String? clientEmail;
  const PaymentStarted(this.contractId, {this.clientContact, this.clientEmail});
  @override
  List<Object?> get props => [contractId, clientContact, clientEmail];
}

/// Razorpay checkout returned success.
class PaymentCheckoutSucceeded extends PaymentEvent {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  const PaymentCheckoutSucceeded({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });
  @override
  List<Object?> get props => [razorpayOrderId, razorpayPaymentId, razorpaySignature];
}

/// Razorpay checkout returned an error.
class PaymentCheckoutFailed extends PaymentEvent {
  final String message;
  const PaymentCheckoutFailed(this.message);
  @override
  List<Object?> get props => [message];
}

/// User closed the checkout sheet without paying.
class PaymentCheckoutCancelled extends PaymentEvent {
  const PaymentCheckoutCancelled();
}