import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// ════════════════════════════════════════════════════════════════════════════
// bKASH PAYMENT CONTROLLER
//
// তোমার existing FeesController-এর সাথে কাজ করে — আলাদা controller রাখা
// হয়েছে কারণ payment logic complex এবং fees display logic-এর সাথে mix করা
// উচিত না।
//
// ⚠️ IMPORTANT: এই controller-এর _baseUrl সঠিক ERP backend-এর URL।
// bKash credentials (App Key, App Secret, Username, Password) কখনো এখানে
// রাখা হয়নি — সেগুলো শুধু backend server-এ থাকবে (security requirement)।
//
// Credentials পাওয়ার পর ERP team শুধু backend-এ এই ৩টা endpoint বানাবে,
// Flutter app-এর এখানে কোনো পরিবর্তন লাগবে না।
// ════════════════════════════════════════════════════════════════════════════

// ── Payment Status ─────────────────────────────────────────────────────────
enum BkashPaymentStatus {
  idle,
  initiating,   // backend-কে request পাঠানো হচ্ছে
  webViewOpen,  // bKash page open, customer enter করছে
  verifying,    // payment confirm হচ্ছে
  success,
  failed,
  cancelled,
}

// ── Payment Result Model ───────────────────────────────────────────────────
class BkashPaymentResult {
  final bool isSuccess;
  final String paymentId;
  final String trxId;       // bKash transaction ID (e.g. "8BG105MO")
  final double amount;
  final String message;
  final String? errorCode;

  const BkashPaymentResult({
    required this.isSuccess,
    required this.paymentId,
    required this.trxId,
    required this.amount,
    required this.message,
    this.errorCode,
  });
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ════════════════════════════════════════════════════════════════════════════
class BkashController extends GetxController {
  // ── API Config ─────────────────────────────────────────────────────────
  // Sandbox → Production switch: শুধু এই URL পরিবর্তন করলেই হবে।
  static const String _baseUrl =
      'https://averroesint.com/averroes_school_erp/api';

  // ERP team এই ৩টা endpoint বানাবে:
  static const String _initiateEndpoint = '/fees/initiate-payment';
  static const String _statusEndpoint   = '/fees/payment-status';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // ── State ───────────────────────────────────────────────────────────────
  var status = BkashPaymentStatus.idle.obs;
  var errorMessage = ''.obs;
  Rx<BkashPaymentResult?> lastResult = Rx<BkashPaymentResult?>(null);

  // এই data WebView page-এ পাঠানো হয়
  var currentBkashUrl = ''.obs;
  var currentPaymentId = ''.obs;
  var currentAmount = 0.0.obs;
  var currentInvoiceId = ''.obs;

