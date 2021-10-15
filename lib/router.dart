import 'package:flutter/material.dart';
import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/presentation/accounts/widgets/account_selector.dart';
import 'package:hermez/src/presentation/home/widgets/home.dart';
import 'package:hermez/src/presentation/home/widgets/info.dart';
import 'package:hermez/src/presentation/onboarding/widgets/first_deposit.dart';
import 'package:hermez/src/presentation/onboarding/widgets/import.dart';
import 'package:hermez/src/presentation/onboarding/widgets/intro.dart';
import 'package:hermez/src/presentation/qrcode/widgets/qrcode.dart';
import 'package:hermez/src/presentation/qrcode/widgets/qrcode_scanner.dart';
import 'package:hermez/src/presentation/security/widgets/pin.dart';
import 'package:hermez/src/presentation/settings/widgets/backup_info.dart';
import 'package:hermez/src/presentation/settings/widgets/recovery_phrase.dart';
import 'package:hermez/src/presentation/settings/widgets/recovery_phrase_confirm.dart';
import 'package:hermez/src/presentation/settings/widgets/remove_account_info.dart';
import 'package:hermez/src/presentation/settings/widgets/settings.dart';
import 'package:hermez/src/presentation/settings/widgets/settings_details.dart';
import 'package:hermez/src/presentation/transactions/widgets/transaction_details.dart';
import 'package:hermez/src/presentation/transfer/widgets/transaction_amount.dart';

import 'dependencies_provider.dart';

Map<String, WidgetBuilder> getRoutes(context) {
  return {
    '/': (BuildContext context) {
      var configurationService = getIt<IConfigurationService>();
      if (configurationService.didSetupWallet()) {
        return PinPage(
          arguments: PinArguments(
            "Enter passcode",
            false,
            false,
            onSuccess: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        );
      } else {
        return IntroPage();
      }
    },

    // ONBOARDING
    '/info': (BuildContext context) {
      return InfoPage(arguments: ModalRoute.of(context).settings.arguments);
    },
    '/first_deposit': (BuildContext context) {
      bool showHermezWallet = ModalRoute.of(context).settings.arguments;
      return FirstDepositPage(
          arguments: FirstDepositArguments(showHermezWallet));
    },
    '/qrcode': (BuildContext context) =>
        QRCodePage(arguments: ModalRoute.of(context).settings.arguments),

    // HOME
    '/settings': (BuildContext context) {
      return SettingsPage(null, null, context, null);
    },
    '/settings_details': (BuildContext context) {
      return SettingsDetailsPage(
        arguments: ModalRoute.of(context).settings.arguments,
      );
    },
    '/remove_account_info': (BuildContext context) {
      return RemoveAccountInfoPage(ModalRoute.of(context).settings.arguments);
    },
    '/backup_info': (BuildContext context) {
      return BackupInfoPage();
    },

    '/import': (BuildContext context) {
      return ImportWalletPage();
    },
    '/pin': (BuildContext context) {
      return PinPage(arguments: ModalRoute.of(context).settings.arguments);
    },
    '/home': (BuildContext context) {
      var configurationService = getIt<IConfigurationService>();
      if (configurationService.didSetupWallet()) {
        final bool showHermezWallet = ModalRoute.of(context).settings.arguments;
        HomeArguments args;
        if (showHermezWallet != null) {
          args = HomeArguments(showHermezWallet: showHermezWallet);
        } else {
          args = HomeArguments();
        }
        return HomePage(arguments: args);
      } else {
        return IntroPage();
      }
    },
    '/scanner': (BuildContext context) {
      return QRCodeScannerPage(
          arguments: ModalRoute.of(context).settings.arguments);
    },

    // SETTINGS
    '/recovery_phrase': (BuildContext context) {
      return RecoveryPhrasePage(
        arguments: ModalRoute.of(context).settings.arguments,
      );
    },
    '/recovery_phrase_confirm': (BuildContext context) {
      return RecoveryPhraseConfirmPage();
    },

    '/transaction_details': (BuildContext context) =>
        /*WalletTransferProvider(
      builder: (context, store) {*/
        TransactionDetailsPage(
            arguments: ModalRoute.of(context).settings.arguments),
    /*'/pin': (BuildContext context) {
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

    '/fee_selector': (BuildContext context) {
      return FeeSelectorPage(
          arguments: ModalRoute.of(context).settings.arguments);
    },
    '/move_info': (BuildContext context) {
      return MoveInfoPage(arguments: ModalRoute.of(context).settings.arguments);
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
    */

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
    /*'/import': (BuildContext context) => WalletSetupProvider(
          builder: (context, store) {
            return ImportWalletPage(store: store);
          },
        ),*/
    //'/amount': (BuildContext context) => AmountPage(),
    /*'/receiver': (BuildContext context) =>
        ReceiverPage(arguments: ModalRoute.of(context).settings.arguments),*/
    '/transaction_amount': (BuildContext context) => TransactionAmountPage(
        arguments: ModalRoute.of(context).settings.arguments),
    '/account_selector': (BuildContext context) =>
        /*var configurationService = Provider.of<ConfigurationService>(context);
      if (configurationService.didSetupWallet())
        return WalletProvider(builder: (context, store) {*/
        AccountSelectorPage(
            arguments: ModalRoute.of(context).settings.arguments),
    /*});
      return WalletSetupProvider(builder: (context, store) {
        return IntroPage();
      });
    },*/
    /*'/transfer': (BuildContext context) => WalletTransferProvider(
          builder: (context, store) {
            return WalletTransferPage(title: "Send Tokens");
          },
        ),*/
  };
}
