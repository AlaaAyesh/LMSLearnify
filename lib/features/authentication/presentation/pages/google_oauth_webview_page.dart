import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class GoogleOAuthWebViewPage extends StatefulWidget {
  final String authUrl;

  const GoogleOAuthWebViewPage({
    super.key,
    required this.authUrl,
  });

  @override
  State<GoogleOAuthWebViewPage> createState() => _GoogleOAuthWebViewPageState();
}

class _GoogleOAuthWebViewPageState extends State<GoogleOAuthWebViewPage> {
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
          },
          onNavigationRequest: (request) {
            final url = request.url;
            
            // Check if this is the callback URL
            if (_isCallbackUrl(url)) {
              _handleCallback(url);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  bool _isCallbackUrl(String url) {
    // Check if URL is our callback URL
    // The callback URL contains 'auth/google/callback' and has a 'code' parameter
    final uri = Uri.parse(url);
    return url.contains('auth/google/callback') && uri.queryParameters.containsKey('code');
  }

  void _handleCallback(String url) {
    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];
    
    // Check for error from Google
    if (error != null && error.isNotEmpty) {
      String errorMessage = 'فشل في تسجيل الدخول';
      if (error == 'access_denied') {
        errorMessage = 'تم رفض الوصول';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
      return;
    }
    
    if (code != null && code.isNotEmpty) {
      // URL decode the code if needed (Google may URL-encode it)
      final decodedCode = Uri.decodeComponent(code);
      
      // Send the code to the bloc to complete authentication
      context.read<AuthBloc>().add(GoogleCallbackEvent(code: decodedCode));
      
      // Close the WebView and wait for authentication result
      Navigator.of(context).pop();
    } else {
      // No code found - show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'فشل في الحصول على رمز المصادقة',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Successfully authenticated - navigate to home
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        } else if (state is AuthError) {
          // Show error and close
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'تسجيل الدخول بـ Google',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

