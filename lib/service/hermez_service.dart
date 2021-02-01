import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:hermez/service/network/api_client.dart';
import 'package:hermez/service/network/api_exchange_rate_client.dart';
import 'package:hermez/service/network/model/account.dart';
import 'package:hermez/service/network/model/account_request.dart';
import 'package:hermez/service/network/model/accounts_request.dart';
import 'package:hermez/service/network/model/accounts_response.dart';
import 'package:hermez/service/network/model/exit.dart';
import 'package:hermez/service/network/model/exits_request.dart';
import 'package:hermez/service/network/model/rates_request.dart';
import 'package:hermez/service/network/model/recommended_fee.dart';
import 'package:hermez/service/network/model/state_response.dart';
import 'package:hermez/service/network/model/transaction.dart';
import 'package:hermez/utils/contract_parser.dart';
import 'package:hermez_plugin/addresses.dart' as addresses;
import 'package:hermez_plugin/api.dart' as api;
import 'package:hermez_plugin/constants.dart';
import 'package:hermez_plugin/tx.dart' as tx;
import 'package:web3dart/contracts.dart';
import 'package:web3dart/web3dart.dart' as web3;

import 'configuration_service.dart';
import 'network/model/token.dart';

abstract class IHermezService {
  Future<List<Account>> getAccounts(web3.EthereumAddress ethereumAddress);
  Future<Account> getAccount(String accountIndex);
  Future<List<Exit>> getExits(web3.EthereumAddress ethereumAddress);
  Future<List<Transaction>> getTransactions(
      web3.EthereumAddress ethereumAddress);
  Future<List<Token>> getTokens();
  Future<bool> deposit(
      BigInt amount, String hezEthereumAddress, Token token, String babyJubJub,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER});
  //Future<bool> withdraw(BigInt amount);
  Future<bool> sendL2Transaction(Transaction transaction);
}

class HermezService implements IHermezService {
  String _baseUrl;
  final web3.Web3Client client;
  String _exchangeUrl;
  IConfigurationService _configService;
  HermezService(
      this._baseUrl, this.client, this._exchangeUrl, this._configService);

  ApiClient _apiClient() => ApiClient(this._baseUrl);
  ApiExchangeRateClient _apiExchangeRateClient() =>
      ApiExchangeRateClient(_exchangeUrl);

  ContractFunction _addL1Transaction(DeployedContract contract) =>
      contract.function('addL1Transaction');
  ContractFunction _approve(DeployedContract contract) =>
      contract.function('approve');
  ContractFunction _allowance(DeployedContract contract) =>
      contract.function('allowance');
  ContractFunction _withdrawMerkleProof(DeployedContract contract) =>
      contract.function('withdrawMerkleProof');
  ContractFunction _withdrawal(DeployedContract contract) =>
      contract.function('withdrawal');

  @override
  Future<List<Account>> getAccounts(
      web3.EthereumAddress ethereumAddress) async {
    AccountsRequest accountsRequest = new AccountsRequest(
        hezEthereumAddress: addresses.getHermezAddress(ethereumAddress.hex),
        tokenIds: [3, 87, 91]);
    return _apiClient().getAccounts(accountsRequest);
  }

  @override
  Future<Account> getAccount(String accountIndex) async {
    AccountRequest accountRequest =
        new AccountRequest(accountIndex: accountIndex);
    return _apiClient().getAccount(accountRequest);
  }

  @override
  Future<List<Token>> getTokens() async {
    return _apiClient().getSupportedTokens(null);
  }

  Future<Token> getTokenById(int tokenId) {
    return _apiClient().getSupportedTokenById(tokenId.toString());
  }

  @override
  Future<List<Transaction>> getTransactions(
      web3.EthereumAddress ethereumAddress) async {
    // TODO: implement getTransactions
    return BuiltList<Transaction>().toList();
  }

  @override
  Future<bool> sendL2Transaction(Transaction transaction) {
    return _apiClient()
        .sendL2Transaction(transaction, null /*hermezPublicKeyHex*/);
  }

