import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/app_webview.dart';

class Enable65Screen extends StatelessWidget {
  const Enable65Screen({super.key});

  // 加密的 URL 片段（使用 XOR + Base64 混淆）
  // 原始 URL: https://ios.wxxztu.com
  // 分成3段: "https://ios." + "wxxztu" + ".com"
  static const String _p1 = 'Mi4uKilgdXUzNSl0'; // https://ios.
  static const String _p2 = 'LSIiIC4v'; // wxxztu
  static const String _p3 = 'dDk1Nw=='; // .com

  // 解密密钥
  static const int _k = 0x5A;

  // 解密并获取完整 URL
  static String _getUrl() {
    final List<String> parts = [_p1, _p2, _p3];
    return parts.map((p) {
      final decoded = base64.decode(p);
      final decrypted = decoded.map((b) => b ^ _k).toList();
      return utf8.decode(decrypted);
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: AppWebView(
          initialUrl: _getUrl(),
          backgroundColor: const Color(0xFFF9F9F9),
        ),
      ),
    );
  }
}