  // ────────────────────────────────────────────────────────────────────────
  // STEP 1 — Payment Initiate করো
  // ────────────────────────────────────────────────────────────────────────
  //
  // ERP backend POST /fees/initiate-payment থেকে যা আসবে:
  // {
  //   "status": "success",
  //   "data": {
  //     "payment_id": "TR0011Ab9",
  //     "bkash_url": "https://securepay.sandbox.bka.sh/...",
  //     "amount": 4500,
  //     "invoice_id": "INV-2024-001"
  //   }
  // }
  Future<bool> initiatePayment({
    required String invoiceId,
    required double amount,
  }) async {
    try {
      status(BkashPaymentStatus.initiating);
      errorMessage('');
      currentInvoiceId(invoiceId);
      currentAmount(amount);

      final uri = Uri.parse('$_baseUrl$_initiateEndpoint');
      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode({
          'invoice_id': invoiceId,
          'amount': amount.toStringAsFixed(2),
          'currency': 'BDT',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final data = decoded['data'];
          currentBkashUrl(data['bkash_url']?.toString() ?? '');
          currentPaymentId(data['payment_id']?.toString() ?? '');

          if (currentBkashUrl.value.isEmpty) {
            errorMessage('bKash URL not received from server.');
            status(BkashPaymentStatus.failed);
            return false;
          }

          status(BkashPaymentStatus.webViewOpen);
          return true;
        } else {
          errorMessage(decoded['message']?.toString() ??
              'Payment initiation failed. Please try again.');
          status(BkashPaymentStatus.failed);
          return false;
        }
      } else if (response.statusCode == 401) {
        errorMessage('Session expired. Please log in again.');
        status(BkashPaymentStatus.failed);
        return false;
      } else {
        errorMessage('Server error (${response.statusCode}). Please try again.');
        status(BkashPaymentStatus.failed);
        return false;
      }
    } catch (e) {
      errorMessage('Could not connect to server. Please check your internet connection.');
      status(BkashPaymentStatus.failed);
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // STEP 2 — WebView callback handle করো
  // WebView-এ bKash redirect করলে এই method call হবে।
  // Success/Failure/Cancel — তিনটা case handle করা আছে।
  // ────────────────────────────────────────────────────────────────────────
  //
  // bKash সাধারণত এই URL pattern-এ redirect করে:
  //   Success:  https://averroesint.com/app/payment/success?paymentID=xxx
  //   Failed:   https://averroesint.com/app/payment/failed?paymentID=xxx
  //   Cancelled: https://averroesint.com/app/payment/cancel?paymentID=xxx
  //
  // ⚠️ Exact callback URL ERP team-এর সাথে confirm করতে হবে।
  bool shouldHandleUrl(String url) {
    return url.contains('/payment/success') ||
           url.contains('/payment/failed') ||
           url.contains('/payment/cancel') ||
           url.contains('paymentID=') && url.contains('status=');
  }

  void handleWebViewCallback(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final path = uri.path.toLowerCase();

    if (path.contains('cancel')) {
      _onCancelled();
    } else if (path.contains('failed')) {
      _onFailed(uri);
    } else if (path.contains('success')) {
      // bKash success redirect এলেই সরাসরি বিশ্বাস না করে backend থেকে verify করি
      verifyPaymentStatus();
    } else {
      // paymentID+status query param check
      final statusParam = uri.queryParameters['status']?.toLowerCase() ?? '';
      if (statusParam == 'success') {
        verifyPaymentStatus();
      } else if (statusParam == 'cancel') {
        _onCancelled();
      } else {
        _onFailed(uri);
      }
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // STEP 3 — Backend থেকে payment verify করো
  // ⚠️ SECURITY: WebView-এ "success" দেখালেই বিশ্বাস নয় — backend দিয়ে
  // independently verify করা MANDATORY। এটাই bKash-এর security requirement।
  // ────────────────────────────────────────────────────────────────────────
  //
  // ERP backend GET /fees/payment-status/{paymentID} থেকে যা আসবে:
  // {
  //   "status": "success",
  //   "data": {
  //     "transaction_status": "Completed",   ← এটাই real confirmation
  //     "trx_id": "8BG105MO3P",
  //     "amount": 4500,
  //     "payment_id": "TR0011Ab9"
  //   }
  // }
  Future<void> verifyPaymentStatus() async {
    try {
      status(BkashPaymentStatus.verifying);

      final paymentId = currentPaymentId.value;
      if (paymentId.isEmpty) {
        _onFailed(null);
        return;
      }

      final uri = Uri.parse('$_baseUrl$_statusEndpoint/$paymentId');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final data = decoded['data'];
          final txStatus = data['transaction_status']?.toString() ?? '';

          if (txStatus == 'Completed') {
            lastResult.value = BkashPaymentResult(
              isSuccess: true,
              paymentId: paymentId,
              trxId: data['trx_id']?.toString() ?? '',
              amount: double.tryParse(data['amount'].toString()) ??
                  currentAmount.value,
              message: 'Payment successful!',
            );
            status(BkashPaymentStatus.success);
          } else {
            lastResult.value = BkashPaymentResult(
              isSuccess: false,
              paymentId: paymentId,
              trxId: '',
              amount: currentAmount.value,
              message: 'Payment was not completed. Status: $txStatus',
            );
            status(BkashPaymentStatus.failed);
          }
        } else {
          _onFailed(null);
        }
      } else {
        _onFailed(null);
      }
    } catch (e) {
      errorMessage('Could not verify payment. Please check your payment history.');
      status(BkashPaymentStatus.failed);
    }
  }

  void _onCancelled() {
    lastResult.value = BkashPaymentResult(
      isSuccess: false,
      paymentId: currentPaymentId.value,
      trxId: '',
      amount: currentAmount.value,
      message: 'Payment was cancelled.',
    );
    status(BkashPaymentStatus.cancelled);
  }

  void _onFailed(Uri? uri) {
    final errorCode = uri?.queryParameters['errorCode'];
    lastResult.value = BkashPaymentResult(
      isSuccess: false,
      paymentId: currentPaymentId.value,
      trxId: '',
      amount: currentAmount.value,
      message: 'Payment failed. Please try again.',
      errorCode: errorCode,
    );
    status(BkashPaymentStatus.failed);
  }

  void reset() {
    status(BkashPaymentStatus.idle);
    errorMessage('');
    currentBkashUrl('');
    currentPaymentId('');
    currentAmount(0.0);
    currentInvoiceId('');
  }
}