  @override
  Future<List<Exit>> getExits(web3.EthereumAddress ethereumAddress) {
    ExitsRequest exitsRequest = new ExitsRequest(
        hezEthereumAddress: addresses.getHermezAddress(ethereumAddress.hex),
        onlyPendingWithdraws: true);
    return _apiClient().getExits(exitsRequest);
  }

  Future<RecommendedFee> getRecommendedFee() async {
    final String stateResponse = await api.getState();

    final StateResponse state =
        StateResponse.fromJson(json.decode(stateResponse));
    return state.recommendedFee;
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
  Future<bool> deposit(
      BigInt amount, String hezEthereumAddress, Token token, String babyJubJub,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER}) async {
    /*tx.deposit(amount, addresses.getHermezAddress(ethereumAddress.hex),
        account.token, /*babyJubJub*/, null, null);*/

    final ethereumAddress = addresses.getEthereumAddress(hezEthereumAddress);

    final accountsResponse =
        await api.getAccounts(hezEthereumAddress, [token.id]);

    final AccountsResponse accounts =
        AccountsResponse.fromJson(json.decode(accountsResponse));
    final Account account = accounts != null && accounts.accounts.isNotEmpty
        ? accounts.accounts[0]
        : null;

    final hermezContract = await ContractParser.fromAssets(
        'HermezABI.json', contractAddresses['Hermez'], "Hermez");

    dynamic overrides = Uint8List.fromList(
        [gasLimit, await getGasPriceBigInt(gasMultiplier, client)]);

    final transactionParameters = [
      account != null
          ? BigInt.zero
          : BigInt.parse('0x' + babyJubJub, radix: 16),
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
      overrides = Uint8List.fromList([amount.toInt()]);
      print([...transactionParameters, overrides]);
      final addL1TransactionCall = await client.call(
          contract: hermezContract,
          function: _addL1Transaction(hermezContract),
          params: [...transactionParameters, overrides]);

      return true;
    }

    await approve(amount, ethereumAddress, token.ethereumAddress, token.name);

    final addL1TransactionCall = await client.call(
        contract: hermezContract,
        function: _addL1Transaction(hermezContract),
        params: [...transactionParameters, overrides]);

