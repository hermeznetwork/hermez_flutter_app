import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/model/wallet_setup.dart';
import 'package:hermez/service/address_service.dart';

import 'wallet_setup_state.dart';

class WalletSetupHandler {
  WalletSetupHandler(this._store, this._addressService);

  final Store<WalletSetup, WalletSetupAction> _store;
  final AddressService _addressService;

  WalletSetup get state => _store.state;

  Future<String> generateMnemonic() async {
    String mnemonic = _addressService.generateMnemonic();
    _store.dispatch(WalletSetupConfirmMnemonic(mnemonic));
    try {
      return await _addressService.setupFromMnemonic(mnemonic);
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> confirmMnemonic(String mnemonic) async {
    if (state.mnemonic != mnemonic) {
      _store
          .dispatch(WalletSetupAddError("Invalid mnemonic, please try again."));
      return false;
    }
    _store.dispatch(WalletSetupStarted());

    await _addressService.setupFromMnemonic(mnemonic);

    return true;
  }

  void goto(WalletCreateSteps step) {
    _store.dispatch(WalletSetupChangeStep(step));
  }

  Future<bool> importFromMnemonic(String mnemonic) async {
    try {
      _store.dispatch(WalletSetupStarted());

      if (_validateMnemonic(mnemonic)) {
        final normalisedMnemonic = _mnemonicNormalise(mnemonic);
        return await _addressService.setupFromMnemonic(normalisedMnemonic) !=
            null;
      } else {
        return false;
      }
    } catch (e) {
      _store.dispatch(WalletSetupAddError(e.toString()));
    }

    _store.dispatch(
        WalletSetupAddError("Invalid mnemonic, it requires 12 words."));

    return false;
  }

  Future<bool> importFromPrivateKey(String privateKey) async {
    try {
      _store.dispatch(WalletSetupStarted());

      await _addressService.setupFromPrivateKey(privateKey);
      return true;
    } catch (e) {
      _store.dispatch(WalletSetupAddError(e.toString()));
    }

    _store.dispatch(
        WalletSetupAddError("Invalid private key, please try again."));

    return false;
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
