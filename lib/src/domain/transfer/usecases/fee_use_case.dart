import 'dart:typed_data';

import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez_sdk/model/recommended_fee.dart';
import 'package:hermez_sdk/model/token.dart';

class FeeUseCase {
  final TransferRepository _transferRepository;

  FeeUseCase(this._transferRepository);

  Future<RecommendedFee> getHermezFees() {
    return _transferRepository.getHermezFees();
  }

  Future<GasPriceResponse> getGasPrice() async {
    return _transferRepository.getGasPrice();
  }

  Future<BigInt> getGasLimit(String from, String to, BigInt amount, Token token,
      {Uint8List data}) async {
    return _transferRepository.getGasLimit(from, to, amount, token, data: data);
  }
}
