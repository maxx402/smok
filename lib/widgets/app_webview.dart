import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebView extends StatefulWidget {
  const AppWebView({
    super.key,
    required this.initialUrl,
    this.loadingMessage,
    this.onPageStarted,
    this.onPageFinished,
    this.backgroundColor,
  });

  final String initialUrl;
  final String? loadingMessage;
  final ValueChanged<String>? onPageStarted;
  final ValueChanged<String>? onPageFinished;
  final Color? backgroundColor;

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (!mounted) {
              return;
            }
            setState(() => _isLoading = true);
            widget.onPageStarted?.call(url);
          },
          onPageFinished: (url) {
            if (!mounted) {
              return;
            }
            setState(() => _isLoading = false);
            widget.onPageFinished?.call(url);
          },
          onWebResourceError: (error) {
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('加载失败: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          color: widget.backgroundColor,
          child: WebViewWidget(controller: _controller),
        ),
        if (_isLoading)
          Container(
            color: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  if (widget.loadingMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.loadingMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
