import 'dart:async';

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
  ContractService(
    this.client,
    this._configService,
    //this.tokenContractsAddress,
    /*this.contracts*/
  );

  final Web3Client client;
  IConfigurationService _configService;
  //Credentials credentials;
  //final List<String> tokenContractsAddress;
  //final List<DeployedContract> contract;

  ContractEvent _transferEvent(DeployedContract contract) =>
      contract.event('Transfer');
  ContractFunction _balanceFunction(DeployedContract contract) =>
      contract.function('balanceOf');
  ContractFunction _approve(DeployedContract contract) =>
      contract.function('approve');
  ContractFunction _sendFunction(DeployedContract contract) =>
      contract.function('transfer');

  Future<Credentials> getCredentials(String privateKey) =>
      client.credentialsFromPrivateKey(privateKey);

  Future<String> transfer(String privateKey, EthereumAddress senderAddress,
      EthereumAddress receiverAddress, BigInt amountInWei,
      {TransferEvent onTransfer, Function onError}) async {
    print(
        'transfer --> privateKey: $privateKey, sender: $senderAddress, receiver: $receiverAddress, amountInWei: $amountInWei');

    /*bool isApproved = await _approveCb;
    if (!isApproved) {
      throw 'transaction not approved';
    }*/

    /*StreamSubscription event;
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
    }*/

    EtherAmount amount =
        EtherAmount.fromUnitAndValue(EtherUnit.wei, amountInWei);

    try {
      String txHash = await _sendTransactionAndWaitForReceipt(
          privateKey, senderAddress, receiverAddress, amount);
      print('transaction $txHash successful');
      return txHash;
    } catch (ex) {
      if (onError != null) {
        onError(ex);
      }
      return null;
    }
  }

  Future<String> _sendTransactionAndWaitForReceipt(
      String privateKey,
      EthereumAddress senderAddress,
      EthereumAddress receiverAddress,
      EtherAmount amount) async {
    print('sendTransactionAndWaitForReceipt');
    Transaction transaction =
        Transaction(from: senderAddress, to: receiverAddress, value: amount);

    final credentials = await this.getCredentials(privateKey);
    final networkId = await client.getNetworkId();

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

    EtherAmount etherAmount = await client.getGasPrice();

    final contract = await ContractParser.fromAssets('partialERC20ABI.json',
        tokenContractAddress.toString(), tokenContractName);

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
    final contract = await ContractParser.fromAssets('partialERC20ABI.json',
        tokenContractAddress.toString(), tokenContractName);

    var response = await client.call(
      contract: contract,
      function: _balanceFunction(contract),
      params: [from],
    );

    return response.first as BigInt;
  }

  Future<BigInt> getEstimatedGas(
    EthereumAddress from,
    EthereumAddress to,
    EtherAmount amount,
  ) async {
    return client.estimateGas(
      sender: from,
      to: to,
      value: amount,
      /*gasPrice: await client.getGasPrice()*/
    );
  }

  Future<EtherAmount> getGasPrice() {
    return client.getGasPrice();
  }

  // ERC20 approve the spender account and set the limit of your funds that they are authorized to spend
  Future<bool> approve(EthereumAddress delegate, BigInt limit,
      EthereumAddress tokenContractAddress, String tokenContractName) async {
    final contract = await ContractParser.fromAssets('partialERC20ABI.json',
        tokenContractAddress.toString(), tokenContractName);

    var response = await client.call(
      contract: contract,
      function: _approve(contract),
      params: [delegate, limit],
    );

    return response.first as bool;
  }

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
