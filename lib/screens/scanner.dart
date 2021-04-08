import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/settings_qrcode.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

typedef OnScanned = void Function(String address);

class QRCodeScannerArguments {
  final WalletHandler store;
  final OnScanned onScanned;
  final bool closeWhenScanned;
  QRCodeScannerArguments(
      {this.store, this.onScanned, this.closeWhenScanned = true});
}

class QRCodeScannerPage extends StatefulWidget {
  QRCodeScannerPage({Key key, this.arguments}) : super(key: key);

  final QRCodeScannerArguments arguments;

  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  /*static final RegExp _basicAddress =
      RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false);
  //List<Barcode> _scanResults;
  String _scanResult;
  CameraController _camera;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;*/

  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildQrView(context),
          Navigator.canPop(context)
              ? SafeArea(
                  child: IconButton(
                    icon: Icon(
                        Platform.isIOS
                            ? Icons.arrow_back_ios
                            : Icons.arrow_back,
                        color: HermezColors.lightOrange),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                )
              : Container(),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                            backgroundColor: Color(0xfff6e9d3),
                            minimumSize: Size(60, 60),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return Image.asset("assets/scan.png",
                                  color: HermezColors.blackTwo, height: 20);
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Flash",
                          style: TextStyle(
                            color: HermezColors.lightOrange,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 30),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                            backgroundColor: Color(0xfff6e9d3),
                            minimumSize: Size(60, 60),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.of(context).pushReplacementNamed(
                                  "/qrcode",
                                  arguments: SettingsQRCodeArguments(
                                      store: widget.arguments.store,
                                      fromHomeScreen: false));
                            } else {
                              Navigator.of(context).pushNamed("/qrcode",
                                  arguments: SettingsQRCodeArguments(
                                      store: widget.arguments.store,
                                      fromHomeScreen: true));
                            }
                          },
                          child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return Image.asset("assets/qr_code.png",
                                  color: HermezColors.blackTwo, height: 20);
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "My Code",
                          style: TextStyle(
                            color: HermezColors.lightOrange,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 30),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                            backgroundColor: Color(0xfff6e9d3),
                            minimumSize: Size(60, 60),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                //return Text(
                                //    'Camera facing ${describeEnum(snapshot.data)}');
                              } else {
                                //return Text('loading');
                              }
                              return Image.asset("assets/scan.png",
                                  color: HermezColors.blackTwo, height: 20);
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Switch",
                          style: TextStyle(
                            color: HermezColors.lightOrange,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 50)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: HermezColors.lightOrange,
          borderRadius: 50,
          borderLength: 60,
          borderWidth: 7,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
