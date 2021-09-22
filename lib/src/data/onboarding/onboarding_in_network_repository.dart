import 'package:hermez/src/data/network/address_service.dart';
import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/domain/onboarding/onboarding_repository.dart';

class OnboardingInNetworkRepository implements OnboardingRepository {
  final IAddressService _addressService;
  final IConfigurationService _configurationService;
  OnboardingInNetworkRepository(
      this._addressService, this._configurationService);

  @override
  Future<String> generateMnemonic() async {
    String mnemonic = _addressService.generateMnemonic();
    try {
      return await _addressService.setupFromMnemonic(mnemonic);
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<bool> confirmMnemonic(String mnemonic) async {
    /*if (state.mnemonic != mnemonic) {
      _store
          .dispatch(WalletSetupAddError("Invalid mnemonic, please try again."));
      return false;
    }
    _store.dispatch(WalletSetupStarted());*/

    await _addressService.setupFromMnemonic(mnemonic);

    return true;
  }

  @override
  bool isValidMnemonic(String mnemonic) {
    if (_validateMnemonic(mnemonic)) {
      final normalisedMnemonic = _mnemonicNormalise(mnemonic);
      return _addressService.isValidMnemonic(normalisedMnemonic);
    } else {
      return false;
    }
  }

  @override
  Future<bool> importFromMnemonic(String mnemonic) async {
    try {
      if (isValidMnemonic(mnemonic)) {
        final normalisedMnemonic = _mnemonicNormalise(mnemonic);
        return await _addressService.setupFromMnemonic(normalisedMnemonic) !=
            null;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> importFromPrivateKey(String privateKey) async {
    try {
      final response = await _addressService.setupFromPrivateKey(privateKey);
      return response;
    } catch (e) {
      return false;
    }
  }

  String _mnemonicNormalise(String mnemonic) {
    return _mnemonicWords(mnemonic).join(" ");
  }

  List<String> _mnemonicWords(String mnemonic) {
    return mnemonic
        .split(" ")
        .where((item) => item != null && item.trim().isNotEmpty)
        .map((item) => item.trim())
        .toList();
  }

  bool _validateMnemonic(String mnemonic) {
    return _mnemonicWords(mnemonic).length == 12;
  }
}