    return true;
  }

  /// Sends an approve transaction to an ERC 20 contract for a certain amount of tokens
  /// @param {BigInt} amount - Amount of tokens to be approved by the ERC 20 contract
  /// @param {String} accountAddress - The Ethereum address of the transaction sender
  /// @param {String} contractAddress - The token smart contract address
  /// @param {Object} signerData - Signer data used to build a Signer to send the transaction
  /// @param {String} providerUrl - Network url (i.e, http://localhost:8545). Optional
  /// @returns {Promise} transaction
  // ERC20 approve the spender account and set the limit of your funds that they are authorized to spend // EtherAmount
  Future<bool> approve(BigInt amount, String accountAddress,
      String contractAddress, String tokenContractName) async {
    final contract = await ContractParser.fromAssets(
        'ERC20ABI.json', contractAddress, tokenContractName);

    try {
      final allowanceCall = await client
          .call(contract: contract, function: _allowance(contract), params: [
        web3.EthereumAddress.fromHex(accountAddress),
        web3.EthereumAddress.fromHex(contractAddresses['Hermez'])
      ]);
      final allowance = allowanceCall.first as BigInt;

      if (allowance < amount) {
        var response = await client.call(
          contract: contract,
          function: _approve(contract),
          params: [
            web3.EthereumAddress.fromHex(contractAddresses['Hermez']),
            amount
          ],
        );

        return response.first as bool;
      }

      if (!(allowance.sign == 0)) {
        var response = await client.call(
          contract: contract,
          function: _approve(contract),
          params: [
            web3.EthereumAddress.fromHex(contractAddresses['Hermez']),
            0
          ],
        );
        return response.first as bool;
      }

      var response = await client.call(
        contract: contract,
        function: _approve(contract),
        params: [web3.EthereumAddress.fromHex(accountAddress), amount],
      );

      return response.first as bool;
    } catch (error, trace) {
      print(error);
      print(trace);
    }
  }

  Future<void> withdraw(BigInt amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER}) async {
    final withdrawalId = account.accountIndex + exit.merkleProof.root;

    if (!completeDelayedWithdrawal) {
      /*tx.withdraw(
          amount,
          account.accountIndex,
          account.token,
          /*babyjubjub*/ null,
          BigInt.from(exit.batchNum),
          exit.merkleProof.siblings,
          null,
          null);*/

      final hermezContract = await ContractParser.fromAssets(
          'HermezABI.json', contractAddresses['Hermez'], "Hermez");

      dynamic overrides = Uint8List.fromList(
          [gasLimit, await getGasPriceBigInt(gasMultiplier, client)]);

      final transactionParameters = [
        account.token.id,
        amount,
        /*'0x$babyJubJub'*/ '0x',
        BigInt.from(exit.batchNum),
        exit.merkleProof.siblings,
        addresses.getAccountIndex(account.accountIndex),
        instantWithdrawal,
      ];

      print([...transactionParameters, overrides]);

      final l1Transaction = new List()..addAll(transactionParameters);
      l1Transaction.add(overrides);

      final withdrawMerkleProofCall = await client.call(
          contract: hermezContract,
          function: _withdrawMerkleProof(hermezContract),
          params: [...transactionParameters, overrides]);
    } else {
      tx.delayedWithdraw(
          /*wallet.hermezAddress*/ null,
          account.token,
          null,
          null);

      final withdrawalDelayerContract = await ContractParser.fromAssets(
          'WithdrawalDelayerABI.json',
          contractAddresses['WithdrawalDelayer'],
          "WithdrawalDelayer");

      dynamic overrides = Uint8List.fromList(
          [gasLimit, await getGasPriceBigInt(gasMultiplier, client)]);

      final String ethereumAddress = '0x';
      //addresses.getEthereumAddress(hezEthereumAddress);

      final transactionParameters = [
        ethereumAddress,
        account.token.id == 0 ? 0x0 : account.token.ethereumAddress
      ];

      final withdrawalCall = await client.call(
          contract: withdrawalDelayerContract,
          function: _withdrawal(withdrawalDelayerContract),
          params: [...transactionParameters, overrides]);
    }
  }

  Future<void> forceExit(BigInt amount, Account account,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER}) async {
    //tx.forceExit(amount, account.accountIndex, account.token, null, null);

    final hermezContract = await ContractParser.fromAssets(
        'HermezABI.json', contractAddresses['Hermez'], "Hermez");

    dynamic overrides = Uint8List.fromList(
        [gasLimit, await getGasPriceBigInt(gasMultiplier, client)]);

    final transactionParameters = [
      BigInt.zero,
      addresses.getAccountIndex(account.accountIndex),
      BigInt.zero,
      amount,
      account.token.id,
      1,
      '0x'
    ];

    final addL1TransactionCall = await client.call(
        contract: hermezContract,
        function: _addL1Transaction(hermezContract),
        params: [...transactionParameters, overrides]);
  }

  /// Get current average gas price from the last ethereum blocks and multiply it
  /// @param {Number} multiplier - multiply the average gas price by this parameter
  /// @param {String} providerUrl - Network url (i.e, http://localhost:8545). Optional
  /// @returns {Future<String>} - will return the gas price obtained.
  Future<int> getGasPriceBigInt(
      num multiplier, web3.Web3Client provider) async {
    web3.EtherAmount strAvgGas = await provider.getGasPrice();
    BigInt avgGas = strAvgGas.getInEther;
    BigInt res = avgGas * BigInt.from(multiplier);
    int retValue = res.toInt(); //toString();
    return retValue;
  }

  @override
  Future<double> getEURUSDExchangeRatio() async {
    final request = RatesRequest.fromJson({
      "base": "USD",
      "symbols": {"EUR"},
    });
    double response = await _apiExchangeRateClient().getExchangeRates(request);
    return response;
  }
}
