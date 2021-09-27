import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

typedef OnScanned = void Function(String address);

enum QRCodeScannerType { ALL, HERMEZ_ADDRESS, ETHEREUM_ADDRESS, TRANSFER }

class QRCodeScannerArguments {
  //final WalletHandler store;
  final QRCodeScannerType type;
  final OnScanned onScanned;
  final bool closeWhenScanned;
  QRCodeScannerArguments(
      {/*this.store,*/
      this.type = QRCodeScannerType.ALL,
      this.onScanned,
      this.closeWhenScanned = true});
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

  String result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // final picker = ImagePicker();
  var showFlashBtn = false;
  var showSwitchBtn = false;
  var flashStatus = false;

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
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 84),
              child: Text(
                'Scan another Hermez code to\n send or receive tokens in your \nHermez wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HermezColors.lightGrey,
                  fontSize: 16,
                  height: 1.57,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    showFlashBtn == false
                        ? FutureBuilder(
                            future: Future.wait(
                                [showFlashButton(), getFlashStatus()]),
                            builder: (context,
                                AsyncSnapshot<List<dynamic>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.data != null &&
                                    showFlashBtn == true) {
                                  return Row(
                                    children: [
                                      IconButton(
                                          iconSize: 56,
                                          padding: EdgeInsets.all(0),
                                          icon: snapshot.data[1] == true
                                              ? Image.asset(
                                                  "assets/flash_on.png",
                                                  width: 56,
                                                  height: 56)
                                              : SvgPicture.asset(
                                                  "assets/flash_off.svg",
                                                  width: 56,
                                                  height: 56),
                                          onPressed: () async {
                                            await controller?.toggleFlash();
                                            setState(() {});
                                          }),
                                      SizedBox(width: 28),
                                    ],
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            })
                        : FutureBuilder(
                            future: getFlashStatus(),
                            builder: (context, AsyncSnapshot<bool> snapshot) {
                              return Row(
                                children: [
                                  IconButton(
                                      iconSize: 56,
                                      padding: EdgeInsets.all(0),
                                      icon: flashStatus == true
                                          ? Image.asset("assets/flash_on.png",
                                              width: 56, height: 56)
                                          : SvgPicture.asset(
                                              "assets/flash_off.svg",
                                              width: 56,
                                              height: 56),
                                      onPressed: () async {
                                        await controller?.toggleFlash();
                                        setState(() {});
                                      }),
                                  SizedBox(width: 28),
                                ],
                              );
                            },
                          ),
                    FutureBuilder(
                      future: showSwitchCamera(),
                      builder: (context, AsyncSnapshot<bool> snapshot) {
                        if (showSwitchBtn == true) {
                          return Row(
                            children: [
                              IconButton(
                                  iconSize: 56,
                                  padding: EdgeInsets.all(0),
                                  icon: SvgPicture.asset(
                                      "assets/switch_camera.svg",
                                      width: 56,
                                      height: 56),
                                  onPressed: () async {
                                    await controller?.flipCamera();
                                    setState(() {});
                                  }),
                              SizedBox(width: 28),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    IconButton(
                      iconSize: 56,
                      padding: EdgeInsets.all(0),
                      icon: SvgPicture.asset("assets/qr_gallery.svg",
                          width: 56, height: 56),
                      onPressed: () async {
                        _getQrByGallery();
                      },
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

  void _getQrByGallery() async {
    XFile file = await picker.pickImage(source: ImageSource.gallery);
    print(file.path);
    String data = await QrCodeToolsPlugin.decodeFrom(file.path)
        .onError((error, stackTrace) {
      return error.toString();
    });
    print(data);
    if (data != null && data.length > 0) {
      if (result == null) {
        List<String> scannedStrings = data.split(":");
        if (scannedStrings.length > 0 &&
            (widget.arguments.type == QRCodeScannerType.ALL ||
                widget.arguments.type == QRCodeScannerType.HERMEZ_ADDRESS) &&
            AddressUtils.isValidEthereumAddress(scannedStrings[1])) {
          finish(data);
        } else if (scannedStrings.length > 0 &&
            (widget.arguments.type == QRCodeScannerType.ALL ||
                widget.arguments.type == QRCodeScannerType.ETHEREUM_ADDRESS) &&
            AddressUtils.isValidEthereumAddress(scannedStrings[0])) {
          finish(data);
        }
      }
    }
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
      if (result == null) {
        List<String> scannedStrings = scanData.code.split(":");
        if ((scannedStrings.length > 0 &&
                    widget.arguments.type == QRCodeScannerType.ALL ||
                widget.arguments.type == QRCodeScannerType.HERMEZ_ADDRESS) &&
            AddressUtils.isValidEthereumAddress(scannedStrings[1])) {
          finish(scanData.code);
        } else if ((scannedStrings.length > 0 &&
                    widget.arguments.type == QRCodeScannerType.ALL ||
                widget.arguments.type == QRCodeScannerType.ETHEREUM_ADDRESS) &&
            AddressUtils.isValidEthereumAddress(scannedStrings[0])) {
          finish(scanData.code);
        }
      }
    }, onError: null, onDone: null, cancelOnError: false);
  }

  void finish(String scanData) {
    result = scanData;
    if (widget.arguments.closeWhenScanned) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
    if (widget.arguments.onScanned != null) {
      widget.arguments.onScanned(result);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<bool> showFlashButton() async {
    SystemFeatures systemFeatures = await controller?.getSystemFeatures();
    if (systemFeatures != null) {
      showFlashBtn = systemFeatures.hasFlash ?? false;
    } else {
      showFlashBtn = false;
    }
    return showFlashBtn;
  }

  Future<bool> showSwitchCamera() async {
    SystemFeatures systemFeatures = await controller?.getSystemFeatures();
    if (systemFeatures != null) {
      showSwitchBtn =
          systemFeatures.hasFrontCamera && systemFeatures.hasBackCamera ??
              false;
    } else {
      showSwitchBtn = false;
    }
    return showSwitchBtn;
  }

  Future<bool> getFlashStatus() async {
    bool status = await controller?.getFlashStatus();
    flashStatus = status;
    return flashStatus;
  }
}
