import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hermez/environment.dart';
import 'package:hermez/secrets/keys.dart';
import 'package:hermez/src/data/accounts/account_in_network_repository.dart';
import 'package:hermez/src/data/network/address_service.dart';
import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/data/network/contract_service.dart';
import 'package:hermez/src/data/network/explorer_service.dart';
import 'package:hermez/src/data/network/hermez_service.dart';
import 'package:hermez/src/data/network/price_updater_service.dart';
import 'package:hermez/src/data/network/storage_service.dart';
import 'package:hermez/src/data/onboarding/onboarding_in_network_repository.dart';
import 'package:hermez/src/data/prices/price_in_network_repository.dart';
import 'package:hermez/src/data/qrcode/qrcode_in_local_repository.dart';
import 'package:hermez/src/data/security/security_in_local_repository.dart';
import 'package:hermez/src/data/settings/settings_in_local_repository.dart';
import 'package:hermez/src/data/tokens/tokens_in_network_repository.dart';
import 'package:hermez/src/data/transactions/transaction_in_network_repository.dart';
import 'package:hermez/src/data/transfer/transfer_in_network_repository.dart';
import 'package:hermez/src/data/wallets/wallet_in_network_repository.dart';
import 'package:hermez/src/domain/accounts/account_repository.dart';
import 'package:hermez/src/domain/accounts/usecases/get_account_use_case.dart';
import 'package:hermez/src/domain/accounts/usecases/get_accounts_use_case.dart';
import 'package:hermez/src/domain/onboarding/onboarding_repository.dart';
import 'package:hermez/src/domain/onboarding/usecases/confirm_mnemonic_use_case.dart';
import 'package:hermez/src/domain/onboarding/usecases/create_mnemonic_use_case.dart';
import 'package:hermez/src/domain/onboarding/usecases/import_private_key_use_case.dart';
import 'package:hermez/src/domain/prices/price_repository.dart';
import 'package:hermez/src/domain/qrcode/qrcode_repository.dart';
import 'package:hermez/src/domain/qrcode/usecases/qrcode_in_gallery_use_case.dart';
import 'package:hermez/src/domain/security/security_repository.dart';
import 'package:hermez/src/domain/security/usecases/authenticate_biometrics_use_case.dart';
import 'package:hermez/src/domain/security/usecases/check_biometrics_use_case.dart';
import 'package:hermez/src/domain/security/usecases/pin_use_case.dart';
import 'package:hermez/src/domain/settings/settings_repository.dart';
import 'package:hermez/src/domain/settings/usecases/address_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/biometrics_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/default_currency_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/default_fee_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/explorer_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/level_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/reset_default_use_case.dart';
import 'package:hermez/src/domain/tokens/token_repository.dart';
import 'package:hermez/src/domain/tokens/usecases/tokens_use_case.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez/src/domain/transactions/usecases/get_transactions_use_case.dart';
import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez/src/domain/transfer/usecases/deposit_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/exit_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/force_exit_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/transfer_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/withdraw_use_case.dart';
import 'package:hermez/src/domain/wallets/get_wallets_use_case.dart';
import 'package:hermez/src/domain/wallets/wallet_repository.dart';
import 'package:hermez/src/presentation/accounts/account_bloc.dart';
import 'package:hermez/src/presentation/onboarding/onboarding_bloc.dart';
import 'package:hermez/src/presentation/qrcode/qrcode_bloc.dart';
import 'package:hermez/src/presentation/security/security_bloc.dart';
import 'package:hermez/src/presentation/settings/settings_bloc.dart';
import 'package:hermez/src/presentation/tokens/tokens_bloc.dart';
import 'package:hermez/src/presentation/transactions/transactions_bloc.dart';
import 'package:hermez/src/presentation/transfer/transfer_bloc.dart';
import 'package:hermez/src/presentation/wallets/wallets_bloc.dart';
import 'package:hermez_sdk/hermez_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'environment.dart';
import 'src/domain/onboarding/usecases/check_mnemonic_use_case.dart';
import 'src/domain/onboarding/usecases/import_mnemonic_use_case.dart';

final getIt = GetIt.instance;

Future<void> init(EnvParams walletParams) async {
  await registerProviders(walletParams);
  registerOnboardingDependencies();
  registerSettingsDependencies();
  registerSecurityDependencies();
  registerQRCodeDependencies();
  registerWalletDependencies();
  registerAccountDependencies();
  registerTokenDependencies();
  registerTransactionDependencies();
  registerTransferDependencies();
}

Future<void> registerProviders(walletParams) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  getIt.registerLazySingleton(() => FlutterSecureStorage());

  getIt.registerLazySingleton(() => StorageService(getIt(), getIt()));

  getIt.registerLazySingleton<IConfigurationService>(
      () => ConfigurationService(getIt(), getIt(), getIt()));

  getIt.registerLazySingleton<IAddressService>(() => AddressService(getIt()));

  getIt.registerLazySingleton<IHermezService>(() => HermezService(getIt()));

  getIt.registerLazySingleton<PriceUpdaterService>(() => PriceUpdaterService(
      walletParams.priceUpdaterApiUrl, walletParams.priceUpdaterApiKey));

  final client = HermezSDK.currentWeb3Client;
  getIt.registerLazySingleton(() => ContractService(
      client, getIt(), ETH_GAS_PRICE_URL, ETH_GAS_STATION_API_KEY));

  getIt.registerLazySingleton(
      () => ExplorerService(walletParams.etherscanApiUrl, ETHERSCAN_API_KEY));

  getIt.registerLazySingleton<PriceRepository>(() => PriceInNetworkRepository(
      walletParams.priceUpdaterApiUrl, walletParams.priceUpdaterApiKey));
}

