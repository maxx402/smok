import 'package:flutter/material.dart';
import '../widgets/app_webview.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: _PrivacyPolicyContent(),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: const SafeArea(
        child: AppWebView(
          initialUrl: 'https://65sj.cc/privacy_policy.html',
          loadingMessage: '加载中...',
          backgroundColor: Color(0xFFF9F9F9),
        ),
      ),
    );
  }
}
