// lib/viewmodel/Bloc/paymentBloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:super_project/repository/paymentRepository.dart';
import 'package:super_project/services/RazorpayService.dart';
import 'package:super_project/viewmodel/Events/paymentEvent.dart';
import 'package:super_project/viewmodel/States/paymentState.dart';


class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository repository;
  late final RazorpayService _razorpayService;

  StreamSubscription? _contractSub;

  PaymentBloc({required this.repository}) : super(const PaymentState()) {
    _razorpayService = RazorpayService(
      onSuccess: (PaymentSuccessResponse r) => add(
        PaymentCheckoutSucceeded(
          razorpayOrderId: r.orderId ?? '',
          razorpayPaymentId: r.paymentId ?? '',
          razorpaySignature: r.signature ?? '',
        ),
      ),
      onError: (PaymentFailureResponse r) {
        // User closed the checkout sheet -> cancelled, not an error.
        if (r.code == Razorpay.PAYMENT_CANCELLED) {
          add(const PaymentCheckoutCancelled());
        } else {
          add(PaymentCheckoutFailed(r.message ?? 'Payment failed'));
        }
      },
      onExternalWallet: (_) {},
    );

    on<PaymentContractRequested>(_onContractRequested);
    on<PaymentContractUpdated>(_onContractUpdated);
    on<PaymentStarted>(_onPaymentStarted);
    on<PaymentCheckoutSucceeded>(_onCheckoutSucceeded);
    on<PaymentCheckoutFailed>(_onCheckoutFailed);
    on<PaymentCheckoutCancelled>(_onCheckoutCancelled);
  }

  Future<void> _onContractRequested(
    PaymentContractRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentUiStatus.loading));

    await _contractSub?.cancel();
    _contractSub =
        repository.watchContract(event.contractId).listen((contract) {
      add(PaymentContractUpdated(contract));
    });
  }

  void _onContractUpdated(
      PaymentContractUpdated event, Emitter<PaymentState> emit) {
    if (event.contract == null) {
      emit(state.copyWith(
          status: PaymentUiStatus.error, errorMessage: 'Contract not found.'));
      return;
    }
    // Don't override a mid-payment status because of an unrelated field change.
    if (state.isBusy) {
      emit(state.copyWith(contract: event.contract));
    } else {
      emit(state.copyWith(
          status: PaymentUiStatus.ready, contract: event.contract));
    }
  }

  Future<void> _onPaymentStarted(
      PaymentStarted event, Emitter<PaymentState> emit) async {
    if (!state.isPayable) return; // blocks duplicate payment client-side too

    emit(state.copyWith(
        status: PaymentUiStatus.processingOrder, errorMessage: null));
    try {
      // Backend creates the order using contracts/{id}.agreedAmount.
      final order = await repository.createOrder(event.contractId);
      final keyId = order['key'] as String;
      final orderId = order['orderId'] as String;
      final paymentDocId = order['paymentDocId'] as String;
      final amountInPaise = (order['amount'] as num).toInt();

      emit(state.copyWith(
          status: PaymentUiStatus.awaitingCheckout,
          paymentDocId: paymentDocId));

      _razorpayService.openCheckout(
        keyId: keyId,
        orderId: orderId,
        amountInPaise: amountInPaise,
        description: state.projectTitle,
        contactNumber: event.clientContact,
        email: event.clientEmail,
      );
    } catch (e) {
      emit(state.copyWith(
          status: PaymentUiStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCheckoutSucceeded(
    PaymentCheckoutSucceeded event,
    Emitter<PaymentState> emit,
  ) async {
    if (state.paymentDocId == null) return;
    emit(state.copyWith(status: PaymentUiStatus.verifying));
    try {
      // The payment only becomes "success" after the SERVER verifies this.
      await repository.verifyPayment(
        paymentDocId: state.paymentDocId!,
        razorpayOrderId: event.razorpayOrderId,
        razorpayPaymentId: event.razorpayPaymentId,
        razorpaySignature: event.razorpaySignature,
      );
      emit(state.copyWith(status: PaymentUiStatus.success));
      // The contract listener then pushes paymentStatus=success to the UI.
    } catch (e) {
      emit(state.copyWith(
          status: PaymentUiStatus.error, errorMessage: e.toString()));
    }
  }

  void _onCheckoutFailed(
      PaymentCheckoutFailed event, Emitter<PaymentState> emit) {
    emit(state.copyWith(
        status: PaymentUiStatus.error, errorMessage: event.message));
  }

  Future<void> _onCheckoutCancelled(
    PaymentCheckoutCancelled event,
    Emitter<PaymentState> emit,
  ) async {
    if (state.paymentDocId != null) {
      await repository.markCancelled(state.paymentDocId!);
    }
    emit(state.copyWith(status: PaymentUiStatus.ready));
  }

  @override
  Future<void> close() {
    _contractSub?.cancel();
    _razorpayService.dispose();
    return super.close();
  }
}