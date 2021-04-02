import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/wallet/backup_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class AccountSettingsPage extends HookWidget {
  AccountSettingsPage(this.store, this.configurationService);

  WalletHandler store;
  ConfigurationService configurationService;

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

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
        child: Column(
          children: <Widget>[
            Container(
              color: HermezColors.lightOrange,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.only(top: 44.0, bottom: 20.0),
                  child: Text(
                    (store.state.txLevel == TransactionLevel.LEVEL2
                                ? "hez:"
                                : "") +
                            "0x" +
                            AddressUtils.strip0x(
                                    store.state.ethereumAddress.substring(0, 6))
                                .toUpperCase() +
                            " ･･･ " +
                            store.state.ethereumAddress
                                .substring(
                                    store.state.ethereumAddress.length - 5,
                                    store.state.ethereumAddress.length)
                                .toUpperCase() ??
                        "",
                    style: TextStyle(
                      color: HermezColors.blackTwo,
                      fontSize: 20,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.only(bottom: 24.0),
                color: HermezColors.lightOrange,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      height: 44,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(56.0),
                          side: BorderSide(color: HermezColors.mediumOrange)),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed("/qrcode", arguments: store);
                      },
                      color: HermezColors.mediumOrange,
                      textColor: HermezColors.steel,
                      child: Wrap(
                        children: [
                          Image.asset(
                            'assets/qr_code.png',
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            "Show QR",
                            style: TextStyle(
                              color: HermezColors.steel,
                              fontSize: 16,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.0),
                    FlatButton(
                      height: 44,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(56.0),
                          side: BorderSide(color: HermezColors.mediumOrange)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text:
                                (store.state.txLevel == TransactionLevel.LEVEL2
                                        ? "hez:"
                                        : "") +
                                    store.state.ethereumAddress));
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text("Copied"),
                        ));
                      },
                      color: HermezColors.mediumOrange,
                      textColor: HermezColors.steel,
                      child: Wrap(
                        children: [
                          Image.asset(
                            'assets/paste.png',
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            "Copy",
                            style: TextStyle(
                              color: HermezColors.steel,
                              fontSize: 16,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )

                /*FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.grey[300])),
                  onPressed: () {

                  },
                  padding: EdgeInsets.all(6.0),
                  color: Colors.grey[300],
                  textColor: Colors.black,
                  child: ListTile(
                    // get the first letter of each crypto with the color
                    title:
                    trailing: Icon(Icons.content_copy),
                  ),
                ),*/
                ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: buildSettingsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSettingsList() {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: configurationService.didBackupWallet() ? 3 : 4,
        separatorBuilder: (BuildContext context, int index) {
          if (index == 0 && !configurationService.didBackupWallet()) {
            return Container();
          } else {
            return Container(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(color: HermezColors.steel));
          }
        },
        //set the item count so that index won't be out of range
        padding: const EdgeInsets.all(16.0),
        //add some padding to make it look good
        itemBuilder: (context, i) {
          //item builder returns a row for each index i=0,1,2,3,4
          // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

          // final index = i ~/ 2; //get the actual index excluding dividers.

          if (!configurationService.didBackupWallet() && i == 0) {
            return BackupRow(() {
              Navigator.of(context).pushNamed("/backup_info");
            });
          } else {
            String title = "";

            final index = i + (configurationService.didBackupWallet() ? 1 : 0);
            switch (index) {
              case 1:
                title = "General";
                break;
              case 2:
                title = "Security";
                break;
              case 3:
                title = "Advanced";
                break;
            }

            return ListTile(
              trailing: Container(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Image.asset("assets/arrow_right.png",
                      height: 12, color: HermezColors.blackTwo)),
              title: Align(
                alignment: Alignment.centerLeft,
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
                  case 1:
                    //Navigator.of(context)
                    //    .pushNamed("/currency_selector", arguments: store);
                    break;
                  case 2:
                    //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));
                    break;
                  case 3:
                    // viewInExplorer();
                    break;
                }
              },
            ); //iterate through indexes and get the next colour
            //return _buildRow(context, element, color); //build the row widget
          }
        },
      ),
    );
  }
}
