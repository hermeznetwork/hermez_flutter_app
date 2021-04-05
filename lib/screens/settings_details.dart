import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/pin.dart';
import 'package:hermez/screens/recovery_phrase.dart';
import 'package:hermez/screens/remove_account_info.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/environment.dart';
import 'package:url_launcher/url_launcher.dart';

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

class SettingsDetailsPage extends HookWidget {
  SettingsDetailsPage(this.arguments, this.configurationService);

  SettingsDetailsArguments arguments;
  ConfigurationService configurationService;

  @override
  Widget build(BuildContext context) {
    String title = "";
    switch (arguments.type) {
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
    /*final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("My Account",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: HermezColors.lightOrange,
      ),
      body: SafeArea(
          child:
              buildSettingsList() /*Column(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white,
                child: buildSettingsList(),
              ),
            ),
          ],
        ),*/
          ),
    );*/
  }

  buildSettingsList() {
    int count = 0;
    switch (arguments.type) {
      case SettingsDetailsType.GENERAL:
        count = 3;
        break;
      case SettingsDetailsType.SECURITY:
        count = 2;
        if (configurationService.getBiometricsFace() ||
            configurationService.getBiometricsFingerprint()) {
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
          String icon = "";

          final index = i;
          switch (index) {
            case 0:
              switch (arguments.type) {
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
                  icon = "assets/force_exit.png";
                  break;
              }
              break;
            case 1:
              switch (arguments.type) {
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
              switch (arguments.type) {
                case SettingsDetailsType.GENERAL:
                  title = "Lock wallet";
                  icon = "assets/logout.png";
                  break;
                case SettingsDetailsType.SECURITY:
                  title = configurationService.getBiometricsFace()
                      ? "Disable Face ID"
                      : configurationService.getBiometricsFingerprint()
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
            title: Align(
              alignment: Alignment(-1.3, 0),
              child: Container(
                padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
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
            onTap: () {
              switch (index) {
                case 0:
                  switch (arguments.type) {
                    case SettingsDetailsType.GENERAL:
                      //  Currency conversion
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
                              arguments: RecoveryPhraseArguments(false));
                        }
                      });
                      break;
                    case SettingsDetailsType.ADVANCED:
                      // Force withdrawal
                      break;
                  }
                  break;
                case 1:
                  switch (arguments.type) {
                    case SettingsDetailsType.GENERAL:
                      // View in block explorer
                      viewInExplorer();
                      break;
                    case SettingsDetailsType.SECURITY:
                      // Change passcode
                      Navigator.of(context).pushNamed("/pin",
                          arguments:
                              PinArguments("Change passcode", true, null));
                      break;
                    case SettingsDetailsType.ADVANCED:
                      // Remove account
                      Navigator.of(context).pushNamed("/remove_account_info",
                          arguments:
                              RemoveAccountInfoArguments(arguments.store));
                      break;
                  }
                  break;
                case 2:
                  switch (arguments.type) {
                    case SettingsDetailsType.GENERAL:
                      // Lock wallet
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/", (Route<dynamic> route) => false);
                      break;
                    case SettingsDetailsType.SECURITY:
                      // Biometrics
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
    var url = getCurrentEnvironment().etherscanUrl +
        "/address/" +
        arguments.store.state.ethereumAddress;
    if (await canLaunch(url))
      await launch(url);
    else
      // can't launch url, there is some error
      throw "Could not launch $url";
  }
}
