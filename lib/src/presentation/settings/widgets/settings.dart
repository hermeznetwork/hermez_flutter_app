import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/wallet/backup_row.dart';
import 'package:hermez/dependencies_provider.dart';
import 'package:hermez/src/presentation/settings/settings_bloc.dart';
import 'package:hermez/src/presentation/settings/settings_state.dart';
import 'package:hermez/src/presentation/settings/widgets/settings_details.dart';
import 'package:hermez/src/presentation/wallets/wallets_bloc.dart';
import 'package:hermez/src/presentation/wallets/wallets_state.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/pop_result.dart';

//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class SettingsPage extends StatelessWidget {
  WalletsBloc _walletsBloc;
  SettingsBloc _settingsBloc;
  BuildContext parentContext;
  Function() onForceExitSuccess;

  SettingsPage(WalletsBloc walletsBloc, SettingsBloc settingsBloc,
      this.parentContext, this.onForceExitSuccess)
      : _settingsBloc =
            settingsBloc != null ? settingsBloc : getIt<SettingsBloc>(),
        _walletsBloc =
            walletsBloc != null ? walletsBloc : getIt<WalletsBloc>() {
    if (!(_walletsBloc.state is LoadedWalletsState)) {
      _walletsBloc.fetchData();
    }
    if (_settingsBloc.state is InitSettingsState) {
      _settingsBloc.init();
    }
  }

  /*SettingsPage(this.parentContext, this.onForceExitSuccess)
      : _walletsBloc = getIt<WalletsBloc>() {
    _walletsBloc.fetchData();
  }*/

  /*WalletsBloc _walletsBloc = getIt<WalletsBloc>() {};

  //final AccountsBloc _bloc;
  _AccountSelectorPageState() : _walletsBloc = getIt<WalletsBloc>() {
    fetchData();
  }*/

  /*void fetchData() {
    if ((widget.arguments.txLevel == TransactionLevel.LEVEL1 &&
        widget.arguments.transactionType != TransactionType.FORCEEXIT) ||
        widget.arguments.transactionType == TransactionType.DEPOSIT) {
      _bloc.getAccounts(LayerFilter.L1, widget.arguments.address);
    } else {
      _bloc.getAccounts(LayerFilter.L2, widget.arguments.address);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    //final bloc = BlocProvider.of<CartBloc>(context);

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
                child: StreamBuilder<WalletsState>(
                    initialData: _walletsBloc.state,
                    stream: _walletsBloc.observableState,
                    builder: (context, snapshot) {
                      final state = snapshot.data;

                      if (state is LoadingWalletsState) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ErrorWalletsState) {
                        return _renderErrorContent();
                      } else {
                        return _renderSettingsContent(context, state);
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderSettingsContent(
      BuildContext context, LoadedWalletsState state) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: state.wallets[0].isBackedUp ? 3 : 4,
        separatorBuilder: (BuildContext context, int index) {
          if (index == 0 && !state.wallets[0].isBackedUp) {
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

          if (!state.wallets[0].isBackedUp && i == 0) {
            return BackupRow(() {
              Navigator.of(parentContext).pushNamed("/backup_info");
            });
          } else {
            String title = "";

            final index = i + (state.wallets[0].isBackedUp ? 1 : 0);
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
                        arguments: SettingsDetailsArguments(parentContext,
                            SettingsDetailsType.GENERAL, _settingsBloc));
                    break;
                  case 2:
                    Navigator.of(context).pushNamed(
                      "settings_details",
                      arguments: SettingsDetailsArguments(parentContext,
                          SettingsDetailsType.SECURITY, _settingsBloc),
                    );
                    break;
                  case 3:
                    Navigator.of(context)
                        .pushNamed(
                      "settings_details",
                      arguments: SettingsDetailsArguments(parentContext,
                          SettingsDetailsType.ADVANCED, _settingsBloc),
                    )
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

  Widget _renderErrorContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34.0),
      child: Column(
        children: [
          Text(
            'There was an error loading \n\n this page.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HermezColors.blueyGrey,
              fontSize: 16,
              fontFamily: 'ModernEra',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
