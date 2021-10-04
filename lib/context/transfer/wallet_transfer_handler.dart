import 'dart:async';
import 'dart:math';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/context/transfer/wallet_transfer_state.dart';
import 'package:hermez/model/wallet_transfer.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/data/network/contract_service.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class WalletTransferHandler {
  WalletTransferHandler(
    this._store,
    this._contractService,
    this._configurationService,
  );

  final Store<WalletTransfer, WalletTransferAction> _store;
  final ContractService _contractService;
  final ConfigurationService _configurationService;

  WalletTransfer get state => _store.state;

  // TODO NOT USED??
  Future<BigInt> getEstimatedFeeInWei(
      String from, String to, String amount, Token token) async {
    var completer = new Completer<BigInt>();
    try {
      GasPriceResponse gasPriceResponse = await _contractService.getGasPrice();
      EtherAmount gasPrice =
          EtherAmount.inWei(BigInt.from(gasPriceResponse.average * pow(10, 8)));

      BigInt estimatedGas = await _contractService.getEstimatedGas(
          EthereumAddress.fromHex(from),
          EthereumAddress.fromHex(to),
          BigInt.from(double.parse(amount) * pow(10, token.decimals)),
          null,
          token);

      print("Estimated Gas: " + estimatedGas.toString());
      print("Gas Price in Wei: " + gasPrice.getInWei.toString());
      print("Gas Price in Eth: " + gasPrice.getInEther.toString());

      completer.complete(estimatedGas * gasPrice.getInWei);
    } catch (ex) {
      _store.dispatch(WalletTransferError(ex.toString()));
      completer.complete(BigInt.from(-1));
    }
    return completer.future;
  }

  Future<bool> transfer(
      String privateKey, String to, String amount, Token token,
      {int gasLimit, int gasPrice}) async {
    _store.dispatch(WalletTransferStarted());
    return await _contractService.transfer(
      to,
      BigInt.from(double.parse(amount) * pow(10, token.decimals)),
      token,
      gasLimit: gasLimit,
      gasPrice: gasPrice,
    );
  }
}
