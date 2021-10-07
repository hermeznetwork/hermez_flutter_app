import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/constants.dart';
import 'package:hermez/dependencies_provider.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/presentation/accounts/widgets/account_selector.dart';
import 'package:hermez/src/presentation/security/widgets/pin.dart';
import 'package:hermez/src/presentation/settings/settings_bloc.dart';
import 'package:hermez/src/presentation/settings/settings_state.dart';
import 'package:hermez/src/presentation/settings/widgets/recovery_phrase.dart';
import 'package:hermez/src/presentation/settings/widgets/remove_account_info.dart';
import 'package:hermez/src/presentation/transfer/widgets/transaction_amount.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/pop_result.dart';
import 'package:local_auth/local_auth.dart';

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
  final BuildContext parentContext;
  final SettingsDetailsType type;
  final SettingsBloc settingsBloc;
  //final String hermezAddress;

  SettingsDetailsArguments(this.parentContext, this.type, this.settingsBloc);
}

class SettingsDetailsPage extends StatefulWidget {
  SettingsDetailsPage({
    Key key,
    this.arguments,
  }) : super(key: key);

  final SettingsDetailsArguments arguments;

  @override
  _SettingsDetailsPageState createState() =>
      _SettingsDetailsPageState(arguments.settingsBloc);
}

class _SettingsDetailsPageState extends State<SettingsDetailsPage> {
  //List<BiometricType> availableBiometrics;

