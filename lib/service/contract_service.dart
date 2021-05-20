import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:hermez/service/network/api_eth_gas_station_client.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/utils/contract_parser.dart';
import 'package:hermez_plugin/api.dart';
import 'package:hermez_plugin/environment.dart';
import 'package:hermez_plugin/model/token.dart';
import 'package:web3dart/web3dart.dart';

import 'configuration_service.dart';

typedef TransferEvent = void Function(
    EthereumAddress from, EthereumAddress to, BigInt value);

abstract class IContractService {
  Future<Credentials> getCredentials(String privateKey);
  Future<bool> sendEth(
      String privateKey, EthereumAddress receiverAddress, BigInt amountInWei,
      {TransferEvent onTransfer, Function onError});
  Future<bool> send(String privateKey, EthereumAddress receiverAddress,
      BigInt amountInWei, Token token,
      {TransferEvent onTransfer, Function onError});
  Future<BigInt> getTokenBalance(EthereumAddress from,
      EthereumAddress tokenContractAddress, String tokenContractName);
  Future<EtherAmount> getEthBalance(EthereumAddress from);
  Future<void> dispose();
  StreamSubscription listenTransfer(
      TransferEvent onTransfer, DeployedContract contract);
  //StreamSubscription listenPendingTransactions();
}

class ContractService implements IContractService {
  ContractService(this.client, this._configService, this._estimateGasPriceUrl,
      this._estimateGasPriceApiKey
      //this.tokenContractsAddress,
      /*this.contracts*/
      );

  final Web3Client client;
  String _estimateGasPriceUrl;
  String _estimateGasPriceApiKey;
  IConfigurationService _configService;
  //Credentials credentials;
  //final List<String> tokenContractsAddress;
  //final List<DeployedContract> contract;

  ApiEthGasStationClient _apiEthGasStationClient() => ApiEthGasStationClient(
      this._estimateGasPriceUrl, this._estimateGasPriceApiKey);

  ContractEvent _transferEvent(DeployedContract contract) =>
      contract.event('Transfer');
  ContractFunction _balanceFunction(DeployedContract contract) =>
      contract.function('balanceOf');
  ContractFunction _sendFunction(DeployedContract contract) =>
      contract.function('transfer');

  Future<Credentials> getCredentials(String privateKey) =>
      client.credentialsFromPrivateKey(privateKey);

  Future<bool> sendEth(
      String privateKey, EthereumAddress receiverAddress, BigInt amountInWei,
      {TransferEvent onTransfer, Function onError}) async {
    final credentials = await this.getCredentials(privateKey);
    final from = await credentials.extractAddress();
    Token token = await getToken(0);
    /*bool isApproved = await _approveCb;
    if (!isApproved) {
      throw 'transaction not approved';
    }*/

    EtherAmount amount =
        EtherAmount.fromUnitAndValue(EtherUnit.wei, amountInWei);

    //try {
    final txHash = await _sendTransaction(privateKey, receiverAddress, amount)
        .then((txHash) {
      if (txHash != null) {
        _configService.addPendingTransfer({
          'hash': txHash,
          'fromHezEthereumAddress': from.hex,
          'toHezEthereumAddress': receiverAddress.hex,
          'token': token,
          'amount': amountInWei.toDouble(),
          'state': 'pend',
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'Transfer'
        });
      }
      return txHash != null;
    });
    return txHash;
    /*} catch (ex) {
      if (onError != null) {
        onError(ex);
      }
      return null;
    }*/
  }

