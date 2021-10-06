import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/settings/usecases/address_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/biometrics_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/default_currency_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/default_fee_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/explorer_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/level_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/private_settings_use_case.dart';
import 'package:hermez/src/domain/settings/usecases/reset_default_use_case.dart';
import 'package:hermez/src/domain/tokens/token.dart';
import 'package:hermez/src/domain/tokens/usecases/tokens_use_case.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez/src/presentation/settings/settings_state.dart';
import 'package:local_auth/local_auth.dart';

class SettingsBloc extends Bloc<SettingsState> {
  final DefaultCurrencyUseCase _defaultCurrencyUseCase;
  final DefaultFeeUseCase _defaultFeeUseCase;
  final LevelUseCase _levelUseCase;
  final BiometricsUseCase _biometricsUseCase;
  final ExplorerUseCase _explorerUseCase;
  final AddressUseCase _addressUseCase;
  final TokensUseCase _tokensUseCase;
  final ResetDefaultUseCase _resetDefaultUseCase;
  final PrivateSettingsUseCase _privateSettingsUseCase;

  SettingsItemState _itemState;

  SettingsBloc(
      this._defaultCurrencyUseCase,
      this._defaultFeeUseCase,
      this._levelUseCase,
      this._biometricsUseCase,
      this._explorerUseCase,
      this._addressUseCase,
      this._tokensUseCase,
      this._resetDefaultUseCase,
      this._privateSettingsUseCase) {
    changeState(SettingsState.init());
  }

  init() async {
    changeState(SettingsState.loading());
    WalletDefaultCurrency defaultCurrency = await getDefaultCurrency();
    WalletDefaultFee defaultFee = await getDefaultFee();
    TransactionLevel level = await getLevel();
    List<BiometricType> availableBiometrics = await getAvailableBiometrics();
    String hermezAddress = await getHermezAddress();
    String ethereumAddress = await getEthereumAddress();
    List<Token> tokens = await getTokens();
    _itemState = SettingsItemState(
        hermezAddress,
        ethereumAddress,
        defaultCurrency,
        defaultFee,
        /*exchangeRatio,*/ level,
        availableBiometrics,
        tokens);
    changeState(SettingsState.loaded(_itemState));
  }

  Future<WalletDefaultCurrency> getDefaultCurrency() async {
    return await _defaultCurrencyUseCase.getDefaultCurrency();
  }

  void setDefaultCurrency(WalletDefaultCurrency defaultCurrency) {
    changeState(SettingsState.loading());
    _defaultCurrencyUseCase.setDefaultCurrency(defaultCurrency).then((value) {
      _itemState.defaultCurrency = defaultCurrency;
      changeState(SettingsState.loaded(_itemState));
    });
  }

  Future<WalletDefaultFee> getDefaultFee() async {
    return await _defaultFeeUseCase.getDefaultFee();
  }

  void setDefaultFee(WalletDefaultFee defaultFee) {
    changeState(SettingsState.loading());
    _defaultFeeUseCase.setDefaultFee(defaultFee).then((value) {
      _itemState.defaultFee = defaultFee;
      changeState(SettingsState.loaded(_itemState));
    });
  }

  Future<TransactionLevel> getLevel() async {
    return await _levelUseCase.getLevel();
  }

  void setLevel(TransactionLevel level) {
    _levelUseCase.setLevel(level).then((value) {
      _itemState.level = level;
      changeState(SettingsState.loaded(_itemState));
    }).catchError((error) {
      changeState(SettingsState.error('A network error has occurred'));
    });
  }

  // Biometrics

  Future<bool> authenticateWithBiometrics(String infoDescription) {
    return _biometricsUseCase.authenticateWithBiometrics(infoDescription);
  }

  Future<List<BiometricType>> getAvailableBiometrics() {
    return _biometricsUseCase.getAvailableBiometrics();
  }

  bool getBiometricsFace() {
    return _biometricsUseCase.getBiometricsFace();
  }

  void setBiometricsFace(bool value) {
    _biometricsUseCase.setBiometricsFace(value);
  }

  bool getBiometricsFingerprint() {
    return _biometricsUseCase.getBiometricsFingerprint();
  }

  void setBiometricsFingerprint(bool value) {
    _biometricsUseCase.setBiometricsFingerprint(value);
  }

  // Explorer

  void showInBatchExplorer(String hermezAddress) {
    _explorerUseCase.showInBatchExplorer(hermezAddress);
  }

  // Address

  Future<String> getHermezAddress() async {
    return _addressUseCase.getHermezAddress();
    /*.then((hermezAddress) {
      //state.settings.hermezAddress = hermezAddress;
      changeState(SettingsState.loaded(state.settings));
      return hermezAddress;
    });*/
  }

  Future<String> getEthereumAddress() async {
    return _addressUseCase.getEthereumAddress();
    /*.then((ethereumAddress) {
      state.settings.ethereumAddress = ethereumAddress;
      changeState(SettingsState.loaded(state.settings));
      return ethereumAddress;
    });*/
  }

  // Tokens

  Future<List<Token>> getTokens() async {
    return _tokensUseCase.getTokens();
  }

  // Private

  Future<String> getRecoveryPhase() {
    return _privateSettingsUseCase.getRecoveryPhrase();
  }

  Future<bool> resetDefault() async {
    return _resetDefaultUseCase.resetDefault();
  }
}
