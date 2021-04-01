import 'package:flutter/material.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/biometrics_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:local_auth/local_auth.dart';

class BiometricsArguments {
  final bool isFingerprint;

  BiometricsArguments(this.isFingerprint);
}

class BiometricsPage extends StatefulWidget {
  BiometricsPage({Key key, this.arguments, this.configurationService})
      : super(key: key);

  final BiometricsArguments arguments;
  final ConfigurationService configurationService;

  @override
  _BiometricsPageState createState() => _BiometricsPageState();
}

class _BiometricsPageState extends State<BiometricsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
            'Enable ' +
                (widget.arguments.isFingerprint ? 'Fingerprint' : 'Face ID'),
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: HermezColors.mediumOrange,
      ),
      body: SafeArea(
        child: Container(
          color: HermezColors.mediumOrange,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: new Center(
                      child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        Image.asset(
                          widget.arguments.isFingerprint
                              ? 'assets/biometrics_fingerprint.png'
                              : 'assets/biometrics_face.png',
                          width: 120,
                          height: 120,
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Text(
                            'Access to your Hermez\n wallet with ' +
                                (widget.arguments.isFingerprint
                                    ? 'Fingerprint'
                                    : 'Face ID'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: HermezColors.blackTwo,
                              fontSize: 18,
                              height: 1.8,
                              decoration: TextDecoration.none,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      ]))),
              Container(
                margin: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 30.0, bottom: 0.0),
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      onPressed: () async {
                        if (await BiometricsUtils.canCheckBiometrics() &&
                            await BiometricsUtils.isDeviceSupported()) {
                          List<BiometricType> availableBiometrics =
                              await BiometricsUtils.getAvailableBiometrics();
                          if (!widget.arguments.isFingerprint &&
                              availableBiometrics
                                  .contains(BiometricType.face)) {
                            // Face ID.
                            bool authenticated = await BiometricsUtils
                                .authenticateWithBiometrics('Scan your ' +
                                    (widget.arguments.isFingerprint
                                        ? 'fingerprint'
                                        : 'face') +
                                    ' to authenticate');
                            if (authenticated) {
                              widget.configurationService
                                  .setBiometricsFace(true);
                              Navigator.of(context).pop(authenticated);
                            }
                          } else if (widget.arguments.isFingerprint &&
                              availableBiometrics
                                  .contains(BiometricType.fingerprint)) {
                            // Touch ID.
                            bool authenticated = await BiometricsUtils
                                .authenticateWithBiometrics('Scan your ' +
                                    (widget.arguments.isFingerprint
                                        ? 'fingerprint'
                                        : 'face') +
                                    ' to authenticate');
                            if (authenticated) {
                              widget.configurationService
                                  .setBiometricsFingerprint(true);
                              Navigator.of(context).pop(authenticated);
                            }
                          }
                        }
                      },
                      padding: EdgeInsets.only(
                          top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                      disabledTextColor: Colors.grey,
                      disabledColor: Colors.blueGrey,
                      color: HermezColors.darkOrange,
                      textColor: Colors.white,
                      child: Text(
                          'Enable ' +
                              (widget.arguments.isFingerprint
                                  ? 'Fingerprint'
                                  : 'Face ID'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      padding: EdgeInsets.only(
                          top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                      disabledTextColor: Colors.grey,
                      textColor: HermezColors.blackTwo,
                      child: Text("Skip",
                          style: TextStyle(
                            color: HermezColors.blackTwo,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
