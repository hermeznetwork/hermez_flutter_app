import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/qrcode/usecases/qrcode_in_gallery_use_case.dart';
import 'package:hermez/src/presentation/qrcode/qrcode_state.dart';

class QrcodeBloc extends Bloc<QrcodeState> {
  final QrcodeInGalleryUseCase _qrcodeInGalleryUseCase;

  QrcodeBloc(this._qrcodeInGalleryUseCase) {
    changeState(QrcodeState.init());
  }

  Future<String> qrcodeInGallery() {
    return _qrcodeInGalleryUseCase.execute().then((data) {
      return data;
      //changeState(QrcodeState.mnemonicCreated(QrcodeItemState(mnemonic)));
    }).catchError((error) {
      return null;
      //changeState(QrcodeState.error('A network error has occurred'));
    });
  }
}
