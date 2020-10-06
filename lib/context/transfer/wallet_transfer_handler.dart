import 'dart:async';
import 'dart:math';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/context/transfer/wallet_transfer_state.dart';
import 'package:hermez/model/wallet_transfer.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/service/contract_service.dart';
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
      BigInt estimatedGas = await _contractService.getEstimatedGas(
          EthereumAddress.fromHex(from),
          EthereumAddress.fromHex(to),
          EtherAmount.fromUnitAndValue(
              EtherUnit.wei, BigInt.from(double.parse(amount) * pow(10, 18))));

      EtherAmount gasPrice = await _contractService.getGasPrice();

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

  Future<bool> transferEth(String from, String to, String amount) async {
    var completer = new Completer<bool>();
    var privateKey = await _configurationService.getPrivateKey();

    _store.dispatch(WalletTransferStarted());

    try {
      BigInt estimatedGas = await _contractService.getEstimatedGas(
          EthereumAddress.fromHex(from),
          EthereumAddress.fromHex(to),
          EtherAmount.fromUnitAndValue(
              EtherUnit.wei, BigInt.from(double.parse(amount) * pow(10, 18))));

      EtherAmount gasPrice = await _contractService.getGasPrice();

      print("Estimated Gas: " + estimatedGas.toString());
      print("Gas Price in Wei: " + gasPrice.getInWei.toString());
      print("Gas Price in Eth: " + gasPrice.getInEther.toString());

      String txHash = await _contractService.transfer(
        privateKey,
        EthereumAddress.fromHex(from),
        EthereumAddress.fromHex(to),
        BigInt.from(double.parse(amount) * pow(10, 18)),
        onTransfer: (from, to, value) {
          completer.complete(true);
        },
        onError: (ex) {
          _store.dispatch(WalletTransferError(ex.toString()));
          completer.complete(false);
        },
      );
      completer.complete(txHash.isNotEmpty);
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
      await _contractService.send(
        privateKey,
        EthereumAddress.fromHex(to),
        BigInt.from(double.parse(amount) * pow(10, 18)),
        EthereumAddress.fromHex(tokenContractAddress),
        tokenContractName,
        onTransfer: (from, to, value) {
          completer.complete(true);
        },
        onError: (ex) {
          _store.dispatch(WalletTransferError(ex.toString()));
          completer.complete(false);
        },
      );
    } catch (ex) {
      _store.dispatch(WalletTransferError(ex.toString()));
      completer.complete(false);
    }

    return completer.future;
  }
}
