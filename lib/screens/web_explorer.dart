import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hermez/service/network/model/bitrefill_gift.dart';
import 'package:hermez/service/network/model/bitrefill_item.dart';
import 'package:hermez/utils/hermez_colors.dart';
//import 'package:webview_flutter/webview_flutter.dart';

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

  InAppWebViewController _webViewController;
  IOSCookieManager _cookieManager = IOSCookieManager.instance();
  WebStorageManager _webStorageManager = WebStorageManager.instance();
  Map<String, String> _headers;
  List<BitrefillItem> _items = [];
  //WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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
          //initialFile: "assets/index.html",
          //initialHeaders: {},
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              useShouldOverrideUrlLoading: true,
              useShouldInterceptFetchRequest: true,
              useOnLoadResource: true,
              supportZoom: false,
              clearCache: true,
              /*debuggingEnabled: true,
    )*/
            ),
          ),
          /*initialUserScripts: ,*/
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;

            controller.addJavaScriptHandler(
                handlerName: "mySum",
                callback: (args) {
                  // Here you receive all the arguments from the JavaScript side
                  // that is a List<dynamic>
                  print("From the JavaScript side:");
                  print(args);
                  return args.reduce((curr, next) => curr + next);
                });
          },
          onLoadStart: (InAppWebViewController controller, Uri url) {
            print("onLoadStart " + url.toString());
          },
          onLoadStop: (InAppWebViewController controller, Uri url) async {
            print("onLoadStop " + url.toString());
            List<Cookie> cookies = await _cookieManager.getAllCookies();
            cookies.forEach((cookie) {
              print(cookie.name + " " + cookie.value);
            });
          },
          onLoadResource: (InAppWebViewController controller,
              LoadedResource resource) async {
            //print("onLoadResource " + resource.url.toString());
            if (resource.url.toString().contains(
                "https://embed.bitrefill.com/pixel/pixel.gif?original=https%3A%2F%2Fembed.bitrefill.com%2Fcheckout")) {
              /*List<Cookie> cookies = await _cookieManager.getAllCookies();
              // if current platform is iOS, delete all data for "flutter.dev".
              var records = await _webStorageManager.ios
                  .fetchDataRecords(dataTypes: IOSWKWebsiteDataType.values);
              var headers = Map<String, String>();
              var cookieString = "";
              cookies.forEach((cookie) {
                cookieString += cookie.name + "=" + cookie.value + "; ";

                print(cookie.name + " " + cookie.value);
              });
              headers['cookie'] = cookieString;*/
              Navigator.maybePop(context);
              //_webViewController.getHtml();*/
              /*_webViewController.loadUrl(
                  urlRequest: URLRequest(
                url: Uri.tryParse('https://embed.bitrefill.com/api/cart'),
                /*headers: {
                      "cookie":
                          "AMP-CONSENT=amp-71nqelvzfct9cSt-TaGc8g; connect.sid=s:kbbbjsOCJauCybshziVWCmlJ2lArnbz4.0WuMLa4Px+9qDyJ08SgMKFPPTGdlBjeBOz/qkeRgS/A; bitrefill=eyJvcmRlckVtYWlsIjoicmF1bC5qYXJlbm8uZGlhekBnbWFpbC5jb20ifQ==; bitrefill.sig=ddNdfY9FJ29YgbiwC0fkWPkqTOs; apikey_referrer=GAj4sWRVqK3Uau1L; _gcl_au=1.1.318145166.1628168047; _ga=GA1.2.1819869595.1628168047; _gid=GA1.2.2112841531.1628168047; brid=xDZqbaeUTI-1628172223; bzid=xDZqbaeUTI-1628172223; mp_3f4a2156790a10d622ab4fdbf12151bb_mixpanel={\"\$device_id\": \"1819869595.1628168047\",\"\$initial_referrer\": \"\$direct\",\"\$initial_referring_domain\": \"\$direct\",\"\$user_id\": \"1819869595.1628168047\",\"distinct_id\": \"1819869595.1628168047\"}"
                    }),*/
                headers: _headers,
              ));*/
            }
            /* else if (resource.url.toString().contains("/cart")) {
              print("CART: ${resource.url}");
              print("CART: " + controller.toString());
            }*/
          },
          iosOnNavigationResponse: (InAppWebViewController controller,
              IOSWKNavigationResponse navigationResponse) async {
            return IOSNavigationResponseAction.ALLOW;
          },
          /*onJsConfirm: (InAppWebViewController controller,
              JsConfirmRequest jsConfirmRequest) {},*/
          shouldInterceptFetchRequest: (InAppWebViewController controller,
              FetchRequest fetchRequest) async {
            print("shouldInterceptFetchRequest URL: ${fetchRequest.url}");
            if (fetchRequest.url.toString().startsWith("/api/cart")) {
              if (_headers == null) {
                _headers = fetchRequest.headers.cast<String, String>();
              }
              if (fetchRequest.method == "POST" && fetchRequest.body != null) {
                try {
                  String data = utf8.decode(List.from(fetchRequest.body));
                  List<String> splits = data.split(RegExp(r'[\r\n]'));
                  splits.removeWhere((element) =>
                      element == "" ||
                      element.startsWith("------WebKitFormBoundary"));
                  Map<String, dynamic> map = Map<String, String>();
                  for (int i = 0; i < splits.length; i++) {
                    String key = "";
                    String value = "";
                    if (splits[i].startsWith("Content-Disposition")) {
                      key = splits[i].replaceAll(
                          "Content-Disposition: form-data; name=", "");
                      key = key.replaceAll(RegExp(r'[\"]'), "");
                      print(key);
                      if (!splits[i + 1].startsWith("Content-Disposition")) {
                        value = splits[i + 1];
                      }
                      map[key] = value;
                    }
                  }
                  print(map);
                  BitrefillGift bitrefillGift;
                  if (map['gift'] != null && map['gift'] == "true") {
                    bitrefillGift = BitrefillGift(
                      recipientName: map['gift_recipient_name'],
                      recipientEmail: map['gift_recipient_email'],
                      delivery: map['gift_delivery'],
                      timezoneOffset: map['gift_delivery'] == "scheduled"
                          ? map['gift_delivery_timezone_offset']
                          : null,
                      senderName: map['gift_sender_name'],
                      message: map['gift_message'],
                      theme: map['gift_theme'],
                    );
                  }
                  BitrefillItem item = BitrefillItem(
                      slug: map['slug'],
                      recipient: map['recipient'],
                      amount: int.parse(map['amount']),
                      value: map['value'] == 'custom'
                          ? num.parse(map['ranged_value'])
                          : num.parse(map['value']),
                      giftInfo: bitrefillGift);
                  _items.add(item);
                } catch (e) {
                  print(e.toString());
                }
              } else if (fetchRequest.method == "PUT" &&
                  fetchRequest.body != null) {
                List<Map<String, dynamic>> jsonObject =
                    json.decode(fetchRequest.body);
                _items = [];
                for (Map<String, dynamic> map in jsonObject) {
                  BitrefillGift bitrefillGift;
                  if (map['giftInfo'] != null) {
                    Map<String, dynamic> giftMap = map['giftInfo'];
                    bitrefillGift = BitrefillGift(
                      recipientName: giftMap['recipientName'],
                      recipientEmail: giftMap['recipientEmail'],
                      senderName: giftMap['senderName'],
                      message: giftMap['message'],
                      theme: giftMap['theme'],
                    );
                  }
                  BitrefillItem item = BitrefillItem(
                      id: map['id'],
                      slug: map['slug'],
                      recipient: map['recipient'],
                      amount: map['amount'],
                      value: map['value'] == 'custom'
                          ? num.parse(map['ranged_value'])
                          : num.parse(map['value']),
                      giftInfo: bitrefillGift);
                  _items.add(item);
                }
                print(jsonObject);
              } else if (fetchRequest.method == "DELETE") {
                // TODO remove by ID
              }
            }
            return fetchRequest;
          },
          onPrint: (InAppWebViewController controller, Uri url) {
            print("onPrint " + url.toString());
          },
          onConsoleMessage: (InAppWebViewController controller,
              ConsoleMessage consoleMessage) {
            print("console message: ${consoleMessage.message}");
          },
        ),
      ),
      //),
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
}
