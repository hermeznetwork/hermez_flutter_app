import 'dart:convert';

import 'package:bip39/bip39.dart' as bip39;
import 'package:hermez/constants.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hd_key.dart';
import 'package:hermez_sdk/addresses.dart' as addresses;
import 'package:hermez_sdk/hermez_wallet.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';

abstract class IAddressService {
  String generateMnemonic();
  String entropyToMnemonic(String entropyMnemonic);
  Future<String> setupFromMnemonic(String mnemonic);
  Future<bool> setupFromPrivateKey(String privateKey);
  String getPrivateKey(String mnemonic);
  Future<String> getHermezPrivateKey(String privateKey);
  Future<String> getBabyJubJubHex(String privateKey);
  Future<String> getBabyJubJubBase64(String privateKey);
  Future<String> getEthereumAddress(String privateKey);
  Future<String> getHermezAddress(String privateKey);
}

class AddressService implements IAddressService {
  IConfigurationService _configService;
  AddressService(this._configService);

  @override
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  String entropyToMnemonic(String entropyMnemonic) {
    return bip39.entropyToMnemonic(entropyMnemonic);
  }

  bool isValidMnemonic(String mnemonic) {
    try {
      final cryptMnemonic = bip39.mnemonicToEntropy(mnemonic);
      final privateKey = getPrivateKey(mnemonic);
      return cryptMnemonic != null &&
          privateKey != null &&
          cryptMnemonic.isNotEmpty &&
          privateKey.isNotEmpty;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<String> setupFromMnemonic(String mnemonic) async {
    try {
      final cryptMnemonic = bip39.mnemonicToEntropy(mnemonic);
      final privateKey = getPrivateKey(mnemonic);
      final hermezPrivateKey = await getHermezPrivateKey(privateKey);
      final ethereumAddress = await getEthereumAddress(privateKey);
      final hermezAddress = await getHermezAddress(privateKey);
      final babyJubJubHex = await getBabyJubJubHex(privateKey);
      final babyJubJubBase64 = await getBabyJubJubBase64(privateKey);
      await _configService.setMnemonic(cryptMnemonic);
      await _configService.setPrivateKey(privateKey);
      await _configService.setHermezPrivateKey(hermezPrivateKey);
      await _configService.setEthereumAddress(ethereumAddress);
      await _configService.setHermezAddress(hermezAddress);
      await _configService.setBabyJubJubHex(babyJubJubHex);
      await _configService.setBabyJubJubBase64(babyJubJubBase64);
      await _configService.setupDone(true);

      print("Config: ${_configService.getEthereumAddress()}");
      return _configService.getEthereumAddress();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<bool> setupFromPrivateKey(String privateKey) async {
    final hermezPrivateKey = await getHermezPrivateKey(privateKey);
    final ethereumAddress = await getEthereumAddress(privateKey);
    final hermezAddress = await getHermezAddress(privateKey);
    final babyJubJubHex = await getBabyJubJubHex(privateKey);
    final babyJubJubBase64 = await getBabyJubJubBase64(privateKey);

    await _configService.setMnemonic("");
    await _configService.setPrivateKey(privateKey);
    await _configService.setHermezPrivateKey(hermezPrivateKey);
    await _configService.setBabyJubJubHex(babyJubJubHex);
    await _configService.setBabyJubJubBase64(babyJubJubBase64);
    await _configService.setEthereumAddress(ethereumAddress);
    await _configService.setHermezAddress(hermezAddress);
    await _configService.setupDone(true);
    return true;
  }

  @override
  String getPrivateKey(String mnemonic) {
    String privateKey =
        HDKey.mnemonicToPrivateKey(mnemonic, derivePath: "m/44'/60'/0'/0/0");
    print("ethereum private key: $privateKey");
    return privateKey;
  }

  @override
  Future<String> getHermezPrivateKey(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final signature =
        await private.signPersonalMessage(ascii.encode(AUTH_MESSAGE));
    final hashedSignatureBuffer =
        keccakAscii(bytesToHex(signature, include0x: true));
    final hermezPrivateKey = bytesToHex(hashedSignatureBuffer);
    print("hermez private key 2: $hermezPrivateKey");
    return hermezPrivateKey;
  }

  @override
  Future<String> getBabyJubJubHex(String privateKey) async {
    final hermezPrivateKey = await getHermezPrivateKey(privateKey);
    final hermezAddress = await getHermezAddress(privateKey);
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    final babyJubJubHex = hermezWallet.publicKeyCompressedHex;
    print("babyjubjub hex: $babyJubJubHex");
    return babyJubJubHex;
  }

  @override
  Future<String> getBabyJubJubBase64(String privateKey) async {
    final hermezPrivateKey = await getHermezPrivateKey(privateKey);
    final hermezAddress = await getHermezAddress(privateKey);
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    final babyJubJubBase64 = hermezWallet.publicKeyBase64;
    print("babyjubjub base64: $babyJubJubBase64");
    return babyJubJubBase64;
  }

  @override
  Future<String> getEthereumAddress(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final address = await private.extractAddress();
    print("ethereum address: $address");
    return address.hex;
  }

  @override
  Future<String> getHermezAddress(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final ethereumAddress = await private.extractAddress();
    final address = addresses.getHermezAddress(ethereumAddress.hex);
    print("hermez address: $address");
    return address;
  }
}
