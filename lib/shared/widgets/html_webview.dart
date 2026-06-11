import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlWebViewPage extends StatelessWidget {
  final String assetPath;
  const HtmlWebViewPage({Key? key, required this.assetPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NumiIT')), // Simple title
      body: WebView(
        initialUrl: 'about:blank',
        onWebViewCreated: (controller) async {
          await controller.loadFlutterAsset(assetPath);
        },
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
