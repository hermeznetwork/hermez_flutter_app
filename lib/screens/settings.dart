import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/wallet/backup_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/settings_details.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/pop_result.dart';

//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class SettingsPage extends HookWidget {
  SettingsPage(this.store, this.configurationService, this.parentContext,
      this.onForceExitSuccess);

  WalletHandler store;
  ConfigurationService configurationService;
  BuildContext parentContext;
  Function() onForceExitSuccess;

  @override
  Widget build(BuildContext context) {
    //final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      //key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("Settings",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
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
              Navigator.of(parentContext).pushNamed("/backup_info");
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
                  child: SvgPicture.asset("assets/arrow_right.svg",
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
                    Navigator.of(context).pushNamed("settings_details",
                        arguments: SettingsDetailsArguments(
                            store, parentContext, SettingsDetailsType.GENERAL));
                    break;
                  case 2:
                    Navigator.of(context).pushNamed("settings_details",
                        arguments: SettingsDetailsArguments(store,
                            parentContext, SettingsDetailsType.SECURITY));
                    break;
                  case 3:
                    Navigator.of(context)
                        .pushNamed("settings_details",
                            arguments: SettingsDetailsArguments(store,
                                parentContext, SettingsDetailsType.ADVANCED))
                        .then((results) {
                      if (results is PopWithResults) {
                        PopWithResults popResult = results;
                        if (popResult.toPage == "/home") {
                          if (this.onForceExitSuccess != null) {
                            this.onForceExitSuccess();
                          }
                        }
                      }
                    });
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
