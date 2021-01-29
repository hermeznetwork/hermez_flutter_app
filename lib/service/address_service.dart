import 'package:bip39/bip39.dart' as bip39;
import 'package:hermez/constants.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hd_key.dart';
import 'package:hermez_plugin/addresses.dart' as addresses;
import 'package:hermez_plugin/hermez_wallet.dart';
import 'package:hermez_plugin/utils/uint8_list_utils.dart';
import "package:hex/hex.dart";
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';

abstract class IAddressService {
  String generateMnemonic();
  String entropyToMnemonic(String entropyMnemonic);
  Future<bool> setupFromMnemonic(String mnemonic);
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

  @override
  Future<bool> setupFromMnemonic(String mnemonic) async {
    final cryptMnemonic = bip39.mnemonicToEntropy(mnemonic);
    final privateKey = getPrivateKey(cryptMnemonic);
    final hermezPrivateKey = await getHermezPrivateKey(privateKey);
    final ethereumAddress = await getEthereumAddress(privateKey);
    final hermezAddress = await getHermezAddress(privateKey);
    final babyJubJubHex = await getBabyJubJubHex(privateKey);
    final babyJubJubBase64 = await getBabyJubJubBase64(privateKey);

    //final hermezAddress =
    //    'hez:0x4294cE558F2Eb6ca4C3191AeD502cF0c625AE995';
    //const hermezEthereumAddressError = '0x4294cE558F2Eb6ca4C3191AeD502cF0c625AE995'
    /*final hashedSignatureBuffer = Uint8List.fromList([
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
    ]);*/
    //const privateKeyError = Buffer.from([10, 147, 192, 202, 232, 207, 65, 134, 114, 147, 167, 10, 140, 18, 111, 145, 163, 133, 85, 250, 191, 58, 146, 129, 0, 79, 4, 238, 153, 79, 151])
    //const wallet = new HermezWallet(privateKey, hermezEthereumAddress)

    /*final hermezWallet = HermezWallet(
        Uint8ArrayUtils.uint8ListfromString(hermezPrivateKey), hermezAddress);*/

    await _configService.setMnemonic(cryptMnemonic);
    await _configService.setPrivateKey(privateKey);
    await _configService.setHermezPrivateKey(hermezPrivateKey);
    await _configService.setBabyJubJubHex(babyJubJubHex);
    await _configService.setBabyJubJubBase64(babyJubJubBase64);
    await _configService.setEthereumAddress(ethereumAddress);
    await _configService.setHermezAddress(hermezAddress);
    await _configService.setupDone(true);

    print("Config: $_configService.getEthereumAddress()");
    return true;
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
    String seed = bip39.mnemonicToSeedHex(mnemonic);
    KeyData master = HDKey.getMasterKeyFromSeed(seed);
    final privateKey = HEX.encode(master.key);
    print("ethereum private key: $privateKey");
    return privateKey;
  }

  @override
  Future<String> getHermezPrivateKey(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final signature =
        await private.sign(Uint8ArrayUtils.uint8ListfromString(AUTH_MESSAGE));
    final hashedSignatureBuffer = keccak256(signature);
    String hermezPrivateKey =
        Uint8ArrayUtils.uint8ListToString(hashedSignatureBuffer);
    print("hermez private key: $hermezPrivateKey");
    return hermezPrivateKey;
  }

  @override
  Future<String> getBabyJubJubHex(String privateKey) async {
    final hermezPrivateKey = await getHermezPrivateKey(privateKey);
    final hermezAddress = await getHermezAddress(privateKey);
    final hermezWallet = HermezWallet(
        Uint8ArrayUtils.uint8ListfromString(hermezPrivateKey), hermezAddress);
    final babyJubJubHex = hermezWallet.publicKeyCompressedHex;
    print("babyjubjub hex: $babyJubJubHex");
    return babyJubJubHex;
  }

  @override
  Future<String> getBabyJubJubBase64(String privateKey) async {
    final hermezPrivateKey = await getHermezPrivateKey(privateKey);
    final hermezAddress = await getHermezAddress(privateKey);
    final hermezWallet = HermezWallet(
        Uint8ArrayUtils.uint8ListfromString(hermezPrivateKey), hermezAddress);
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
