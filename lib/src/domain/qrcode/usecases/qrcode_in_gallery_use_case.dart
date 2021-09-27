import 'package:hermez/src/domain/qrcode/qrcode_repository.dart';

class QrcodeInGalleryUseCase {
  final QrcodeRepository _qrcodeRepository;

  QrcodeInGalleryUseCase(this._qrcodeRepository);

  Future<String> execute() {
    return _qrcodeRepository.getQrByGallery();
  }
}
