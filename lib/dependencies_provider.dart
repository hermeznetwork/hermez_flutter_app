import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hermez/environment.dart';
import 'package:hermez/secrets/keys.dart';
import 'package:hermez/src/data/network/address_service.dart';
import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/data/network/contract_service.dart';
import 'package:hermez/src/data/network/explorer_service.dart';
import 'package:hermez/src/data/network/hermez_service.dart';
import 'package:hermez/src/data/network/price_updater_service.dart';
import 'package:hermez/src/data/network/storage_service.dart';
import 'package:hermez/src/data/onboarding/onboarding_in_network_repository.dart';
import 'package:hermez/src/data/security/security_in_local_repository.dart';
import 'package:hermez/src/data/wallets/wallet_in_network_repository.dart';
import 'package:hermez/src/domain/onboarding/onboarding_repository.dart';
import 'package:hermez/src/domain/onboarding/usecases/confirm_mnemonic_use_case.dart';
import 'package:hermez/src/domain/onboarding/usecases/create_mnemonic_use_case.dart';
import 'package:hermez/src/domain/onboarding/usecases/import_private_key_use_case.dart';
import 'package:hermez/src/domain/security/security_repository.dart';
import 'package:hermez/src/domain/security/usecases/authenticate_biometrics_use_case.dart';
import 'package:hermez/src/domain/security/usecases/check_biometrics_use_case.dart';
import 'package:hermez/src/domain/security/usecases/check_pin_use_case.dart';
import 'package:hermez/src/domain/security/usecases/confirm_pin_use_case.dart';
import 'package:hermez/src/domain/security/usecases/create_pin_use_case.dart';
import 'package:hermez/src/domain/wallets/get_wallets_use_case.dart';
import 'package:hermez/src/domain/wallets/wallet_repository.dart';
import 'package:hermez/src/presentation/onboarding/onboarding_bloc.dart';
import 'package:hermez/src/presentation/security/security_bloc.dart';
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
  registerWalletDependencies();
  registerSettingsDependencies();
  registerOnboardingDependencies();
  registerSecurityDependencies();
  registerTransferDependencies();
  registerAccountDependencies();
  registerTransactionDependencies();
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
}

void registerWalletDependencies() {
  getIt.registerFactory(() => WalletsBloc(getIt()));

  getIt.registerLazySingleton(() => GetWalletsUseCase(getIt()));

  getIt.registerLazySingleton<WalletRepository>(() =>
      WalletInNetworkRepository(getIt(), getIt(), getIt(), getIt(), null, null
          /*getIt(), getIt(), getIt(), getIt(), getIt(), getIt()*/));
}

void registerSettingsDependencies() {}

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

void registerSecurityDependencies() {
  getIt.registerFactory(
      () => SecurityBloc(getIt(), getIt(), getIt(), getIt(), getIt()));

  getIt.registerLazySingleton(() => CreatePinUseCase(getIt()));

  getIt.registerLazySingleton(() => ConfirmPinUseCase(getIt()));

  getIt.registerLazySingleton(() => CheckPinUseCase(getIt()));

  getIt.registerLazySingleton(() => CheckBiometricsUseCase(getIt()));

  getIt.registerLazySingleton(() => AuthenticateBiometricsUseCase(getIt()));

  getIt.registerLazySingleton<SecurityRepository>(
      () => SecurityInLocalRepository(getIt()));
}

void registerTransferDependencies() {}

void registerAccountDependencies() {}

void registerTransactionDependencies() {}
