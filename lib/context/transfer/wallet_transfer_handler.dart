import 'dart:async';
import 'dart:math';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/context/transfer/wallet_transfer_state.dart';
import 'package:hermez/model/wallet_transfer.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/service/contract_service.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
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

  Future<BigInt> getEstimatedFeeInWei(
      String from, String to, String amount) async {
    var completer = new Completer<BigInt>();
    try {
      GasPriceResponse gasPriceResponse = await _contractService.getGasPrice();
      EtherAmount gasPrice =
          EtherAmount.inWei(BigInt.from(gasPriceResponse.average * pow(10, 8)));

      BigInt estimatedGas = await _contractService.getEstimatedGas(
          EthereumAddress.fromHex(from),
          EthereumAddress.fromHex(to),
          EtherAmount.fromUnitAndValue(
              EtherUnit.wei, BigInt.from(double.parse(amount) * pow(10, 18))),
          null);

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

  Future<bool> transferEth(String privateKey, String to, String amount) async {
    var completer = new Completer<bool>();
    //var privateKey = await _configurationService.getPrivateKey();

    _store.dispatch(WalletTransferStarted());

    try {
      /*BigInt estimatedGas = await _contractService.getEstimatedGas(
          EthereumAddress.fromHex(from),
          EthereumAddress.fromHex(to),
          EtherAmount.fromUnitAndValue(
              EtherUnit.wei, BigInt.from(double.parse(amount) * pow(10, 18))));

      EtherAmount gasPrice = await _contractService.getGasPrice();

      print("Estimated Gas: " + estimatedGas.toString());
      print("Gas Price in Wei: " + gasPrice.getInWei.toString());
      print("Gas Price in Eth: " + gasPrice.getInEther.toString());*/

      String txHash = await _contractService.sendEth(
        privateKey,
        EthereumAddress.fromHex(to),
        BigInt.from(double.parse(amount) * pow(10, 18)),
        onError: (ex) {
          _store.dispatch(WalletTransferError(ex.toString()));
          completer.complete(false);
        },
      );
      completer.complete(txHash != null && txHash.isNotEmpty);
    } catch (ex) {
      _store.dispatch(WalletTransferError(ex.toString()));
      completer.complete(false);
    }

    return completer.future;
  }

  Future<bool> transfer(String to, String amount, String tokenContractAddress,
      String tokenContractName) async {
    var completer = new Completer<bool>();
    var privateKey = await _configurationService.getPrivateKey();

    _store.dispatch(WalletTransferStarted());

    try {
      String txHash = await _contractService.send(
        privateKey,
        EthereumAddress.fromHex(to),
        BigInt.from(double.parse(amount) * pow(10, 18)),
        EthereumAddress.fromHex(tokenContractAddress),
        tokenContractName,
        onError: (ex) {
          _store.dispatch(WalletTransferError(ex.toString()));
          completer.complete(false);
        },
      );
      completer.complete(txHash != null && txHash.isNotEmpty);
    } catch (ex) {
      _store.dispatch(WalletTransferError(ex.toString()));
      completer.complete(false);
    }

    return completer.future;
  }
}
