import 'package:flutter/material.dart';
import 'package:hermez/screens/account_selector.dart';
import 'package:hermez/screens/backup_info.dart';
import 'package:hermez/screens/biometrics.dart';
import 'package:hermez/screens/fee_selector.dart';
import 'package:hermez/screens/first_deposit.dart';
import 'package:hermez/screens/home.dart';
import 'package:hermez/screens/import.dart';
import 'package:hermez/screens/info.dart';
import 'package:hermez/screens/intro.dart';
import 'package:hermez/screens/pin.dart';
import 'package:hermez/screens/qrcode.dart';
import 'package:hermez/screens/recovery_phrase.dart';
import 'package:hermez/screens/recovery_phrase_confirm.dart';
import 'package:hermez/screens/remove_account_info.dart';
import 'package:hermez/screens/scanner.dart';
import 'package:hermez/screens/settings_details.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/screens/transaction_details.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:provider/provider.dart';

import 'context/setup/wallet_setup_provider.dart';
import 'context/transfer/wallet_transfer_provider.dart';
import 'context/wallet/wallet_provider.dart';

Map<String, WidgetBuilder> getRoutes(context) {
  return {
    '/': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet()) {
        return PinPage(
            arguments: PinArguments("Enter passcode", false, () {
              Navigator.pushReplacementNamed(context, '/home');
            }),
            configurationService: configurationService);
      } else {
        return WalletSetupProvider(builder: (context, store) {
          return IntroPage();
        });
      }
    },
    '/home': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet()) {
        return WalletProvider(builder: (context, store) {
          return HomePage(store, configurationService);
        });
      } else {
        return WalletSetupProvider(builder: (context, store) {
          return IntroPage();
        });
      }
    },
    '/pin': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      return PinPage(
          arguments: ModalRoute.of(context).settings.arguments,
          configurationService: configurationService);
    },
    '/info': (BuildContext context) {
      return InfoPage(arguments: ModalRoute.of(context).settings.arguments);
    },
    '/biometrics': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      return BiometricsPage(
          arguments: ModalRoute.of(context).settings.arguments,
          configurationService: configurationService);
    },
    '/backup_info': (BuildContext context) {
      return BackupInfoPage();
    },
    '/recovery_phrase': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      return RecoveryPhrasePage(
          arguments: ModalRoute.of(context).settings.arguments,
          configurationService: configurationService);
    },
    '/recovery_phrase_confirm': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      return RecoveryPhraseConfirmPage(
          configurationService: configurationService);
    },
    '/settings_details': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      return SettingsDetailsPage(
          arguments: ModalRoute.of(context).settings.arguments,
          configurationService: configurationService);
    },
    '/fee_selector': (BuildContext context) {
      return FeeSelectorPage(
          arguments: ModalRoute.of(context).settings.arguments);
    },
    '/remove_account_info': (BuildContext context) {
      return RemoveAccountInfoPage(ModalRoute.of(context).settings.arguments);
    },
    /*'/account_details': (BuildContext context) {
      // Cast the arguments to the correct type: ScreenArguments.
      final WalletAccountDetailsArguments args =
          ModalRoute.of(context).settings.arguments;
      var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet())
        return WalletProvider(builder: (context, store) {
          return WalletAccountDetailsPage(args);
        });
      return WalletSetupProvider(builder: (context, store) {
        return IntroPage();
      });
    },*/
    '/scanner': (BuildContext context) {
      return QRCodeScannerPage(
          arguments: ModalRoute.of(context).settings.arguments);
    },
    '/qrcode': (BuildContext context) =>
        QRCodePage(arguments: ModalRoute.of(context).settings.arguments),
    //'/currency_selector': (BuildContext context) =>
    //    SettingsCurrencyPage(store: ModalRoute.of(context).settings.arguments),
    '/first_deposit': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet()) {
        return WalletProvider(builder: (context, store) {
          return FirstDepositPage(store: store);
        });
      }
      return WalletSetupProvider(builder: (context, store) {
        return IntroPage();
      });
    },

    //(BuildContext context) {
    /*var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet())
        return WalletProvider(builder: (context, store) {
          return SettingsCurrencyPage();
        });
      return IntroPage();*/
    //},
    /*'/create': (BuildContext context) =>
        WalletSetupProvider(builder: (context, store) {
          useEffect(() {
            store.generateMnemonic();
            return null;
          }, []);

          return WalletCreatePage("Create wallet");
        }),*/
    '/import': (BuildContext context) => WalletSetupProvider(
          builder: (context, store) {
            return ImportWalletPage(store: store);
          },
        ),
    //'/amount': (BuildContext context) => AmountPage(),
    /*'/receiver': (BuildContext context) =>
        ReceiverPage(arguments: ModalRoute.of(context).settings.arguments),*/
    '/account_selector': (BuildContext context) {
      var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet())
        return WalletProvider(builder: (context, store) {
          return AccountSelectorPage(ModalRoute.of(context).settings.arguments);
        });
      return WalletSetupProvider(builder: (context, store) {
        return IntroPage();
      });
    },
    /*'/transfer': (BuildContext context) => WalletTransferProvider(
          builder: (context, store) {
            return WalletTransferPage(title: "Send Tokens");
          },
        ),*/
    '/transaction_amount': (BuildContext context) => TransactionAmountPage(
        arguments: ModalRoute.of(context).settings.arguments),
    '/transaction_details': (BuildContext context) => WalletTransferProvider(
          builder: (context, store) {
            return TransactionDetailsPage(
                arguments: ModalRoute.of(context).settings.arguments);
          },
        ),
  };
}
