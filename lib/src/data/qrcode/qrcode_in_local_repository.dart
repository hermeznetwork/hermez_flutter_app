import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/domain/qrcode/qrcode_repository.dart';
import 'package:hermez/src/domain/security/security_repository.dart';
import 'package:hermez/utils/biometrics_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

class SecurityInLocalRepository implements QrcodeRepository {
  final IConfigurationService _configurationService;
  SecurityInLocalRepository(this._configurationService);


  @override
  Future<String> getQrByGallery() async {
      final picker = ImagePicker();
      XFile file = await picker.pickImage(source: ImageSource.gallery);
      print(file.path);
      String data = await QrCodeToolsPlugin.decodeFrom(file.path)
          .onError((error, stackTrace) {
        return error.toString();
      });
      print(data);
      return data;
      /*if (data != null && data.length > 0) {
        if (result == null) {
          List<String> scannedStrings = data.split(":");
          if (scannedStrings.length > 0 &&
              (widget.arguments.type == QRCodeScannerType.ALL ||
                  widget.arguments.type == QRCodeScannerType.HERMEZ_ADDRESS) &&
              AddressUtils.isValidEthereumAddress(scannedStrings[1])) {
            finish(data);
          } else if (scannedStrings.length > 0 &&
              (widget.arguments.type == QRCodeScannerType.ALL ||
                  widget.arguments.type == QRCodeScannerType.ETHEREUM_ADDRESS) &&
              AddressUtils.isValidEthereumAddress(scannedStrings[0])) {
            finish(data);
          }
        }
      }*/
    }
  }
}
