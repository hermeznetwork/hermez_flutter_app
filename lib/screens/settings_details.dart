import 'package:flutter/material.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/pin.dart';
import 'package:hermez/screens/recovery_phrase.dart';
import 'package:hermez/screens/remove_account_info.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/biometrics_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/environment.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../wallet_account_selector_page.dart';
import '../wallet_transfer_amount_page.dart';

//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

enum SettingsDetailsType {
  GENERAL,
  SECURITY,
  ADVANCED,
}

class SettingsDetailsArguments {
  final WalletHandler store;
  final SettingsDetailsType type;

  SettingsDetailsArguments(this.store, this.type);
}

class SettingsDetailsPage extends StatefulWidget {
  SettingsDetailsPage({Key key, this.arguments, this.configurationService})
      : super(key: key);

  final SettingsDetailsArguments arguments;
  final ConfigurationService configurationService;

  @override
  _SettingsDetailsPageState createState() => _SettingsDetailsPageState();
}

class _SettingsDetailsPageState extends State<SettingsDetailsPage> {
  bool showBiometrics = false;

  @override
  void initState() {
    super.initState();
    if (widget.arguments.type == SettingsDetailsType.SECURITY) {
      shouldShowBiometrics();
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "";
    switch (widget.arguments.type) {
      case SettingsDetailsType.GENERAL:
        title = 'General';
        break;
      case SettingsDetailsType.SECURITY:
        title = 'Security';
        break;
      case SettingsDetailsType.ADVANCED:
        title = 'Advanced';
        break;
    }
    return Scaffold(
        appBar: new AppBar(
          title: new Text(title,
              style: TextStyle(
                  fontFamily: 'ModernEra',
                  color: HermezColors.blackTwo,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(child: buildSettingsList()));
  }

  buildSettingsList() {
    int count = 0;
    switch (widget.arguments.type) {
      case SettingsDetailsType.GENERAL:
        count = 3;
        break;
      case SettingsDetailsType.SECURITY:
        count = 2;
        if (showBiometrics) {
          count++;
        }
        break;
      case SettingsDetailsType.ADVANCED:
        count = 2;
        break;
    }
    return Container(
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: count,
        //set the item count so that index won't be out of range
        padding: const EdgeInsets.all(16.0),
        //add some padding to make it look good
        itemBuilder: (context, i) {
          //item builder returns a row for each index i=0,1,2,3,4
          // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

          // final index = i ~/ 2; //get the actual index excluding dividers.
          String title = "";
          String subtitle;
          String icon = "";

          final index = i;
          switch (index) {
            case 0:
              switch (widget.arguments.type) {
                case SettingsDetailsType.GENERAL:
                  title = "Currency conversion";
                  icon = "assets/currency_conversion.png";
                  break;
                case SettingsDetailsType.SECURITY:
                  title = "Show recovery phrase";
                  icon = "assets/show_recovery_phrase.png";
                  break;
                case SettingsDetailsType.ADVANCED:
                  title = "Force withdrawal";
                  subtitle = "Forces the coordinator to process"
                      " the transaction (more Gas is required).";
                  icon = "assets/force_exit.png";
                  break;
              }
              break;
            case 1:
              switch (widget.arguments.type) {
                case SettingsDetailsType.GENERAL:
                  title = "View in block explorer";
                  icon = "assets/view_explorer.png";
                  break;
                case SettingsDetailsType.SECURITY:
                  title = "Change passcode";
                  icon = "assets/change_passcode.png";
                  break;
                case SettingsDetailsType.ADVANCED:
                  title = "Remove account";
                  icon = "assets/remove_account.png";
                  break;
              }
              break;
            case 2:
              switch (widget.arguments.type) {
                case SettingsDetailsType.GENERAL:
                  title = "Lock wallet";
                  icon = "assets/logout.png";
                  break;
                case SettingsDetailsType.SECURITY:
                  title = widget.configurationService.getBiometricsFace()
                      ? "Disable Face ID"
                      : widget.configurationService.getBiometricsFingerprint()
                          ? "Disable fingerprint"
                          : "Enable fingerprint";
                  icon = "assets/fingerprint.png";
                  break;
                case SettingsDetailsType.ADVANCED:
                  title = "General";
                  break;
              }
              break;
          }

          return ListTile(
            leading: Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Image.asset(
                  icon,
                  height: 20,
                  width: 20,
                )),
            /*trailing: Container(
                padding: EdgeInsets.only(top: 20.0),
                child: Image.asset("assets/arrow_right.png",
                    height: 12, color: HermezColors.blackTwo)),*/
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  //alignment: Alignment(-1.3, 0),
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 30.0, bottom: subtitle != null ? 8.0 : 30.0),
                    child: Text(
                      title,
                      style: TextStyle(
                          color: HermezColors.black,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                subtitle != null
                    ? Align(
                        child: Container(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                                color: HermezColors.blueyGreyTwo,
                                fontFamily: 'ModernEra',
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
            onTap: () {
              switch (index) {
                case 0:
                  switch (widget.arguments.type) {
                    case SettingsDetailsType.GENERAL:
                      //  Currency conversion
                      Navigator.of(context).pushNamed("/currency_selector",
                          arguments: widget.arguments.store);
                      break;
                    case SettingsDetailsType.SECURITY:
                      // Show recovery phrase
                      Navigator.of(context)
                          .pushNamed("/pin",
                              arguments: PinArguments(
                                  "Show Recovery Phrase", false, null))
                          .then((value) {
                        if (value.toString() == "true") {
                          Navigator.of(context).pushNamed("/recovery_phrase",
                              arguments: RecoveryPhraseArguments(false,
                                  store: widget.arguments.store));
                        }
                      });
                      break;
                    case SettingsDetailsType.ADVANCED:
                      // Force withdrawal
                      Navigator.of(context).pushNamed("/account_selector",
                          arguments: AccountSelectorArguments(
                            //widget.arguments.store.state.txLevel,
                            TransactionType.FORCEEXIT,
                            widget.arguments.store,
                          ));
                      break;
                  }
                  break;
                case 1:
                  switch (widget.arguments.type) {
                    case SettingsDetailsType.GENERAL:
                      // View in block explorer
                      viewInExplorer();
                      break;
                    case SettingsDetailsType.SECURITY:
                      // Change passcode
                      Navigator.of(context)
                          .pushNamed("/pin",
                              arguments: PinArguments(
                                  "Enter old passcode", false, null))
                          .then((value) {
                        if (value.toString() == "true") {
                          Navigator.of(context).pushNamed("/pin",
                              arguments: PinArguments(
                                  "Enter new passcode", true, null));
                        }
                      });
                      break;
                    case SettingsDetailsType.ADVANCED:
                      // Remove account
                      Navigator.of(context).pushNamed("/remove_account_info",
                          arguments: RemoveAccountInfoArguments(
                              widget.arguments.store));
                      break;
                  }
                  break;
                case 2:
                  switch (widget.arguments.type) {
                    case SettingsDetailsType.GENERAL:
                      // Lock wallet
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/", (Route<dynamic> route) => false);
                      break;
                    case SettingsDetailsType.SECURITY:
                      // Biometrics
                      checkBiometrics();
                      break;
                    case SettingsDetailsType.ADVANCED:
                      // Nothing
                      break;
                  }
                  break;
              }
            },
          ); //iterate through indexes and get the next colour
          //return _buildRow(context, element, color); //build the row widget
        },
      ),
    );
  }

  viewInExplorer() async {
    var url;
    if (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1) {
      url = getCurrentEnvironment().etherscanUrl +
          "/address/" +
          widget.arguments.store.state.ethereumAddress;
    } else {
      url = getCurrentEnvironment().batchExplorerUrl +
          '/user-account/' +
          getHermezAddress(widget.arguments.store.state.ethereumAddress);
    }
    if (await canLaunch(url))
      await launch(url);
    else
      // can't launch url, there is some error
      throw "Could not launch $url";
  }

  Future<void> checkBiometrics() async {
    if (await BiometricsUtils.canCheckBiometrics() &&
        await BiometricsUtils.isDeviceSupported()) {
      List<BiometricType> availableBiometrics =
          await BiometricsUtils.getAvailableBiometrics();
      if (availableBiometrics.contains(BiometricType.face)) {
        // Face ID.
        bool authenticated =
            await BiometricsUtils.authenticateWithBiometrics('Scan your face'
                ' to authenticate');
        if (authenticated) {
          setState(() {
            widget.configurationService.setBiometricsFace(
                !widget.configurationService.getBiometricsFace());
          });
        }
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        // Touch ID.
        bool authenticated = await BiometricsUtils.authenticateWithBiometrics(
            'Scan your fingerprint'
            ' to authenticate');
        if (authenticated) {
          setState(() {
            widget.configurationService.setBiometricsFingerprint(
                !widget.configurationService.getBiometricsFingerprint());
          });
        }
      }
    }
  }

  Future<void> shouldShowBiometrics() async {
    if (await BiometricsUtils.canCheckBiometrics() &&
        await BiometricsUtils.isDeviceSupported()) {
      List<BiometricType> availableBiometrics =
          await BiometricsUtils.getAvailableBiometrics();
      if (availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.fingerprint)) {
        setState(() {
          showBiometrics = true;
        });

        return;
      }
    }
    setState(() {
      showBiometrics = false;
    });
    return;
  }
}