  final SettingsBloc _settingsBloc;
  _SettingsDetailsPageState(SettingsBloc settingsBloc)
      : _settingsBloc =
            settingsBloc != null ? settingsBloc : getIt<SettingsBloc>() {
    if (!(_settingsBloc.state is LoadedSettingsState)) {
      _settingsBloc.init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _renderAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<SettingsState>(
          initialData: _settingsBloc.state,
          stream: _settingsBloc.observableState,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state is LoadingSettingsState) {
              return Container(
                  color: Colors.white,
                  child: Center(
                    child:
                        CircularProgressIndicator(color: HermezColors.orange),
                  ));
            } else if (state is ErrorSettingsState) {
              return Center(child: Text(state.message));
            } else {
              return _renderSettingsDetails(context, state);
            }
          },
        ),
      ),
    );
  }

  Widget _renderSettingsDetails(
      BuildContext context, LoadedSettingsState state) {
    int count = 0;
    switch (widget.arguments.type) {
      case SettingsDetailsType.GENERAL:
        count = 3;
        break;
      case SettingsDetailsType.SECURITY:
        count = 2;
        if (state.settings.availableBiometrics != null &&
            state.settings.availableBiometrics.length > 0) {
          count++;
        }
        break;
      case SettingsDetailsType.ADVANCED:
        count = 3;
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
                  icon = "assets/settings_currency_conversion.svg";
                  break;
                case SettingsDetailsType.SECURITY:
                  title = "Show recovery phrase";
                  icon = "assets/settings_show_recovery_phrase.svg";
                  break;
                case SettingsDetailsType.ADVANCED:
                  title = "Force withdrawal";
                  subtitle = "Forces the coordinator to process"
                      " the transaction (more Gas is required).";
                  icon = "assets/settings_force_withdrawal.svg";
                  break;
              }
              break;
            case 1:
              switch (widget.arguments.type) {
                case SettingsDetailsType.GENERAL:
                  title = "View in block explorer";
                  icon = "assets/settings_view_explorer.svg";
                  break;
                case SettingsDetailsType.SECURITY:
                  title = "Change passcode";
                  icon = "assets/settings_change_passcode.svg";
                  break;
                case SettingsDetailsType.ADVANCED:
                  title = "Modify default fee";
                  icon = "assets/settings_default_fee.svg";
                  break;
              }
              break;
            case 2:
              switch (widget.arguments.type) {
                case SettingsDetailsType.GENERAL:
                  title = "Lock wallet";
                  icon = "assets/settings_lock_wallet.svg";
                  break;
                case SettingsDetailsType.SECURITY:
                  {
                    String enabledName = "Enable";
                    String biometricName = "biometrics";
                    icon = "assets/settings_fingerprint.svg";
                    if (state.settings.availableBiometrics != null &&
                        state.settings.availableBiometrics.length > 1) {
                      biometricName = 'biometrics';
                      enabledName = (_settingsBloc.getBiometricsFace() ==
                                  false &&
                              _settingsBloc.getBiometricsFingerprint() == false)
                          ? "Enable"
                          : "Disable";
                    } else if (state.settings.availableBiometrics != null &&
                        state.settings.availableBiometrics
                            .contains(BiometricType.fingerprint)) {
                      biometricName = 'fingerprint';
                      enabledName =
                          (_settingsBloc.getBiometricsFingerprint() == false)
                              ? "Enable"
                              : "Disable";
                      icon = "assets/settings_fingerprint.svg";
                    } else if (state.settings.availableBiometrics != null &&
                        state.settings.availableBiometrics
                            .contains(BiometricType.face)) {
                      biometricName = Platform.isIOS ? 'Face ID' : 'face';
                      enabledName = (_settingsBloc.getBiometricsFace() == false)
                          ? "Enable"
                          : "Disable";
                      icon = "assets/settings_face.svg";
                    }
                    title = enabledName + " " + biometricName;
                    break;
                  }
                case SettingsDetailsType.ADVANCED:
                  title = "Remove account";
                  icon = "assets/settings_remove_account.svg";
                  break;
              }
              break;
          }

          return ListTile(
            leading: Container(
              //alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(top: 16.0),
              child: SvgPicture.asset(
                icon,
                /*height: 20,
                width: 20,*/
                fit: BoxFit.scaleDown,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
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
                        alignment: Alignment.centerLeft,
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
                      Navigator.of(context).pushNamed("currency_selector",
                          arguments: _settingsBloc);
                      break;
                    case SettingsDetailsType.SECURITY:
                      // Show recovery phrase
                      Navigator.of(widget.arguments.parentContext)
                          .pushNamed("/pin",
                              arguments: PinArguments(
                                  "Show Recovery Phrase", false, false))
                          .then((value) {
                        if (value.toString() == "true") {
                          Navigator.of(widget.arguments.parentContext)
                              .pushNamed("/recovery_phrase",
                                  arguments: RecoveryPhraseArguments(
                                      false, _settingsBloc));
                        }
                      });
                      break;
                    case SettingsDetailsType.ADVANCED:
                      Navigator.pushNamed(widget.arguments.parentContext,
                              "/account_selector",
                              arguments: AccountSelectorArguments(
                                  TransactionLevel.LEVEL2,
                                  TransactionType.FORCEEXIT,
                                  "" /*,
                                  widget.arguments.store*/
                                  ))
                          .then((selectedAccount) {
                        if (selectedAccount != null) {
                          /*Token token = widget.arguments.store.state.tokens
                              .firstWhere((token) =>
                                  token.id ==
                                  (selectedAccount as Account).tokenId);
                          PriceToken priceToken = widget
                              .arguments.store.state.priceTokens
                              .firstWhere((priceToken) =>
                                  priceToken.id ==
                                  (selectedAccount as Account).tokenId);*/
                          // Force withdrawal
                          Navigator.pushNamed(widget.arguments.parentContext,
                                  "/transaction_amount",
                                  arguments: TransactionAmountArguments(
                                      //widget.arguments.store,
                                      TransactionLevel.LEVEL2,
                                      TransactionType.FORCEEXIT,
                                      account: selectedAccount,
                                      //token: token,
                                      //priceToken: priceToken,
                                      allowChangeLevel: false))
                              .then((results) {
                            if (results is PopWithResults) {
                              PopWithResults popResult = results;
                              if (popResult.toPage == "/home") {
                                Navigator.pop(context, popResult);
                                /*if (this.onForceExitSuccess != null) {
                                  this.onForceExitSuccess();
                                }*/
                              }
                            }
                          });
                        }
                      });

                      break;
                  }
                  break;
                case 1:
                  switch (widget.arguments.type) {
                    case SettingsDetailsType.GENERAL:
                      // View in block explorer
                      _settingsBloc
                          .showInBatchExplorer(state.settings.hermezAddress);
                      break;
                    case SettingsDetailsType.SECURITY:
                      // Change passcode
                      Navigator.of(widget.arguments.parentContext)
                          .pushNamed("/pin",
                              arguments: PinArguments(
                                  "Enter old passcode", false, false))
                          .then((value) {
                        if (value.toString() == "true") {
                          Navigator.of(widget.arguments.parentContext)
                              .pushNamed("/pin",
                                  arguments: PinArguments(
                                      "Enter new passcode", true, true))
                              .then((value) {
                            if (value.toString() == "true") {
                              Flushbar(
                                messageText: Text(
                                  'Your passcode has been changed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: HermezColors.blackTwo,
                                    fontSize: 16,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                boxShadows: [
                                  BoxShadow(
                                    color:
                                        HermezColors.blueyGreyTwo.withAlpha(64),
                                    offset: Offset(0, 4),
                                    blurRadius: 16,
                                    spreadRadius: 0,
                                  ),
                                ],
                                borderColor:
                                    HermezColors.blueyGreyTwo.withAlpha(64),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                backgroundColor: Colors.white,
                                margin: EdgeInsets.all(16.0),
                                duration: Duration(
                                    seconds: FLUSHBAR_AUTO_HIDE_DURATION),
                              ).show(context);
                            }
                          });
                        }
                      });
                      break;
                    case SettingsDetailsType.ADVANCED:
                      // Default fee
                      Navigator.of(context)
                          .pushNamed("fee_selector", arguments: _settingsBloc);
                      break;
                  }
                  break;
                case 2:
                  switch (widget.arguments.type) {
                    case SettingsDetailsType.GENERAL:
                      // Lock wallet
                      Navigator.pushNamedAndRemoveUntil(
                          widget.arguments.parentContext,
                          "/",
                          (Route<dynamic> route) => false);
                      break;
                    case SettingsDetailsType.SECURITY:
                      // Biometrics
                      checkBiometrics();
                      break;
                    case SettingsDetailsType.ADVANCED:
                      // Remove account
                      Navigator.of(widget.arguments.parentContext).pushNamed(
                          "/remove_account_info",
                          arguments: RemoveAccountInfoArguments(_settingsBloc));
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

  Widget _renderAppBar() {
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
    return AppBar(
      title: new Text(title,
          style: TextStyle(
              fontFamily: 'ModernEra',
              color: HermezColors.blackTwo,
              fontWeight: FontWeight.w800,
              fontSize: 20)),
      centerTitle: true,
      elevation: 0.0,
      backgroundColor: Colors.white,
    );
  }

  Future<void> checkBiometrics() async {
    if (widget.arguments.type == SettingsDetailsType.SECURITY) {
      if ((_settingsBloc.state as LoadedSettingsState)
          .settings
          .availableBiometrics
          .contains(BiometricType.face)) {
        // Face ID.
        bool authenticated = await _settingsBloc
            .authenticateWithBiometrics('Scan your face to authenticate');
        if (authenticated) {
          setState(() {
            _settingsBloc.setBiometricsFace(!_settingsBloc.getBiometricsFace());
          });
          Flushbar(
            messageText: Text(
              (Platform.isIOS ? 'Face ID' : 'Face') +
                  ' has been ' +
                  (_settingsBloc.getBiometricsFace() ? 'enabled' : 'disabled'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: HermezColors.blackTwo,
                fontSize: 16,
                fontFamily: 'ModernEra',
                fontWeight: FontWeight.w700,
              ),
            ),
            boxShadows: [
              BoxShadow(
                color: HermezColors.blueyGreyTwo.withAlpha(64),
                offset: Offset(0, 4),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
            borderColor: HermezColors.blueyGreyTwo.withAlpha(64),
            borderRadius: BorderRadius.all(Radius.circular(12)),
            backgroundColor: Colors.white,
            margin: EdgeInsets.all(16.0),
            duration: Duration(seconds: FLUSHBAR_AUTO_HIDE_DURATION),
          ).show(context);
        }
      } else if ((_settingsBloc.state as LoadedSettingsState)
          .settings
          .availableBiometrics
          .contains(BiometricType.fingerprint)) {
        // Touch ID.
        bool authenticated = await _settingsBloc.authenticateWithBiometrics(
            'Scan your fingerprint to authenticate');
        if (authenticated) {
          setState(() {
            _settingsBloc.setBiometricsFingerprint(
                !_settingsBloc.getBiometricsFingerprint());
          });
          Flushbar(
            messageText: Text(
              'Fingerprint has been ' +
                  (_settingsBloc.getBiometricsFingerprint()
                      ? 'enabled'
                      : 'disabled'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: HermezColors.blackTwo,
                fontSize: 16,
                fontFamily: 'ModernEra',
                fontWeight: FontWeight.w700,
              ),
            ),
            boxShadows: [
              BoxShadow(
                color: HermezColors.blueyGreyTwo.withAlpha(64),
                offset: Offset(0, 4),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
            borderColor: HermezColors.blueyGreyTwo.withAlpha(64),
            borderRadius: BorderRadius.all(Radius.circular(12)),
            backgroundColor: Colors.white,
            margin: EdgeInsets.all(16.0),
            duration: Duration(seconds: FLUSHBAR_AUTO_HIDE_DURATION),
          ).show(context);
        }
      }
    }
  }
}
