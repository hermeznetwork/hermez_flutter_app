import 'dart:convert';

import "package:convert/convert.dart" show hex;
import 'package:pointycastle/digests/sha3.dart';

class AddressUtils {
  /// Returns whether a given Ethereum address is valid.
  static bool isValidEthereumAddress(String address) {
    if (!isValidFormat(address)) {
      return false;
    }

    final addr = strip0x(address);
    // if all lowercase or all uppercase, as in checksum is not present
    if (RegExp(r"^[0-9a-f]{40}$").hasMatch(addr) ||
        RegExp(r"^[0-9A-F]{40}$").hasMatch(addr)) {
      return true;
    }

    String checksumAddress;
    try {
      checksumAddress = checksumEthereumAddress(address);
    } catch (err) {
      return false;
    }

    return addr.toLowerCase() == checksumAddress.substring(2).toLowerCase();
  }

  static String strip0x(String address) {
    if (address.toLowerCase().startsWith("0x")) {
      address = address.substring(2);
    }
    return address;
  }

  static String stripHez0x(String address) {
    if (address.toLowerCase().startsWith("hez:")) {
      address = address.substring(4);
    }
    return strip0x(address);
  }

  /// Derives an Ethereum address from a given public key.
  /*String ethereumAddressFromPublicKey(Uint8List publicKey) {
    final decompressedPubKey = decompressPublicKey(publicKey);
    final hash = SHA3Digest(256, true).process(decompressedPubKey.sublist(1));
    final address = hash.sublist(12, 32);

    return checksumEthereumAddress(hex.encode(address));
  }*/

  /// Converts an Ethereum address to a checksummed address (EIP-55).
  static String checksumEthereumAddress(String address) {
    if (!isValidFormat(address)) {
      throw ArgumentError.value(address, "address", "invalid address");
    }

    final addr = strip0x(address).toLowerCase();
    final hash = ascii.encode(hex.encode(
      SHA3Digest(256 /*, true*/).process(ascii.encode(addr)),
    ));

    var newAddr = "0x";

    for (var i = 0; i < addr.length; i++) {
      if (hash[i] >= 56) {
        newAddr += addr[i].toUpperCase();
      } else {
        newAddr += addr[i];
      }
    }

    return newAddr;
  }

  static bool isValidFormat(String address) {
    return RegExp(r"^[0-9a-fA-F]{40}$").hasMatch(strip0x(address));
  }
}
