import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import '../../wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'fees_controller.dart';

class BkashPaymentPage extends StatefulWidget {
  final String bkashUrl;
  final String paymentId;
  final String invoiceId;
  final double amount;
  final FeesController feesCtrl;

  const BkashPaymentPage({
    Key? key,
    required this.bkashUrl,
    required this.paymentId,
    required this.invoiceId,
    required this.amount,
    required this.feesCtrl,
  }) : super(key: key);

  @override
  State<BkashPaymentPage> createState() => _BkashPaymentPageState();
}

class _BkashPaymentPageState extends State<BkashPaymentPage> {
  late final WebViewController _controller;

  static const String _successPattern  = '/payment/success';
  static const String _failurePattern  = '/payment/failure';
  static const String _cancelPattern   = '/payment/cancel';

  bool _isLoading   = true;
  bool _isDone      = false;
  String _status    = '';
  String _message   = '';
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
            _checkCallbackUrl(url);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            _checkCallbackUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.bkashUrl));
  }

  void _checkCallbackUrl(String url) {
    if (_isDone) return;

    if (url.contains(_successPattern)) {
      setState(() => _isDone = true);
      _verifyPayment();
    } else if (url.contains(_failurePattern)) {
      setState(() {
        _isDone   = true;
        _status   = 'failure';
        _message  = 'Payment failed. Please try again.';
      });
    } else if (url.contains(_cancelPattern)) {
      setState(() {
        _isDone  = true;
        _status  = 'cancelled';
        _message = 'Payment was cancelled.';
      });
    }
  }

  Future<void> _verifyPayment() async {
    setState(() => _isVerifying = true);

    try {
      final verified = await widget.feesCtrl.verifyPayment(widget.paymentId);
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _status      = verified ? 'success' : 'failure';
          _message     = verified
              ? 'Payment of ৳${widget.amount.toStringAsFixed(0)} successful!'
              : 'Payment could not be verified. Please contact school office.';
        });

        if (verified) {
          widget.feesCtrl.refreshFees();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _status  = 'failure';
          _message = 'Verification error. Please contact school office.';
        });
      }
    }
  }

  Future<bool> _showCancelDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancel Payment?', style: sansproSemibold.copyWith(fontSize: 17)),
        content: Text(
          'Going back will cancel your payment process. Are you sure?',
          style: sansproRegular.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay', style: TextStyle(color: WireframeColor.appcolor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: WireframeColor.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel Payment', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope পরিবর্তন করে আধুনিক PopScope ব্যবহার করা হলো
    return PopScope(
      canPop: _isDone,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showCancelDialog();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE2136E),
          foregroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'bKash',
                  style: sansproBold.copyWith(
                    fontSize: 16,
                    color: const Color(0xFFE2136E),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Secure Payment',
                style: sansproRegular.copyWith(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.lock_outline, color: Colors.white, size: 20),
            ),
          ],
        ),
        body: _isDone
            ? _buildResultScreen()
            : Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFE2136E)),
                      SizedBox(height: 16),
                      Text('Loading bKash secure page...', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    if (_isVerifying) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFE2136E)),
            SizedBox(height: 20),
            Text('Verifying payment...', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    final isSuccess = _status == 'success';
    final isCancelled = _status == 'cancelled';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess
                    ? WireframeColor.green.withAlpha(25)
                    : isCancelled
                    ? WireframeColor.textgray.withAlpha(25)
                    : WireframeColor.red.withAlpha(25),
              ),
              child: Icon(
                isSuccess
                    ? Icons.check_circle_outline
                    : isCancelled
                    ? Icons.cancel_outlined
                    : Icons.error_outline,
                size: 52,
                color: isSuccess
                    ? WireframeColor.green
                    : isCancelled
                    ? WireframeColor.textgray
                    : WireframeColor.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSuccess
                  ? 'Payment Successful!'
                  : isCancelled
                  ? 'Payment Cancelled'
                  : 'Payment Failed',
              style: sansproBold.copyWith(
                fontSize: 22,
                color: isSuccess
                    ? WireframeColor.green
                    : isCancelled
                    ? WireframeColor.textgray
                    : WireframeColor.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.textgray),
            ),
            if (isSuccess) ...[
              const SizedBox(height: 8),
              Text(
                'Payment ID: ${widget.paymentId}',
                style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? WireframeColor.green : WireframeColor.appcolor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context, isSuccess),
                child: Text(
                  isSuccess ? 'Done' : 'Back to Fees',
                  style: sansproSemibold.copyWith(fontSize: 16),
                ),
              ),
            ),
            if (!isSuccess && !isCancelled) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isDone    = false;
                    _status    = '';
                    _message   = '';
                    _isLoading = true;
                  });
                  _controller.loadRequest(Uri.parse(widget.bkashUrl));
                },
                child: Text('Try Again', style: sansproSemibold.copyWith(color: WireframeColor.appcolor)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}