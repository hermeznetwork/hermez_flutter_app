import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:hermez/constants.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hd_key.dart';
import 'package:hermez_plugin/addresses.dart' as addresses;
import 'package:hermez_plugin/hermez_wallet.dart';
import 'package:hermez_plugin/utils/uint8_list_utils.dart';
import "package:hex/hex.dart";
import 'package:web3dart/credentials.dart';

abstract class IAddressService {
  String generateMnemonic();
  String getPrivateKey(String mnemonic);
  //String getHermezPrivateKey(String mnemonic);
  //String getBabyJubJub(String privateKey);
  Future<EthereumAddress> getPublicAddress(String privateKey);
  Future<bool> setupFromMnemonic(String mnemonic);
  Future<bool> setupFromPrivateKey(String privateKey);
  String entropyToMnemonic(String entropyMnemonic);
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

  @override
  String getPrivateKey(String mnemonic) {
    String seed = bip39.mnemonicToSeedHex(mnemonic);
    KeyData master = HDKey.getMasterKeyFromSeed(seed);
    final privateKey = HEX.encode(master.key);
    print("ethereum private key: $privateKey");

    /*KeyData rollup = HDKey.derivePath("m/44'/60'/0'/0'", seed);
    final rollupPrivateKey = HEX.encode(rollup.key);
    print("rollup private key: $rollupPrivateKey");*/

    return privateKey;
  }

  /*void method(String mnemonic) {
    String seed = bip39.mnemonicToSeedHex(mnemonic);
    KeyData master = HDKey.getMasterKeyFromSeed(seed);
    print(HEX.encode(master
        .key)); // 171cb88b1b3c1db25add599712e36245d75bc65a1a5c9e18d76f9f2b1eab4012
    print(HEX.encode(master
        .chainCode)); // ef70a74db9c3a5af931b5fe73ed8e1a53464133654fd55e7a66f8570b8e33c3b
    // "m/44'/60'/0'/0/0"
    // m / purpose' / coin_type' / account' / change / address_index
    KeyData data = HDKey.derivePath("m/0'/2147483647'", seed);
    var pb = HDKey.getBublickKey(data.key);
    print(HEX.encode(data
        .key)); // ea4f5bfe8694d8bb74b7b59404632fd5968b774ed545e810de9c32a4fb4192f4
    print(HEX.encode(data
        .chainCode)); // 138f0b2551bcafeca6ff2aa88ba8ed0ed8de070841f0c4ef0165df8181eaad7f
    print(HEX.encode(
        pb)); // 005ba3b9ac6e90e83effcd25ac4e58a1365a9e35a3d3ae5eb07b9e4d90bcf7506d
  }*/

  @override
  Future<EthereumAddress> getPublicAddress(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);

    final address = await private.extractAddress();
    print("address: $address");
    return address;
  }

  @override
  Future<bool> setupFromMnemonic(String mnemonic) async {
    final cryptMnemonic = bip39.mnemonicToEntropy(mnemonic);
    final privateKey = this.getPrivateKey(cryptMnemonic);
    final ethereumAddress = await getPublicAddress(privateKey);
    final private = EthPrivateKey.fromHex(privateKey);
    final signature =
        await private.sign(Uint8ArrayUtils.uint8ListfromString(AUTH_MESSAGE));
    final hermezAddress = addresses.getHermezAddress(ethereumAddress.hex);
    //final hashedSignatureBuffer = keccak256(signature);

    final hermezEthereumAddress =
        'hez:0x4294cE558F2Eb6ca4C3191AeD502cF0c625AE995';
    //const hermezEthereumAddressError = '0x4294cE558F2Eb6ca4C3191AeD502cF0c625AE995'
    final hashedSignatureBuffer = Uint8List.fromList([
      10,
      147,
      192,
      202,
      232,
      207,
      65,
      134,
      114,
      147,
      167,
      10,
      140,
      18,
      111,
      145,
      163,
      133,
      85,
      250,
      191,
      58,
      146,
      129,
      0,
      79,
      4,
      238,
      153,
      79,
      151,
      219
    ]);
    //const privateKeyError = Buffer.from([10, 147, 192, 202, 232, 207, 65, 134, 114, 147, 167, 10, 140, 18, 111, 145, 163, 133, 85, 250, 191, 58, 146, 129, 0, 79, 4, 238, 153, 79, 151])
    //const wallet = new HermezWallet(privateKey, hermezEthereumAddress)

    final hermezWallet =
        HermezWallet(hashedSignatureBuffer, hermezEthereumAddress);

    // TODO
    //final babyJubJub = this.method(cryptMnemonic);

    await _configService.setMnemonic(cryptMnemonic);
    await _configService.setPrivateKey(privateKey);
    //await _configService.setBabyJubJub();
    await _configService.setEthereumAddress(ethereumAddress.toString());
    await _configService.setupDone(true);

    print("Config: $_configService.getEthereumAddress()");
    return true;
  }

  @override
  Future<bool> setupFromPrivateKey(String privateKey) async {
    await _configService.setMnemonic("");
    await _configService.setPrivateKey(privateKey);
    final address = await getPublicAddress(privateKey);
    await _configService.setEthereumAddress(address.toString());
    await _configService.setupDone(true);
    return true;
  }
}
