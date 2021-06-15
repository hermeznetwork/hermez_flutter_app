/*
* author: Aleksey Popov <alepooop@gmail.com>
* homepage: https://github.com/alepop/dart-ed25519-hd-key
*/

//import 'dart:convert';
//import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
// import 'package:pointycastle/api.dart';
// import 'package:pointycastle/digests/sha512.dart';
// import 'package:pointycastle/macs/hmac.dart';

class KeyData {
  List<int> key;
  List<int> chainCode;
  KeyData({this.key, this.chainCode});
}

const String MASTER_SECRET = 'Bitcoin seed';
const int HARDENED_OFFSET = 0x80000000;

class _HDKey {
  //static final _curveBytes = utf8.encode(MASTER_SECRET);

  const _HDKey();

  /*KeyData _getKeys(Uint8List data, Uint8List keyParameter) {
    final digest = SHA512Digest();
    final hmac = HMac(digest, 128)..init(KeyParameter(keyParameter));
    final I = hmac.process(data);
    final IL = I.sublist(0, 32);
    final IR = I.sublist(32);
    return KeyData(key: IL, chainCode: IR);
  }

  KeyData getMasterKeyFromSeed(String seed) {
    final seedBytes = HEX.decode(seed);
    return this._getKeys(seedBytes, _HDKey._curveBytes);
  }*/

  /*Uint8List getBublickKey(Uint8List privateKey, [bool withZeroByte = true]) {
    final signature = ED25519.Signature.keyPair_fromSeed(privateKey);
    if (withZeroByte == true) {
      Uint8List dataBytes = Uint8List(33);
      dataBytes[0] = 0x00;
      dataBytes.setRange(1, 33, signature.publicKey);
      return dataBytes;
    } else {
      return signature.publicKey;
    }
  }*/

  String mnemonicToPrivateKey(String mnemonic, {String derivePath}) {
    String ethPath = (derivePath != null && derivePath.isNotEmpty)
        ? derivePath
        : "m/44'/60'/0'/0/0";

    final seed = bip39.mnemonicToSeed(mnemonic);
    bip32.BIP32 node = bip32.BIP32.fromSeed(seed).derivePath(ethPath);
    String privateKey = HEX.encode(node.privateKey);
    return privateKey;
  }
}

const HDKey = const _HDKey();
