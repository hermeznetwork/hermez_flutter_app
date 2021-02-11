import 'dart:async';

import 'package:hermez/service/network/api_eth_gas_station_client.dart';
import 'package:hermez/utils/contract_parser.dart';
import 'package:web3dart/web3dart.dart';

import 'configuration_service.dart';

typedef TransferEvent = void Function(
    EthereumAddress from, EthereumAddress to, BigInt value);

abstract class IContractService {
  Future<Credentials> getCredentials(String privateKey);
  Future<String> send(
      String privateKey,
      EthereumAddress receiver,
      BigInt amount,
      EthereumAddress tokenContractAddress,
      String tokenContractName,
      {TransferEvent onTransfer,
      Function onError});
  Future<BigInt> getTokenBalance(EthereumAddress from,
      EthereumAddress tokenContractAddress, String tokenContractName);
  Future<EtherAmount> getEthBalance(EthereumAddress from);
  Future<void> dispose();
  StreamSubscription listenTransfer(
      TransferEvent onTransfer, DeployedContract contract);
}

class ContractService implements IContractService {
  ContractService(this.client, this._configService, this._estimateGasPriceUrl
      //this.tokenContractsAddress,
      /*this.contracts*/
      );

  final Web3Client client;
  String _estimateGasPriceUrl;
  IConfigurationService _configService;
  //Credentials credentials;
  //final List<String> tokenContractsAddress;
  //final List<DeployedContract> contract;

  ApiEthGasStationClient _apiEthGasStationClient() =>
      ApiEthGasStationClient(this._estimateGasPriceUrl);

  ContractEvent _transferEvent(DeployedContract contract) =>
      contract.event('Transfer');
  ContractFunction _balanceFunction(DeployedContract contract) =>
      contract.function('balanceOf');
  ContractFunction _sendFunction(DeployedContract contract) =>
      contract.function('transfer');

  Future<Credentials> getCredentials(String privateKey) =>
      client.credentialsFromPrivateKey(privateKey);

  Future<String> sendEth(
      String privateKey, EthereumAddress receiverAddress, BigInt amountInWei,
      {TransferEvent onTransfer, Function onError}) async {
    /*final credentials = await this.getCredentials(privateKey);
    final from = await credentials.extractAddress();*/

    /*bool isApproved = await _approveCb;
    if (!isApproved) {
      throw 'transaction not approved';
    }*/

    EtherAmount amount =
        EtherAmount.fromUnitAndValue(EtherUnit.wei, amountInWei);

    try {
      String txHash =
          await _sendTransaction(privateKey, receiverAddress, amount);
      print('transaction $txHash successful');
      return txHash;
    } catch (ex) {
      if (onError != null) {
        onError(ex);
      }
      return null;
    }
  }

  Future<String> _sendTransaction(String privateKey,
      EthereumAddress receiverAddress, EtherAmount amount) async {
    print('sendTransaction');

    final credentials = await this.getCredentials(privateKey);
    final from = await credentials.extractAddress();
    final networkId = await client.getNetworkId();

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
        'transfer --> privateKey: $privateKey, sender: $from, receiver: $receiverAddress, amountInWei: $amount');

    String txHash = await client.sendTransaction(credentials, transaction,
        chainId: networkId);

    return txHash;
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

  Future<String> send(
      String privateKey,
      EthereumAddress receiver,
      BigInt amount,
      EthereumAddress tokenContractAddress,
      String tokenContractName,
      {TransferEvent onTransfer,
      Function onError}) async {
    final credentials = await this.getCredentials(privateKey);
    final from = await credentials.extractAddress();
    final networkId = await client.getNetworkId();

    double gasPrice = await _apiEthGasStationClient().getGasPrice();

    EtherAmount etherAmount = await client.getGasPrice();

    final contract = await ContractParser.fromAssets(
        'ERC20ABI.json', tokenContractAddress.toString(), tokenContractName);

    StreamSubscription event;
    // Workaround once sendTransacton doesn't return a Promise containing confirmation / receipt
    if (onTransfer != null) {
      event = listenTransfer(
        (from, to, value) async {
          onTransfer(from, to, value);
          await event.cancel();
        },
        contract,
        take: 1,
      );
    }

    try {
      //client.getBlockNumber()
      final transactionId = await client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: _sendFunction(contract),
          parameters: [receiver, amount],
          from: from,
        ),
        chainId: networkId,
      );
      print('transact started $transactionId');
      return transactionId;
    } catch (ex) {
      if (onError != null) {
        onError(ex);
      }
      return null;
    }
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
    EtherAmount amount,
  ) async {
    return client.estimateGas(
      sender: from,
      to: to,
      value: amount, /* gasPrice: await getGasPrice()*/
    );
  }

  Future<EtherAmount> getGasPrice() async {
    //double gasPrice = await _apiEthGasStationClient().getGasPrice();
    //return EtherAmount.fromUnitAndValue(
    //    EtherUnit.gwei, BigInt.from(gasPrice / 10));
    return client.getGasPrice();
    /*const strAvgGas = await client.getGasPrice()
    const avgGas = Scalar.e(strAvgGas)
    const res = (avgGas * Scalar.e(multiplier))
    const retValue = res.toString()*/
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

      print('$from}');
      print('$to}');
      print('$value}');

      onTransfer(from, to, value);
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
