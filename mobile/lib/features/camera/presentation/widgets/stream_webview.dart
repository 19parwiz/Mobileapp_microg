import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StreamWebView extends StatefulWidget {
  final String url;

  const StreamWebView({
    super.key,
    required this.url,
  });

  @override
  State<StreamWebView> createState() => _StreamWebViewState();
}

class _StreamWebViewState extends State<StreamWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
