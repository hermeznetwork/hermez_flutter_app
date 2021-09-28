import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/domain/qrcode/qrcode_repository.dart';
import 'package:image_picker/image_picker.dart';
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
  }
}
