

import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Thin wrapper around the Razorpay SDK so the Bloc / UI never touch
/// razorpay_flutter directly. Holds no business logic and no secrets —
/// key_id (public) is passed in per-checkout from the Cloud Function response.
class RazorpayService {
  late final Razorpay _razorpay;

  RazorpayService({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
    required void Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  /// [amountInPaise] and [orderId] MUST come from the createOrder Cloud
  /// Function response — never compute/hardcode them client-side.
  void openCheckout({
    required String keyId,
    required String orderId,
    required int amountInPaise,
    required String description,
    String? contactNumber,
    String? email,
  }) {
    final options = {
      'key': keyId,
      'amount': amountInPaise,
      'order_id': orderId,
      'name': 'WorkSphere',
      'description': description,
      'prefill': {
        'contact': contactNumber ?? '',
        'email': email ?? '',
      },
      'theme': {'color': '#5B5FEF'},
    };
    _razorpay.open(options);
  }

  void dispose() => _razorpay.clear();
}