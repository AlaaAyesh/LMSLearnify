import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class PaymentCheckoutWebViewPage extends StatefulWidget {
  final String checkoutUrl;

  const PaymentCheckoutWebViewPage({
    super.key,
    required this.checkoutUrl,
  });

  @override
  State<PaymentCheckoutWebViewPage> createState() => _PaymentCheckoutWebViewPageState();
}

class _PaymentCheckoutWebViewPageState extends State<PaymentCheckoutWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            
            // Check if payment was completed (redirect URLs)
            if (_isPaymentComplete(url)) {
              _handlePaymentComplete();
            } else if (_isPaymentFailed(url)) {
              _handlePaymentFailed();
            }
          },
          onNavigationRequest: (request) {
            final url = request.url;
            
            // Check if payment was completed or failed
            if (_isPaymentComplete(url)) {
              _handlePaymentComplete();
              return NavigationDecision.prevent;
            } else if (_isPaymentFailed(url)) {
              _handlePaymentFailed();
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('Payment WebView error: ${error.description}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('حدث خطأ أثناء تحميل صفحة الدفع'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  bool _isPaymentComplete(String url) {
    // Check if URL indicates successful payment
    // Kashier redirects to merchantRedirect URL on success
    final uri = Uri.parse(url);
    final host = uri.host.toLowerCase();
    
    print('Checking payment completion for URL: $url');
    print('Host: $host, Path: ${uri.path}, Query: ${uri.queryParameters}');
    
    // Check for success indicators in URL
    final isSuccess = uri.path.contains('success') ||
           uri.path.contains('payment-success') ||
           (uri.queryParameters.containsKey('payment_status') &&
           uri.queryParameters['payment_status'] == 'success') ||
           (uri.queryParameters.containsKey('status') &&
           uri.queryParameters['status'] == 'success') ||
           uri.queryParameters.containsKey('payment_success') ||
           // Check if redirected to merchant redirect URL (usually means success)
           (host.contains('learnify') && !host.contains('checkout') && !host.contains('api'));
    
    if (isSuccess) {
      print('Payment completion detected!');
    }
    
    return isSuccess;
  }

  bool _isPaymentFailed(String url) {
    // Check if URL indicates failed payment
    final uri = Uri.parse(url);
    return uri.path.contains('failure') ||
           uri.path.contains('payment-failed') ||
           uri.path.contains('cancel') ||
           uri.queryParameters.containsKey('payment_status') &&
           uri.queryParameters['payment_status'] == 'failed' ||
           uri.queryParameters.containsKey('status') &&
           uri.queryParameters['status'] == 'failed' ||
           uri.queryParameters.containsKey('error');
  }

  void _handlePaymentComplete() {
    if (mounted) {
      print('Handling payment completion...');
      setState(() => _isLoading = false);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إتمام عملية الدفع بنجاح'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Wait a bit for backend to process, then close
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          print('Returning success from payment checkout page');
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      });
    }
  }

  void _handlePaymentFailed() {
    if (mounted) {
      print('Handling payment failure...');
      setState(() => _isLoading = false);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشلت عملية الدفع. يرجى المحاولة مرة أخرى'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Wait a bit then close
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          print('Returning failure from payment checkout page');
          Navigator.of(context).pop(false); // Return false to indicate failure
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'إتمام الدفع',
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
