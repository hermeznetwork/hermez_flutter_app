//import 'package:firebase_analytics/firebase_analytics.dart';
//import 'package:firebase_analytics/observer.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/environment.dart';
import 'package:hermez/router.dart';
import 'package:hermez/services_provider.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:provider/provider.dart';

void main() async {
  // bootstrapping;
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // setEnvironment('goerli');
  setEnvironment('rinkeby');
  // setEnvironment('mainnet');

  final stores = await createProviders(getCurrentEnvironment());

  runApp(MultiProvider(
    providers: stores,
    child: MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  //MainApp();
  // Create the initialization Future outside of `build`:
  //final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  //final FirebaseAnalytics analytics = FirebaseAnalytics();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /* return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          /*if (snapshot.hasError) {
            return SomethingWentWrong();
          }*/

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {*/
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hermez Wallet',
      initialRoute: '/',
      routes: getRoutes(context),
      /*navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],*/
      theme: ThemeData(
          primarySwatch: HermezColors.primarySwatch,
          buttonTheme: ButtonThemeData(
            buttonColor: HermezColors.secondary,
            textTheme: ButtonTextTheme.accent,
          ),
          fontFamily: 'ModernEra'),
    );
  }

// Otherwise, show something whilst waiting for initialization to complete
/*return Container(
              color: Colors.white,
              child: Center(
                child: new CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(primaryOrange),
                ),
              ));*/
//});
//}
}

const MaterialColor primaryWhite = MaterialColor(
  _whitePrimaryValue,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(_whitePrimaryValue),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);
const int _whitePrimaryValue = 0xFFFFFFFF;

const MaterialColor primaryOrange = MaterialColor(
  _orangePrimaryValue,
  <int, Color>{
    50: Color(0xffffa600),
    100: Color(0xffffa600),
    200: Color(0xffffa600),
    300: Color(0xffffa600),
    400: Color(0xffffa600),
    500: Color(_orangePrimaryValue),
    600: Color(0xffffa600),
    700: Color(0xffffa600),
    800: Color(0xffffa600),
    900: Color(0xffffa600),
  },
);
const int _orangePrimaryValue = 0xffffa600;
