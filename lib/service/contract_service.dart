import 'dart:async';

import 'package:hermez/utils/contract_parser.dart';
import 'package:web3dart/web3dart.dart';

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
    //this.tokenContractsAddress,
    /*this.contracts*/
  );

  final Web3Client client;
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