void registerQRCodeDependencies() {
  getIt.registerFactory(() => QrcodeBloc(getIt()));

  getIt.registerLazySingleton(() => QrcodeInGalleryUseCase(getIt()));

  getIt.registerLazySingleton<QrcodeRepository>(
      () => QrcodeInLocalRepository(getIt()));
}

void registerOnboardingDependencies() {
  getIt.registerFactory(
      () => OnboardingBloc(getIt(), getIt(), getIt(), getIt(), getIt()));

  getIt.registerLazySingleton(() => CreateMnemonicUseCase(getIt()));

  getIt.registerLazySingleton(() => ConfirmMnemonicUseCase(getIt()));

  getIt.registerLazySingleton(() => CheckMnemonicUseCase(getIt()));

  getIt.registerLazySingleton(() => ImportMnemonicUseCase(getIt()));

  getIt.registerLazySingleton(() => ImportPrivateKeyUseCase(getIt()));

  getIt.registerLazySingleton<OnboardingRepository>(
      () => OnboardingInNetworkRepository(getIt(), getIt()));
}

void registerSettingsDependencies() {
  getIt.registerFactory(() => SettingsBloc(
      getIt(), getIt(), getIt(), getIt(), getIt(), getIt(), getIt(), getIt()));

  getIt.registerLazySingleton(() => DefaultCurrencyUseCase(getIt()));

  getIt.registerLazySingleton(() => DefaultFeeUseCase(getIt()));

  getIt.registerLazySingleton(() => LevelUseCase(getIt()));

  getIt.registerLazySingleton(() => BiometricsUseCase(getIt()));

  getIt.registerLazySingleton(() => ExplorerUseCase(getIt()));

  getIt.registerLazySingleton(() => AddressUseCase(getIt()));

  getIt.registerLazySingleton(() => ResetDefaultUseCase(getIt()));

  //getIt.registerLazySingleton(() => TokensUseCase(getIt(), getIt()));

  getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsInLocalRepository(getIt()));
}

void registerSecurityDependencies() {
  getIt.registerFactory(() => SecurityBloc(getIt(), getIt(), getIt()));

  getIt.registerLazySingleton(() => PinUseCase(getIt()));

  getIt.registerLazySingleton(() => CheckBiometricsUseCase(getIt()));

  getIt.registerLazySingleton(() => AuthenticateBiometricsUseCase(getIt()));

  getIt.registerLazySingleton<SecurityRepository>(
      () => SecurityInLocalRepository(getIt()));
}

void registerWalletDependencies() {
  getIt.registerFactory(() => WalletsBloc(getIt()));

  getIt.registerLazySingleton(() => GetWalletsUseCase(getIt()));

  getIt.registerLazySingleton<WalletRepository>(() =>
      WalletInNetworkRepository(getIt(), getIt(), getIt(), getIt(), null, null
          /*getIt(), getIt(), getIt(), getIt(), getIt(), getIt()*/));
}

void registerAccountDependencies() {
  getIt.registerFactory(() => AccountBloc(getIt(), getIt(), getIt()));

  getIt.registerLazySingleton(
      () => GetAccountsUseCase(getIt(), getIt(), getIt()));

  getIt.registerLazySingleton(
      () => GetAccountUseCase(getIt(), getIt(), getIt()));

  getIt.registerLazySingleton<AccountRepository>(
      () => AccountInNetworkRepository(getIt(), getIt(), getIt()));
}

void registerTokenDependencies() {
  getIt.registerFactory(() => TokensBloc(getIt()));

  getIt.registerLazySingleton(() => TokensUseCase(getIt(), getIt()));

  getIt.registerLazySingleton<TokenRepository>(
      () => TokensInNetworkRepository());
}

void registerTransactionDependencies() {
  getIt.registerFactory(() => TransactionsBloc(getIt()));

  getIt.registerLazySingleton(() => GetAllTransactionsUseCase(getIt()));

  getIt.registerLazySingleton<TransactionRepository>(
      () => TransactionInNetworkRepository(getIt(), getIt(), getIt(), getIt()));
}

void registerTransferDependencies() {
  getIt.registerFactory(
      () => TransferBloc(getIt(), getIt(), getIt(), getIt(), getIt(), getIt()));

  getIt.registerLazySingleton(() => TransferUseCase(getIt()));

  getIt.registerLazySingleton(() => DepositUseCase(getIt()));

  getIt.registerLazySingleton(() => ExitUseCase(getIt()));

  getIt.registerLazySingleton(() => ForceExitUseCase(getIt()));

  getIt.registerLazySingleton(() => WithdrawUseCase(getIt()));

  getIt.registerLazySingleton<TransferRepository>(
      () => TransferInNetworkRepository(getIt(), getIt()));
}
