import 'package:hermez/qrcode_reader_page.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/wallet_account_details_page.dart';
import 'package:hermez/wallet_create_page.dart';
import 'package:hermez/wallet_import_page.dart';
import 'package:hermez/wallet_home_page.dart';
import 'package:hermez/wallet_activity_page.dart';
import 'package:hermez/wallet_settings_page.dart';
import 'package:hermez/wallet_settings_qrcode_page.dart';
import 'package:hermez/wallet_settings_currency_page.dart';
import 'package:hermez/wallet_amount_page.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:hermez/wallet_transfer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'context/wallet/wallet_provider.dart';
import 'context/setup/wallet_setup_provider.dart';
import 'context/transfer/wallet_transfer_provider.dart';
import 'intro_page.dart';
import 'wallet_receiver_page.dart';

Map<String, WidgetBuilder> getRoutes(context) {
  return {
    '/': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet())
        return WalletProvider(builder: (context, store) {
          return WalletHomePage("Hermez");
        });

      return IntroPage();
    },
    '/activity': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet())
        return WalletProvider(builder: (context, store) {
          return WalletActivityPage("Hermez");
        });

      return IntroPage();
    },
    '/account_details': (BuildContext context) {
      // Cast the arguments to the correct type: ScreenArguments.
      final WalletAccountDetailsArguments args = ModalRoute.of(context).settings.arguments;
      var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet())
        return WalletProvider(builder: (context, store) {
          return WalletAccountDetailsPage(args);
        });
      return IntroPage();
    },
    '/settings': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet())
        return WalletProvider(builder: (context, store) {
          return SettingsPage();
        });
      return IntroPage();
    },
    '/qrcode': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet())
      return WalletProvider(builder: (context, store) {
        return SettingsQRCodePage();
      });
      return IntroPage();
    },
    '/currency_selector': (BuildContext context) => SettingsCurrencyPage(store: ModalRoute.of(context).settings.arguments),
        //(BuildContext context) {
      /*var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet())
        return WalletProvider(builder: (context, store) {
          return SettingsCurrencyPage();
        });
      return IntroPage();*/
    //},
    '/create': (BuildContext context) =>
        WalletSetupProvider(builder: (context, store) {
          useEffect(() {
            store.generateMnemonic();
            return null;
          }, []);

          return WalletCreatePage("Create wallet");
        }),
    '/import': (BuildContext context) => WalletSetupProvider(
          builder: (context, store) {
            return WalletImportPage("Import wallet");
          },
        ),
    '/amount': (BuildContext context) => AmountPage(),
    '/receiver': (BuildContext context) => ReceiverPage(arguments: ModalRoute.of(context).settings.arguments),
    '/transfer': (BuildContext context) => WalletTransferProvider(
          builder: (context, store) {
            return WalletTransferPage(title: "Send Tokens");
          },
        ),
    '/transfer_amount': (BuildContext context) => WalletTransferProvider(
      builder: (context, store) {
        return WalletTransferAmountPage();
      },
    ),
    '/qrcode_reader': (BuildContext context) => QRCodeReaderPage(
          title: "Scan QRCode",
          onScanned: ModalRoute.of(context).settings.arguments,
        )
  };
}
