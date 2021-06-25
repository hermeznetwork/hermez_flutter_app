import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_test/flutter_test.dart';
import 'package:hermez/utils/hd_key.dart';

void main() {
  group("Test seed", () {
    test("should have valid key", () {
      String seed = bip39.mnemonicToSeedHex(
          "thought empty modify achieve arch tooth sign unhappy life tape team dust");
      var master = HDKey.mnemonicToPrivateKey(seed);
      expect(
          master,
          equals(
              "1352d9efc5c511f89ff262f913e58a2d42649d47246752790cbce6987e100bfe"));
    });
  });
}