  Future<bool> send(String privateKey, EthereumAddress receiverAddress,
      BigInt amountInWei, Token token,
      {TransferEvent onTransfer, Function onError}) async {
    final credentials = await this.getCredentials(privateKey);
    final from = await credentials.extractAddress();

    EthereumAddress tokenContractAddress =
        EthereumAddress.fromHex(token.ethereumAddress);
    String tokenContractName = token.symbol;
    final contract = await ContractParser.fromAssets(
        'ERC20ABI.json', tokenContractAddress.toString(), tokenContractName);

    final txHash = await client
        .sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: _sendFunction(contract),
        parameters: [receiverAddress, amountInWei],
        from: from,
      ),
    )
        .then((txHash) {
      if (txHash != null) {
        _configService.addPendingTransfer({
          'hash': txHash,
          'fromHezEthereumAddress': from.hex,
          'toHezEthereumAddress': receiverAddress.hex,
          'token': token,
          'amount': amountInWei.toDouble(),
          'state': 'pend',
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'Transfer'
        });
      }
      return txHash != null;
    });
    return txHash;
  }

  Future<String> _sendTransaction(String privateKey,
      EthereumAddress receiverAddress, EtherAmount amount) async {
    print('sendTransaction');

    final credentials = await this.getCredentials(privateKey);
    final from = await credentials.extractAddress();

    final gasPrice = await client.getGasPrice();
    final maxGas = await client.estimateGas(
        sender: from, to: receiverAddress, value: amount);

    Transaction transaction = Transaction(
        from: from,
        to: receiverAddress,
        maxGas: maxGas.toInt(),
        gasPrice: gasPrice,
        value: amount);

    print(
        'transfer L1 --> privateKey: $privateKey, sender: $from, receiver: $receiverAddress, amountInWei: $amount');
    String txHash;
    try {
      txHash = await client.sendTransaction(credentials, transaction,
          chainId: getCurrentEnvironment().chainId);
    } catch (e) {
      print(e.toString());
    }

    print(txHash);

    return txHash;
  }

  Future<TransactionInformation> getTransactionByHash(String txHash) async {
    TransactionInformation transaction =
        await client.getTransactionByHash(txHash);
    return transaction;
  }

  Future<TransactionReceipt> getTxReceipt(String txHash) async {
    TransactionReceipt receipt;
    try {
      receipt = await client.getTransactionReceipt(txHash);
    } catch (err) {
      print('could not get $txHash receipt, try again');
    }
    return receipt;
  }

  Future<TransactionReceipt> getTransactionReceipt(String txHash) async {
    TransactionReceipt receipt;
    try {
      receipt = await client.getTransactionReceipt(txHash);
    } catch (err) {
      print('could not get $txHash receipt, try again');
    }
    int delay = 1;
    int retries = 10;
    while (receipt == null) {
      print('waiting for receipt');
      await Future.delayed(new Duration(seconds: delay));
      delay *= 2;
      retries--;
      if (retries == 0) {
        throw 'transaction $txHash not mined yet...';
      }
      try {
        receipt = await client.getTransactionReceipt(txHash);
      } catch (err) {
        print('could not get $txHash receipt, try again');
      }
    }
    return receipt;
  }

  Future<String> _sendTransactionAndWaitForReceipt(String privateKey,
      EthereumAddress receiverAddress, EtherAmount amount) async {
    print('sendTransactionAndWaitForReceipt');

    final credentials = await this.getCredentials(privateKey);
    final from = await credentials.extractAddress();
    final networkId = await client.getNetworkId();

    Transaction transaction =
        Transaction(from: from, to: receiverAddress, value: amount);

    print(
        'transfer --> privateKey: $privateKey, sender: $from, receiver: $receiverAddress, amountInWei: $amount');

    String txHash = await client.sendTransaction(credentials, transaction,
        chainId: networkId);
    TransactionReceipt receipt;
    try {
      receipt = await client.getTransactionReceipt(txHash);
    } catch (err) {
      print('could not get $txHash receipt, try again');
    }
    int delay = 1;
    int retries = 10;
    while (receipt == null) {
      print('waiting for receipt');
      await Future.delayed(new Duration(seconds: delay));
      delay *= 2;
      retries--;
      if (retries == 0) {
        throw 'transaction $txHash not mined yet...';
      }
      try {
        receipt = await client.getTransactionReceipt(txHash);
      } catch (err) {
        print('could not get $txHash receipt, try again');
      }
    }
    return txHash;
  }

  Future<EtherAmount> getEthBalance(EthereumAddress from) async {
    return await client.getBalance(from);
  }

  Future<BigInt> getTokenBalance(EthereumAddress from,
      EthereumAddress tokenContractAddress, String tokenContractName) async {
    final contract = await ContractParser.fromAssets(
        'ERC20ABI.json', tokenContractAddress.hex, tokenContractName);

    var response = await client.call(
      contract: contract,
      function: _balanceFunction(contract),
      params: [from],
    );

    return response[0] as BigInt;
  }

  Future<BigInt> getEstimatedGas(
    EthereumAddress from,
    EthereumAddress to,
    EtherAmount value,
    Uint8List data,
  ) async {
    return client.estimateGas(sender: from, to: to, value: value, data: data);
  }

  Future<int> getNetworkId() {
    return client.getNetworkId();
  }

  Future<GasPriceResponse> getGasPrice() async {
    if (getCurrentEnvironment().chainId == 1) {
      GasPriceResponse gasPrice = await _apiEthGasStationClient().getGasPrice();
      return gasPrice;
    } else {
      EtherAmount gasPrice = await client.getGasPrice();
      GasPriceResponse gasPriceResponse = GasPriceResponse(
          safeLow: BigInt.from((gasPrice.getInWei.toInt() ~/ 2) ~/ pow(10, 8))
              .toInt(),
          average: gasPrice.getValueInUnit(EtherUnit.gwei).toInt() * 10,
          fast: EtherAmount.fromUnitAndValue(
                      EtherUnit.wei, gasPrice.getInWei.toInt() * 2)
                  .getValueInUnit(EtherUnit.gwei)
                  .toInt() *
              10);
      return gasPriceResponse;
    }
  }

  /*StreamSubscription listenEthTransfer(TransferEvent onTransfer, {int take}) {
    var events = client.events(FilterOptions.events(
      contract: contract,
      event: _transferEvent(contract),
    ));

    if (take != null) {
      events = events.take(take);
    }

    return events.listen((event) {
      final decoded =
          _transferEvent(contract).decodeResults(event.topics, event.data);

      final from = decoded[0] as EthereumAddress;
      final to = decoded[1] as EthereumAddress;
      final value = decoded[2] as BigInt;

      print('$from}');
      print('$to}');
      print('$value}');

      onTransfer(from, to, value);
    });
  }*/

  StreamSubscription listenTransfer(
      TransferEvent onTransfer, DeployedContract contract,
      {int take}) {
    var events = client.events(FilterOptions.events(
      contract: contract,
      event: _transferEvent(contract),
    ));

    if (take != null) {
      events = events.take(take);
    }

    return events.listen((event) {
      final decoded =
          _transferEvent(contract).decodeResults(event.topics, event.data);

      final from = decoded[0] as EthereumAddress;
      final to = decoded[1] as EthereumAddress;
      final value = decoded[2] as BigInt;

      print('$from');
      print('$to');
      print('$value');

      onTransfer(from, to, value);
    });
  }

  StreamSubscription listenPendingTransactions({int take}) {
    var pendingTransactions = client.pendingTransactions();

    if (take != null) {
      pendingTransactions = pendingTransactions.take(take);
    }

    return pendingTransactions.listen((event) {
      print('$event');
    });
  }

  /*Future<DeployedContract> _contract(
      String contractName, String contractAddress) async {
    String abi = ABI.get(contractName);
    DeployedContract contract = DeployedContract(
        ContractAbi.fromJson(abi, contractName),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<List<dynamic>> _readFromContract(String contractName,
      String contractAddress, String functionName, List<dynamic> params) async {
    DeployedContract contract = await _contract(contractName, contractAddress);
    return await client.call(
        contract: contract,
        function: contract.function(functionName),
        params: params);
  }*/

  /*void listTransactions() async {
    int n = await client.getBlockNumber();
    client.getBlockNumber()

    String hash = "0x74836273a74ec6e3a6c939fe0f361c56eeabee03dbacdc41821a8c4ec6dbdbb4";
    var transactionInfo = await client.getTransactionByHash(hash);
    var transacitonReceipt = await client.getTransactionReceipt(hash); -> Exception has occurred.
    FormatException (FormatException: Invalid radix-10 number (at character 1)
    10c755

    var txs = [];
    for (var i = 0; i < n; i++) {
      var block = client.getTr(transactionHash).getBlock(i, true);
      for (var j = 0; j < block.transactions; j++) {
        if (block.transactions[j].to == the_address)
          txs.push(block.transactions[j]);
      }
    }
  }*/

  Future<void> dispose() async {
    await client.dispose();
  }
}
