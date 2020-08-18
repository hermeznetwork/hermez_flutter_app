import 'package:hermez/app_config.dart';
import 'package:hermez/router.dart';
import 'package:hermez/services_provider.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  // bootstrapping;
  WidgetsFlutterBinding.ensureInitialized();
  final stores = await createProviders(AppConfig().params["ropsten"]);

  runApp(MainApp(stores));
}

class MainApp extends StatelessWidget {
  MainApp(this.stores);
  final List<SingleChildCloneableWidget> stores;
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: stores,
        child: new MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter App',
          initialRoute: '/',
          routes: getRoutes(context),
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: primaryWhite,
            buttonTheme: ButtonThemeData(
              buttonColor: Colors.grey,
              textTheme: ButtonTextTheme.primary,
            ),
            fontFamily: 'ModernEra'
          ),
        ));
  }
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