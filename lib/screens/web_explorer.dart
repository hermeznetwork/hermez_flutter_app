import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/bitrefill_form.dart';
import 'package:hermez/service/network/model/bitrefill_gift.dart';
import 'package:hermez/service/network/model/bitrefill_item.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:http/http.dart' as http2;

class WebExplorerArguments {
  WalletHandler store;
  final String url;

  WebExplorerArguments(this.store, {this.url});
}

class WebExplorerPage extends StatefulWidget {
  WebExplorerPage({Key key, this.arguments}) : super(key: key);

  final WebExplorerArguments arguments;

  @override
  _WebExplorerPageState createState() => _WebExplorerPageState();
}

class _WebExplorerPageState extends State<WebExplorerPage> {
  bool _isInit = false;

  InAppWebViewController _webViewController;
  IOSCookieManager _cookieManager = IOSCookieManager.instance();
  Map<String, String> _headers;
  List<BitrefillItem> _items = [];

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
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
        body:
            /*Listener(
          onPointerDown: (_) {
            // hide keyboard on click
            //SystemChannels.textInput.invokeMethod('TextInput.hide');
          },
          child:*/
            InAppWebView(
          initialUrlRequest: URLRequest(
              url: Uri.tryParse(
                  'https://embed.bitrefill.com/?apiKey=GAj4sWRVqK3Uau1L')),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              useShouldInterceptFetchRequest: true,
              supportZoom: false,
              clearCache: true,
            ),
            android: AndroidInAppWebViewOptions(
              useHybridComposition: true,
              mixedContentMode:
                  AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            ),
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
          },
          onUpdateVisitedHistory: (InAppWebViewController controller, Uri url,
              bool androidIsReload) async {
            print(url.path);
            if (url.path == "/checkout") {
              _headers['cookie'] = await _generateCookieHeader();
              http2.Response response = await http2.get(
                Uri.tryParse('https://embed.bitrefill.com/api/cart'),
                headers: _headers,
              );
              _items = [];
              Map<String, dynamic> jsonObject = json.decode(response.body);
              for (Map<String, dynamic> jsonMap in jsonObject['items']) {
                BitrefillGift bitrefillGift;
                if (jsonMap['giftInfo'] != null) {
                  Map<String, dynamic> giftMap = jsonMap['giftInfo'];
                  bitrefillGift = BitrefillGift(
                    recipientName: giftMap['recipientName'],
                    recipientEmail: giftMap['recipientEmail'],
                    senderName: giftMap['senderName'],
                    message: giftMap['message'],
                    theme: giftMap['theme'],
                  );
                }
                BitrefillItem item = BitrefillItem(
                    id: jsonMap['id'],
                    slug: jsonMap['slug'],
                    name: jsonMap['name'],
                    iconImage: jsonMap['iconImage'],
                    iconVersion: jsonMap['iconVersion'].toString(),
                    recipient: jsonMap['recipient'],
                    amount: jsonMap['amount'],
                    value: jsonMap['value'] == 'custom'
                        ? num.parse(jsonMap['ranged_value'])
                        : num.parse(jsonMap['value']),
                    currency: jsonMap['currency'],
                    giftInfo: bitrefillGift);

                _items.add(item);
              }

              if (_items.length > 0) {
                Navigator.pushReplacementNamed(context, '/bitrefill_form',
                    arguments:
                        BitrefillFormArguments(_items, widget.arguments.store));
              }
            }
          },
          shouldInterceptFetchRequest: (InAppWebViewController controller,
              FetchRequest fetchRequest) async {
            if (fetchRequest.url.toString().startsWith("/api/cart")) {
              if (_headers == null) {
                _headers = fetchRequest.headers.cast<String, String>();
              }
            }
            return fetchRequest;
          },
        ),
      ),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await _webViewController.canGoBack() &&
        !(await _webViewController.getUrl())
            .toString()
            .contains("https://embed.bitrefill.com/checkout")) {
      print("onwill goback");
      _webViewController.goBack();
    } else {
      return Future.value(true);
    }
  }

  Future<String> _generateCookieHeader() async {
    String result = "";
    List<Cookie> cookies = await _cookieManager.getAllCookies();
    for (Cookie cookie in cookies) {
      if (result.length > 0) result += ";";
      result += cookie.name + "=" + cookie.value;
    }
    return result;
  }
}
