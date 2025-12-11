// HelpWebView removed — WebView feature reverted.
// This placeholder prevents build errors while the WebView integration is paused.
import 'package:flutter/material.dart';

class HelpWebView extends StatelessWidget {
  final String url;
  final String? title;
  const HelpWebView({super.key, required this.url, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'Help & Support')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Help & Support temporarily disabled. URL: $url'),
        ),
      ),
    );
  }
}
