import 'dart:async';
import 'dart:convert' as JSON;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebExplorerArguments {
  final String url;

  WebExplorerArguments(this.url);
}

class WebExplorerPage extends StatefulWidget {
  WebExplorerPage({Key key, this.arguments}) : super(key: key);

  final WebExplorerArguments arguments;

  @override
  _WebExplorerPageState createState() => _WebExplorerPageState();
}

Timer timer;

class _WebExplorerPageState extends State<WebExplorerPage> {
  // WeblnHandlers _weblnHandlers;
  // InvoiceBloc _invoiceBloc;
  bool _isInit = false;

  WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      //_invoiceBloc = AppBlocsProvider.of<InvoiceBloc>(context);
      //_weblnHandlers = WeblnHandlers(context, widget.accountBloc, _invoiceBloc);

      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Bitrefill",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: HermezColors.lightOrange,
      body: Listener(
        onPointerDown: (_) {
          // hide keyboard on click
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: WebView(
          initialUrl: 'https://embed.bitrefill.com/?apiKey=GAj4sWRVqK3Uau1L',
          onWebViewCreated: (WebViewController webViewController) {
            setState(() {
              _webViewController = webViewController;
            });
          },
          // enable Javascript on WebView
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: <JavascriptChannel>[
            _hermezJavascriptChannel(context),
          ].toSet(),
          onPageStarted: (String url) async {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            // redirect post messages to javascript channel
            //_webViewController.evaluateJavascript(
            //    "window.onmessage = (message) => window.HermezWebView.postMessage(message.data);");
            print('Page finished loading: $url');
          },
        ),
      ),
    );
  }

  JavascriptChannel _hermezJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: "HermezWebView",
      onMessageReceived: (JavascriptMessage message) {
        if (message != null) {
          var postMessage = JSON.jsonDecode(message.message);
          print(postMessage);
        }
      },
    );
  }
}
