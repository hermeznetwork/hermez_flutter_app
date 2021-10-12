import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/dependencies_provider.dart' as di;
import 'package:hermez/environment.dart';
import 'package:hermez/src/presentation/app.dart';

void main() async {
  // bootstrapping;
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  setEnvironment('goerli');
  //setEnvironment('rinkeby');
  //setEnvironment('mainnet');
  await di.init(getCurrentEnvironment());
  //final stores = await createProviders(getCurrentEnvironment());

  runApp(App());

  /*runApp(MultiProvider(
    providers: stores,
    child: App(),
  ));*/
}
