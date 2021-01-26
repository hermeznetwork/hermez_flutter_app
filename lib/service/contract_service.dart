import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:hermez/service/network/api_eth_gas_station_client.dart';
import 'package:hermez/service/network/model/account.dart';
import 'package:hermez/service/network/model/accounts_response.dart';
import 'package:hermez/service/network/model/token.dart';
import 'package:hermez/utils/contract_parser.dart';
import 'package:hermez_plugin/addresses.dart' as addresses;
import 'package:hermez_plugin/api.dart' as api;
import 'package:hermez_plugin/constants.dart';
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
  ContractFunction _approve(DeployedContract contract) =>
      contract.function('approve');
  ContractFunction _allowance(DeployedContract contract) =>
      contract.function('allowance');
  ContractFunction _sendFunction(DeployedContract contract) =>
      contract.function('transfer');

  ContractFunction _addL1Transaction(DeployedContract contract) =>
      contract.function('addL1Transaction');

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
        'ERC20ABI.json', tokenContractAddress.toString(), tokenContractName);

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

  /// Makes a deposit.
  /// It detects if it's a 'createAccountDeposit' or a 'deposit' and prepares the parameters accordingly.
  /// Detects if it's an Ether, ERC 20 or ERC 777 token and sends the transaction accordingly.
  /// @param {BigInt} amount - The amount to be deposited
  /// @param {String} hezEthereumAddress - The Hermez address of the transaction sender
  /// @param {Object} token - The token information object as returned from the API
  /// @param {String} babyJubJub - The compressed BabyJubJub in hexadecimal format of the transaction sender.
  /// @param {String} providerUrl - Network url (i.e, http://localhost:8545). Optional
  /// @param {Object} signerData - Signer data used to build a Signer to send the transaction
  /// @param {Number} gasLimit - Optional gas limit
  /// @param {Number} gasMultiplier - Optional gas multiplier
  /// @returns {Promise} transaction parameters
  @override
  Future<void> deposit(
      BigInt amount, String hezEthereumAddress, Token token, String babyJubJub,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER}) async {
    /*tx.deposit(amount, addresses.getHermezAddress(ethereumAddress.hex),
        account.token, /*babyJubJub*/, null, null);*/

    final ethereumAddress = addresses.getEthereumAddress(hezEthereumAddress);

    final accountsResponse =
        await api.getAccounts(hezEthereumAddress, [token.id]);

    final AccountsResponse accounts =
        AccountsResponse.fromJson(json.decode(accountsResponse));
    final Account account = accounts != null ? accounts.accounts[0] : null;

    final hermezContract = await ContractParser.fromAssets(
        'HermezABI.json', contractAddresses['Hermez'], "Hermez");

    dynamic overrides = {gasLimit, await getGasPriceStr(gasMultiplier, client)};

    final transactionParameters = [
      account != null ? BigInt.zero : '0x' + babyJubJub,
      account != null
          ? BigInt.from(addresses.getAccountIndex(account.accountIndex))
          : BigInt.zero,
      BigInt.from(1),
      BigInt.zero,
      BigInt.from(token.id),
      BigInt.zero
    ];

    print([...transactionParameters, overrides]);

    if (token.id == 0) {
      overrides = Uint8List.fromList([2]);
      print([...transactionParameters, overrides]);
      /*return hermezContract.addL1Transaction(...transactionParameters, overrides)
          .then(() => {
          return transactionParameters
      })*/
      final addL1TransactionCall = await client.call(
          contract: hermezContract,
          function: _addL1Transaction(hermezContract),
          params: [...transactionParameters, overrides]);
    }

    /*final addL1TransactionCall = await client.call(
        contract: hermezContract,
        function: _addL1Transaction(hermezContract),
        params: null);*/
  }

  // ERC20 approve the spender account and set the limit of your funds that they are authorized to spend // EtherAmount
  Future<bool> approve(BigInt amount, EthereumAddress accountAddress,
      EthereumAddress contractAddress, String tokenContractName) async {
    final contract = await ContractParser.fromAssets(
        'ERC20ABI.json', contractAddress.toString(), tokenContractName);

    /*final allowanceCall = await client.call(
        contract: contract,
        function: _allowance(contract),
        params: [
          accountAddress,
          EthereumAddress.fromHex(contractAddresses['Hermez'])
        ]);

    final allowance = allowanceCall.first as double;

    //final amountBigInt = utils.getTokenAmountBigInt(amount, 2);

    if (allowance < amount) {
      var response = await client.call(
        contract: contract,
        function: _approve(contract),
        params: [contractAddresses['Hermez'], amount],
      );

      return response.first as bool;
    }

    if (!(allowance.sign == 0)) {
      var response = await client.call(
        contract: contract,
        function: _approve(contract),
        params: [contractAddresses['Hermez'], 0],
      );
      return response.first as bool;
    }*/

    var response = await client.call(
      sender: accountAddress,
      contract: contract,
      function: _approve(contract),
      params: [accountAddress, amount],
    );

    return response.first as bool;
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

  /// Get current average gas price from the last ethereum blocks and multiply it
  /// @param {Number} multiplier - multiply the average gas price by this parameter
  /// @param {String} providerUrl - Network url (i.e, http://localhost:8545). Optional
  /// @returns {Future<String>} - will return the gas price obtained.
  Future<String> getGasPriceStr(num multiplier, Web3Client provider) async {
    EtherAmount strAvgGas = await provider.getGasPrice();
    BigInt avgGas = strAvgGas.getInEther;
    BigInt res = avgGas * BigInt.from(multiplier);
    String retValue = res.toString();
    return retValue;
  }

  Future<void> dispose() async {
    await client.dispose();
  }
}
