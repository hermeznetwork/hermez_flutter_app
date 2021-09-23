import 'package:flutter/material.dart';
import 'package:hermez/dependencies_provider.dart';
import 'package:hermez/src/presentation/home/widgets/info.dart';
import 'package:hermez/src/presentation/onboarding/onboarding_bloc.dart';
import 'package:hermez/src/presentation/security/widgets/pin.dart';
import 'package:hermez/utils/hermez_colors.dart';

class IntroPage extends StatelessWidget {
  final OnboardingBloc _bloc;

  IntroPage() : _bloc = getIt<OnboardingBloc>();
  /* {
    _bloc.fetchData();
  }*/

  @override
  Widget build(BuildContext context) {
    //final store = useWalletSetup(context);
    //final bloc = BlocProvider.of<WalletsBloc>(context);

    return Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        backgroundColor: HermezColors.lightOrange,
      ),
      backgroundColor: HermezColors.lightOrange,
      body: SafeArea(
        child: Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: new Center(
                  child: SingleChildScrollView(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/intro_hermez_logo.png',
                          width: 120,
                          height: 120,
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Text(
                            'Secure wallet for low-cost\n token transfers',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: HermezColors.steel,
                              fontSize: 18,
                              height: 1.8,
                              decoration: TextDecoration.none,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
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
                        var success = await Navigator.of(context).pushNamed(
                            "/pin",
                            arguments: PinArguments(null, true, false));
                        if (success != null && success == true) {
                          String mnemonic = await _bloc.generateMnemonic();
                          Navigator.of(context).pushNamed("/info",
                              arguments: InfoArguments(
                                  "info_backup_success.png",
                                  false,
                                  "Your wallet has been created",
                                  iconSize: 300, onFinished: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    "/first_deposit",
                                    (Route<dynamic> route) => false,
                                    arguments: true);
                              }));
                        }
                      },
                      padding: EdgeInsets.only(
                          top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                      disabledTextColor: Colors.grey,
                      disabledColor: Colors.blueGrey,
                      color: HermezColors.darkOrange,
                      textColor: Colors.white,
                      child: Text("Create new wallet",
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
                        Navigator.of(context).pushNamed("/import");
                      },
                      padding: EdgeInsets.only(
                          top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                      disabledTextColor: Colors.grey,
                      textColor: HermezColors.blackTwo,
                      child: Text("Import a wallet",
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

/*return StreamBuilder<WalletsState>(
        initialData: _bloc.state,
        stream: _bloc.observableState,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is LoadingWalletsState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ErrorWalletsState) {
            return Center(child: Text(state.message));
          } else {
            return Container(); /*_renderIntroContent(context, state);*/
          }
        });
  }
}*/
