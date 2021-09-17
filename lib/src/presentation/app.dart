import 'package:flutter/material.dart';
import 'package:hermez/router.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hermez Wallet',
      initialRoute: '/',
      routes: getRoutes(context),
      theme: ThemeData(
          primarySwatch: primaryWhite,
          accentColor: primaryOrange,
          buttonTheme: ButtonThemeData(
            buttonColor: primaryOrange,
            textTheme: ButtonTextTheme.accent,
          ),
          fontFamily: 'ModernEra'),
      /*home: BlocProvider(
        bloc: getIt<WalletBloc>(),
        child: HomePage(),
      ),*/
    );
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
