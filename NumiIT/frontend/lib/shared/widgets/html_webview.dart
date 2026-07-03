import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlWebViewPage extends StatefulWidget {
  final String assetPath;
  const HtmlWebViewPage({super.key, required this.assetPath});

  @override
  State<HtmlWebViewPage> createState() => _HtmlWebViewPageState();
}

class _HtmlWebViewPageState extends State<HtmlWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NumiIT')), // Simple title
      body: WebViewWidget(controller: _controller),
    );
  }
}
