// lib/repository/paymentRepository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:super_project/model/paymentModel.dart';

/// All Firestore reads + Cloud Function calls for payments live here.
/// The Bloc depends on this, never on Firestore/Functions directly.
class PaymentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  PaymentRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  /// Live contract doc: amount/title/status shown on PaymentScreen.
  Stream<Map<String, dynamic>?> watchContract(String contractId) {
    return _firestore
        .collection('contracts')
        .doc(contractId)
        .snapshots()
        .map((snap) => snap.data());
  }

  /// Step 1: ask the server to create a Razorpay order (server reads amount).
  Future<Map<String, dynamic>> createOrder(String contractId) async {
    try {
      final callable = _functions.httpsCallable('createOrder');
      final result =
          await callable.call<Map<String, dynamic>>({'contractId': contractId});
      return Map<String, dynamic>.from(result.data as Map);
    } on FirebaseFunctionsException catch (e) {
      throw PaymentException(_friendlyMessage(e));
    }
  }

  /// Step 2: send Razorpay's result to the server for signature verification.
  /// This is the ONLY app-triggered step that can mark a payment "success".
  Future<void> verifyPayment({
    required String paymentDocId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final callable = _functions.httpsCallable('verifyPayment');
      await callable.call<Map<String, dynamic>>({
        'paymentDocId': paymentDocId,
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      });
    } on FirebaseFunctionsException catch (e) {
      throw PaymentException(_friendlyMessage(e));
    }
  }

  Future<void> markCancelled(String paymentDocId) async {
    try {
      final callable = _functions.httpsCallable('markPaymentCancelled');
      await callable
          .call<Map<String, dynamic>>({'paymentDocId': paymentDocId});
    } on FirebaseFunctionsException {
      // Non-critical: next Pay Now reuses the same payment document.
    }
  }

  /// Completed contracts of this client that are not paid yet.
  /// Two equality filters only -> no composite index needed.
  Stream<List<Map<String, dynamic>>> watchClientPendingContracts(
      String clientId) {
    return _firestore
        .collection('contracts')
        .where('clientId', isEqualTo: clientId)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {...d.data(), 'contractId': d.id})
            .where((c) =>
                (c['paymentStatus'] as String? ?? 'pending') != 'success')
            .toList());
  }

  /// Client's payment history, own uid only.
  /// Index: payments (clientId ASC, createdAt DESC)
  Stream<List<PaymentModel>> watchClientPayments(String clientId) {
    return _firestore
        .collection('payments')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PaymentModel.fromMap(d.id, d.data())).toList());
  }

  /// Freelancer's payment history, own uid only.
  /// Index: payments (freelancerId ASC, createdAt DESC)
  Stream<List<PaymentModel>> watchFreelancerPayments(String freelancerId) {
    return _firestore
        .collection('payments')
        .where('freelancerId', isEqualTo: freelancerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PaymentModel.fromMap(d.id, d.data())).toList());
  }

  String _friendlyMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Please log in again to continue.';
      case 'permission-denied':
        return 'You are not authorized to make this payment.';
      case 'failed-precondition':
        return 'Please complete the project before paying.';
      case 'already-exists':
        return 'This contract has already been paid.';
      case 'not-found':
        return 'Contract not found.';
      case 'invalid-argument':
        return 'Invalid payment details.';
      case 'aborted':
        return 'Payment verification failed. If money was deducted, please contact support.';
      default:
        return 'Something went wrong while processing payment. Please try again.';
    }
  }
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);
  @override
  String toString() => message;
}