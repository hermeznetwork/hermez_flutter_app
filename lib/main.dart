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
      title: 'Polygon Hermez',
      initialRoute: '/',
      routes: getRoutes(context),
      /*navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],*/
      theme: ThemeData(
          colorScheme: HermezColors.appColorScheme,
          scaffoldBackgroundColor: HermezColors.appColorScheme.background,
          appBarTheme: AppBarTheme(
              backgroundColor: HermezColors.appColorScheme.background,
              foregroundColor: HermezColors.dark,
              elevation: 0.0),
          buttonTheme: ButtonThemeData(
            buttonColor: HermezColors.primary,
            textTheme: ButtonTextTheme.accent,
          ),
          fontFamily: 'ModernEra'),
    );
  }
}
