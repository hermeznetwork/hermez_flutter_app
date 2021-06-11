import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/constants.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/service/address_service.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/service/contract_service.dart';
import 'package:hermez/service/exchange_service.dart';
import 'package:hermez/service/explorer_service.dart';
import 'package:hermez/service/hermez_service.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/service/storage_service.dart';
import 'package:hermez/utils/contract_parser.dart';
import 'package:hermez_sdk/addresses.dart' as addresses;
import 'package:hermez_sdk/api.dart';
import 'package:hermez_sdk/environment.dart';
import 'package:hermez_sdk/hermez_compressed_amount.dart';
import 'package:hermez_sdk/hermez_wallet.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/forged_transactions_request.dart';
import 'package:hermez_sdk/model/forged_transactions_response.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';
import 'package:hermez_sdk/model/recommended_fee.dart';
import 'package:hermez_sdk/model/state_response.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/model/transaction.dart';
import 'package:hermez_sdk/tx_pool.dart' as tx_pool;
import 'package:hermez_sdk/tx_utils.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3;

import 'wallet_state.dart';

class WalletHandler {
  WalletHandler(
      this._store,
      this._addressService,
      this._contractService,
      this._explorerService,
      this._configurationService,
      this._storageService,
      this._hermezService,
      this._exchangeService);

  final Store<Wallet, WalletAction> _store;
  final AddressService _addressService;
  final ContractService _contractService;
  final ExplorerService _explorerService;
  final StorageService _storageService;
  final ConfigurationService _configurationService;
  final HermezService _hermezService;
  final ExchangeService _exchangeService;

  Wallet get state => _store.state;

  Future<void> initialise() async {
    try {
      _store.dispatch(InitializingWallet());
      print("Initializing Wallet");
      final entropyMnemonic = await _configurationService.getMnemonic();

      if (entropyMnemonic != null && entropyMnemonic.isNotEmpty) {
        await _initialiseFromMnemonic(entropyMnemonic);
        return;
      }

      final privateKey = await _configurationService.getPrivateKey();
      await _initialiseFromPrivateKey(privateKey);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> initialiseReadOnly() async {
    _store.dispatch(InitializingWallet());
    print("Initializing Wallet");
    final entropyMnemonic = await _configurationService.getMnemonic();
    final privateKey = await _configurationService.getPrivateKey();
    final ethereumAddress = await _configurationService.getEthereumAddress();

    if (privateKey != null &&
        privateKey.isNotEmpty &&
        ethereumAddress != null &&
        ethereumAddress.isNotEmpty) {
      await _initialiseFromStoredData(privateKey, ethereumAddress);
      return;
    }

    if (entropyMnemonic != null && entropyMnemonic.isNotEmpty) {
      await _initialiseFromMnemonic(entropyMnemonic);
      return;
    }

    _initialiseFromPrivateKey(privateKey);
  }

  Future<void> _initialiseFromMnemonic(String entropyMnemonic) async {
    final mnemonic = _addressService.entropyToMnemonic(entropyMnemonic);
    final privateKey = _addressService.getPrivateKey(mnemonic);
    final address = await _addressService.getEthereumAddress(privateKey);
    await _initialise();
    _store.dispatch(WalletInitialized(address.toString(), privateKey));
    print("Wallet Initialized");
  }

  Future<void> _initialiseFromPrivateKey(String privateKey) async {
    final address = await _addressService.getEthereumAddress(privateKey);
    await _initialise();
    _store.dispatch(WalletInitialized(address.toString(), privateKey));
    print("Wallet Initialized");
  }

  Future<void> _initialiseFromStoredData(
      String privateKey, String ethereumAddress) async {
    await _initialise();
    _store.dispatch(WalletInitialized(ethereumAddress, privateKey));
    print("Wallet Initialized");
  }

  Future<void> _initialise() async {
    final levelSelected = await _configurationService.getLevelSelected();
    _store.dispatch(LevelUpdated(levelSelected));

    final defaultCurrency = await _configurationService.getDefaultCurrency();
    _store.dispatch(DefaultCurrencyUpdated(defaultCurrency));

    final defaultFee = await _configurationService.getDefaultFee();
    _store.dispatch(DefaultFeeUpdated(defaultFee));

    final exchangeRatio = await _exchangeService
        .getFiatExchangeRates(["EUR", "CNY", "JPY", "GBP"]);
    await _configurationService.setExchangeRatio(exchangeRatio);
    _store.dispatch(ExchangeRatioUpdated(exchangeRatio[
        (await _configurationService.getDefaultCurrency())
            .toString()
            .split(".")
            .last]));

    //final state = await getState();

    /*final exchangeRatio = await _hermezService.getEURUSDExchangeRatio();
    _configurationService.setExchangeRatio(exchangeRatio);
    _store.dispatch(ExchangeRatioUpdated(exchangeRatio));*/

    /*final address = await _configurationService.getEthereumAddress();
    final createAccountAuth = await _hermezService
        .getCreateAccountAuthorization(web3.EthereumAddress.fromHex(address));*/

    //if (createAccountAuth == null) {
    await authorizeAccountCreation();
    //}
    //await this.fetchOwnBalance();

    /*
    // TODO uncomment
    _contractService.listenTransfer((from, to, value) async {
      var fromMe = from.toString() == state.address;
      var toMe = to.toString() == state.address;

      if (!fromMe && !toMe) {
        return;
      }

      print('======= balance updated =======');

      await fetchOwnBalance(supportedTokens);
    });*/
  }

  /*Future<void> fetchOwnL1Balance() async {
    if (state != null && state.ethereumAddress != null) {
      final supportedTokens = await _hermezService.getTokens();
      _store.dispatch(UpdatingBalance());

      web3.EtherAmount ethBalance = web3.EtherAmount.zero();
      Map<String, BigInt> tokensBalance = Map();
      List<Account> accounts = List();

      for (Token token in supportedTokens) {
        if (token.id == 0) {
          // GET L1 ETH Balance
          ethBalance = await _contractService.getEthBalance(
              web3.EthereumAddress.fromHex(state.ethereumAddress));

          if (ethBalance.getInWei > BigInt.zero) {
            final account = Account(
                accountIndex: "0",
                balance: ethBalance.getInWei.toString(),
                bjj: "",
                hezEthereumAddress: state.ethereumAddress,
                itemId: 0,
                nonce: 0,
                token: token);
            accounts.add(account);
          }
        } else {
          var tokenBalance = BigInt.zero;
          try {
            tokenBalance = await _contractService.getTokenBalance(
                web3.EthereumAddress.fromHex(state.ethereumAddress),
                web3.EthereumAddress.fromHex(token.ethereumAddress),
                token.name);
          } catch (error) {}
          if (tokenBalance > BigInt.zero) {
            var tokenAmount = web3.EtherAmount.fromUnitAndValue(
                web3.EtherUnit.wei, tokenBalance);
            final account = Account(
                accountIndex: "0",
                balance: tokenAmount.getInWei.toString(),
                bjj: "",
                hezEthereumAddress: state.ethereumAddress,
                itemId: 0,
                nonce: 0,
                token: token);
            accounts.add(account);
            tokensBalance[token.symbol] = tokenBalance;
          }
        }
      }

      _store.dispatch(
          BalanceUpdated(ethBalance.getInWei, tokensBalance, accounts));
    }
  }

  Future<void> fetchOwnL2Balance() async {
    final accounts = await _hermezService.getAccounts(
        web3.EthereumAddress.fromHex(state.ethereumAddress), [3, 87, 91]);
    _store.dispatch(UpdatingBalance());

    List<Account> L2accounts = List();
    var ethBalance = web3.EtherAmount.fromUnitAndValue(web3.EtherUnit.wei, 0);

    Map<String, BigInt> tokensBalance = Map();

    for (Account account in accounts) {
      var balance = BigInt.parse(account.balance);
      // if tokenId == 0 -> ETH
      if (account.token.symbol == "ETH") {
        ethBalance =
            web3.EtherAmount.fromUnitAndValue(web3.EtherUnit.wei, balance);
      } else {
        tokensBalance[account.token.symbol] = balance;
      }
    }

    //var accounts = await _hermezService
    //    .getAccounts(web3.EthereumAddress.fromHex(state.address));

    // TEST ENVIRONMENT
    /*Map<String, String> headers = {
      'X-CMC_PRO_API_KEY': '87529169-9e17-4393-939e-39c4737dbd80',
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
    };
    String _apiURL =
        "https://sandbox-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?start=1&limit=100&convert=USD";
    String symbols = "ETH,USDT,BNB,LINK,LEO,USDC,HT,VEST,COMP,MKR,HEDG,BAT,INO,CRO,ZRX,OKB,KNC,SNX,LEND";//,HT,VEST,COMP,MKR,HEDG,cUSDC,BAT,INO,CRO,ZRX,OKB,KNC,SNX,LEND";
    String _apiURL2 =
        "https://sandbox-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=$symbols&convert=USD";
    var response = await http.get(_apiURL2, headers: headers); //waits for response
    String body = response.body;
    Map result = jsonDecode(body);
    var cryptoList = result["data"].values.toList();*/
    //final cryptoList = List();

    _store.dispatch(
        BalanceUpdated(ethBalance.getInWei, tokensBalance, L2accounts));
  }*/

  Future<bool> getAccounts() async {
    try {
      //_store.dispatch(UpdatingWallet());
      print('Updating Wallet');
      List<Account> l1Accounts = await getL1Accounts(true);
      List<Account> l2Accounts = await getL2Accounts();
      List<Exit> exits = await getExits();
      List<PoolTransaction> pendingL2Txs = await getPoolTransactions();
      List<dynamic> pendingL1Transfers = await getPendingTransfers();
      List<dynamic> pendingDeposits = await getPendingDeposits();
      List<dynamic> pendingWithdraws = await getPendingWithdraws();
      List<dynamic> pendingForceExits = await getPendingForceExits();
      _store.dispatch(WalletUpdated(
          l1Accounts,
          l2Accounts,
          exits,
          pendingL2Txs,
          pendingL1Transfers,
          pendingDeposits,
          pendingWithdraws,
          pendingForceExits));
      print('Wallet Updated');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<Account>> getL1Accounts(bool showZeroBalanceAccounts) async {
    List<Account> accounts = [];
    if (state != null && state.ethereumAddress != null) {
      final supportedTokens = await _hermezService.getTokens();

      //_store.dispatch(UpdatingBalance());

      for (Token token in supportedTokens) {
        if (token.id == 0) {
          // GET L1 ETH Balance
          web3.EtherAmount ethBalance = await _contractService.getEthBalance(
              web3.EthereumAddress.fromHex(state.ethereumAddress));
          if (ethBalance.getInWei > BigInt.zero) {
            final account = Account(
                accountIndex: token.id.toString(),
                balance: ethBalance.getInWei.toString(),
                bjj: "",
                hezEthereumAddress: state.ethereumAddress,
                itemId: 0,
                nonce: 0,
                token: token);
            accounts.add(account);
          } else {
            List<dynamic> transactions = await getEthereumTransactionsByAddress(
                state.ethereumAddress, token, null);
            if (transactions != null && transactions.isNotEmpty) {
              final account = Account(
                  accountIndex: token.id.toString(),
                  balance: ethBalance.getInWei.toString(),
                  bjj: "",
                  hezEthereumAddress: state.ethereumAddress,
                  itemId: 0,
                  nonce: 0,
                  token: token);
              accounts.add(account);
            }
          }
        } else {
          //Map<String, BigInt> tokensBalance = Map();
          var tokenBalance = BigInt.zero;
          try {
            tokenBalance = await _contractService.getTokenBalance(
                web3.EthereumAddress.fromHex(state.ethereumAddress),
                web3.EthereumAddress.fromHex(token.ethereumAddress),
                token.name);
          } catch (error) {
            throw error;
          }
          var tokenAmount = web3.EtherAmount.fromUnitAndValue(
              web3.EtherUnit.wei, tokenBalance);
          if (tokenBalance > BigInt.zero) {
            final account = Account(
                accountIndex: token.id.toString(),
                balance: tokenAmount.getInWei.toString(),
                bjj: "",
                hezEthereumAddress: state.ethereumAddress,
                itemId: 0,
                nonce: 0,
                token: token);
            accounts.add(account);
          } else {
            if (showZeroBalanceAccounts) {
              List<dynamic> transactions =
                  await getEthereumTransactionsByAddress(
                      state.ethereumAddress, token, null);
              if (transactions != null && transactions.isNotEmpty) {
                final account = Account(
                    accountIndex: token.id.toString(),
                    balance: tokenAmount.getInWei.toString(),
                    bjj: "",
                    hezEthereumAddress: state.ethereumAddress,
                    itemId: 0,
                    nonce: 0,
                    token: token);
                accounts.add(account);
                //tokensBalance[token.symbol] = tokenBalance;
              }
            }
          }
        }
      }

      // _store.dispatch(
      //     BalanceUpdated(ethBalance.getInWei, tokensBalance, accounts));
    }
    return accounts;
  }

  Future<List<Account>> getL2Accounts(
      {String ethereumAddress, List<int> tokenIds}) async {
    if (ethereumAddress == null) {
      ethereumAddress = state.ethereumAddress;
    }
    if (tokenIds == null) {
      tokenIds = [];
    }
    final accounts = await _hermezService.getAccounts(
        web3.EthereumAddress.fromHex(ethereumAddress), tokenIds);

    return accounts;
  }

  Future<Account> getAccount(String accountIndex) async {
    Account account = await _hermezService.getAccount(accountIndex);
    return account;
  }

  Future<Account> getL1Account(int tokenId) async {
    if (state != null && state.ethereumAddress != null) {
      final supportedTokens = await _hermezService.getTokens();
      Token token = supportedTokens.firstWhere(
          (supportedToken) => supportedToken.id == tokenId,
          orElse: () => null);
      if (token != null) {
        if (tokenId == 0) {
          // GET L1 ETH Balance
          web3.EtherAmount ethBalance = await _contractService.getEthBalance(
              web3.EthereumAddress.fromHex(state.ethereumAddress));
          final account = Account(
              accountIndex: tokenId.toString(),
              balance: ethBalance.getInWei.toString(),
              bjj: "",
              hezEthereumAddress: state.ethereumAddress,
              itemId: 0,
              nonce: 0,
              token: token);
          return account;
        } else {
          var tokenBalance = BigInt.zero;
          try {
            tokenBalance = await _contractService.getTokenBalance(
                web3.EthereumAddress.fromHex(state.ethereumAddress),
                web3.EthereumAddress.fromHex(token.ethereumAddress),
                token.name);
          } catch (error) {
            throw error;
          }
          var tokenAmount = web3.EtherAmount.fromUnitAndValue(
              web3.EtherUnit.wei, tokenBalance);

          final account = Account(
              accountIndex: token.id.toString(),
              balance: tokenAmount.getInWei.toString(),
              bjj: "",
              hezEthereumAddress: state.ethereumAddress,
              itemId: 0,
              nonce: 0,
              token: token);
          return account;
        }
      } else {
        return null;
      }
    }
  }

  Future<StateResponse> getState() async {
    final state = await _hermezService.getState();
    return state;
  }

  Future<void> getBlockAvgTime() async {
    await _explorerService.getBlockAvgTime();
  }

  Future<List<Token>> getTokens() async {
    final supportedTokens = await _hermezService.getTokens();
    return supportedTokens;
  }

  Future<Token> getTokenById(int tokenId) async {
    final supportedToken = await _hermezService.getTokenById(tokenId);
    return supportedToken;
  }

  Future<List<Exit>> getExits(
      {bool onlyPendingWithdraws = true, int tokenId = -1}) async {
    final exits = await _hermezService.getExits(
        web3.EthereumAddress.fromHex(state.ethereumAddress),
        onlyPendingWithdraws: onlyPendingWithdraws,
        tokenId: tokenId);
    exits.sort((exit1, exit2) {
      return exit2.itemId.compareTo(exit1.itemId);
    });
    return exits;
  }

  Future<List<dynamic>> getPendingTransfers() async {
    final storage =
        await _storageService.getStorage(PENDING_TRANSFERS_KEY, false);
    final chainId = getCurrentEnvironment().chainId.toString();
    final ethereumAddress = await _configurationService.getEthereumAddress();
    final List accountPendingTransfers = _storageService
        .getItemsByHermezAddress(storage, chainId, ethereumAddress);

    List transferIds = [];
    for (final pendingTransfer in accountPendingTransfers) {
      try {
        final transactionHash = pendingTransfer['txHash'];
        web3.TransactionReceipt receipt =
            await _contractService.getTxReceipt(transactionHash);
        List<dynamic> transactions = await getEthereumTransactionsByAddress(
            ethereumAddress, Token.fromJson(pendingTransfer['token']), 0);
        final transactionFound = transactions.firstWhere(
            (transaction) => transaction['txHash'] == transactionHash,
            orElse: () => null);
        if (transactionFound != null ||
            (receipt != null && receipt.status == false)) {
          transferIds.add(transactionHash);
          await _configurationService.removePendingTransfer(transactionHash);
        }
      } catch (e) {
        print(e.toString());
      }
    }

    accountPendingTransfers.removeWhere(
        (pendingTransfer) => transferIds.contains(pendingTransfer['txHash']));

    return accountPendingTransfers.reversed.toList();
  }

  Future<List<dynamic>> getPendingForceExits() async {
    final storage =
        await _storageService.getStorage(PENDING_FORCE_EXITS_KEY, false);
    final chainId = getCurrentEnvironment().chainId.toString();
    final ethereumAddress = await _configurationService.getEthereumAddress();
    final List accountPendingForceExits = _storageService
        .getItemsByHermezAddress(storage, chainId, ethereumAddress);

    List forceExitIds = [];
    for (final pendingForceExit in accountPendingForceExits) {
      final transactionHash = pendingForceExit['hash'];
      web3.TransactionReceipt receipt =
          await _contractService.getTxReceipt(transactionHash);
      if (receipt != null) {
        if (receipt.status == false) {
          // Tx didn't pass
          if (pendingForceExit['id'] == null) {
            pendingForceExit['id'] = transactionHash;
            accountPendingForceExits[accountPendingForceExits.indexWhere(
                    (element) => element['hash'] == pendingForceExit['hash'])] =
                pendingForceExit;
            await _configurationService.updatePendingForceExitId(
                transactionHash, transactionHash);
          }
          forceExitIds.add(transactionHash);
          await _configurationService.removePendingForceExit(transactionHash);
        } else {
          final hermezContract = await ContractParser.fromAssets(
              'HermezABI.json',
              getCurrentEnvironment().contracts['Hermez'],
              "Hermez");
          final contractEvent = hermezContract.event('L1UserTxEvent');
          for (var log in receipt.logs) {
            if (log['address'] == hermezContract.address.hex) {
              try {
                List<String> topics = List<String>.from(
                    log['topics'].map((topic) => topic.toString()));
                List l1UserTxEvent =
                    contractEvent.decodeResults(topics, log['data']);
                final transactionId =
                    getL1UserTxId(l1UserTxEvent[0], l1UserTxEvent[1]);

                if (pendingForceExit['id'] == null) {
                  pendingForceExit['id'] = transactionId;
                  accountPendingForceExits[accountPendingForceExits.indexWhere(
                          (element) =>
                              element['hash'] == pendingForceExit['hash'])] =
                      pendingForceExit;
                  _configurationService.updatePendingForceExitId(
                      transactionHash, transactionId);
                }

                final forgedTransaction =
                    await getHistoryTransaction(transactionId);
                if (forgedTransaction != null &&
                    forgedTransaction.batchNum != null) {
                  forceExitIds.add(transactionHash);
                  _configurationService.removePendingForceExit(transactionHash,
                      name: 'hash');
                }
              } catch (e) {
                print(e.toString());
              }
            }
          }
        }
      }
    }

    accountPendingForceExits.removeWhere(
        (pendingForceExit) => forceExitIds.contains(pendingForceExit['hash']));

    return accountPendingForceExits.reversed.toList();
  }

  Future<List<dynamic>> getPendingDeposits() async {
    final storage =
        await _storageService.getStorage(PENDING_DEPOSITS_KEY, false);
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress =
        await _configurationService.getHermezAddress();
    final List accountPendingDeposits = _storageService.getItemsByHermezAddress(
        storage, chainId, hermezEthereumAddress);

    List depositIds = [];
    for (final pendingDeposit in accountPendingDeposits) {
      final transactionHash = pendingDeposit['txHash'];
      web3.TransactionReceipt receipt =
          await _contractService.getTxReceipt(transactionHash);
      if (receipt != null) {
        if (receipt.status == false) {
          // Tx didn't pass
          if (pendingDeposit['id'] == null) {
            pendingDeposit['id'] = transactionHash;
            accountPendingDeposits[accountPendingDeposits.indexWhere(
                    (element) =>
                        element['txHash'] == pendingDeposit['txHash'])] =
                pendingDeposit;
            _configurationService.updatePendingDepositId(
                transactionHash, transactionHash);
          }
          depositIds.add(transactionHash);
          _configurationService.removePendingDeposit(transactionHash);
        } else {
          final hermezContract = await ContractParser.fromAssets(
              'HermezABI.json',
              getCurrentEnvironment().contracts['Hermez'],
              "Hermez");
          final contractEvent = hermezContract.event('L1UserTxEvent');
          for (var log in receipt.logs) {
            if (log['address'] == hermezContract.address.hex) {
              try {
                List<String> topics = List<String>.from(
                    log['topics'].map((topic) => topic.toString()));
                List l1UserTxEvent =
                    contractEvent.decodeResults(topics, log['data']);
                final transactionId =
                    getL1UserTxId(l1UserTxEvent[0], l1UserTxEvent[1]);

                if (pendingDeposit['id'] == null) {
                  pendingDeposit['id'] = transactionId;
                  accountPendingDeposits[accountPendingDeposits.indexWhere(
                          (element) =>
                              element['txHash'] == pendingDeposit['txHash'])] =
                      pendingDeposit;
                  _configurationService.updatePendingDepositId(
                      transactionHash, transactionId);
                }

                final forgedTransaction =
                    await getHistoryTransaction(transactionId);
                if (forgedTransaction != null &&
                    forgedTransaction.batchNum != null) {
                  depositIds.add(transactionHash);
                  _configurationService.removePendingDeposit(transactionHash);
                }
              } catch (e) {
                print(e.toString());
              }
            }
          }
        }
      }
      /*
      web3.TransactionInformation transaction =
          await _contractService.getTransactionByHash(transactionHash);
      if (transaction != null && transaction.transactionIndex != null) {
        depositIds.add(transactionId);
        _configurationService.removePendingDeposit(transactionId);
      }*/
    }

    accountPendingDeposits.removeWhere(
        (pendingDeposit) => depositIds.contains(pendingDeposit['txHash']));

    return accountPendingDeposits.reversed.toList();
  }

  Future<List<dynamic>> getPendingWithdraws() async {
    final List accountPendingWithdraws =
        await _configurationService.getPendingWithdraws();

    List removeWithdawalIds = [];
    List removeWithdawalHashes = [];
    List updateWithdawalIds = [];
    List<dynamic> updatePendingWithdraws = [];
    accountPendingWithdraws.forEach((pendingWithdraw) async {
      final String transactionHash = pendingWithdraw['hash'];
      final String status = pendingWithdraw['status'];
      Exit exit;
      if (pendingWithdraw['accountIndex'] != null &&
          pendingWithdraw['batchNum'] != null &&
          (status == 'pending' || status == 'completed')) {
        exit = await getExit(
            pendingWithdraw['accountIndex'], pendingWithdraw['batchNum']);
        if (exit.instantWithdraw != null || exit.delayedWithdraw != null) {
          final withdrawalId = exit.accountIndex + exit.batchNum.toString();
          removeWithdawalIds.add(withdrawalId);
          _configurationService.removePendingWithdraw(withdrawalId);
        }
      }

      if (transactionHash != null) {
        web3.TransactionInformation txInfo;
        try {
          txInfo = await _contractService.getTransactionByHash(transactionHash);
        } catch (e) {
          // wait an hour and if not, it failed
          if ((pendingWithdraw['instant'] == true ||
                  pendingWithdraw['status'] == 'completed') &&
              (DateTime.now().subtract(Duration(hours: 1)).isAfter(
                  DateTime.fromMillisecondsSinceEpoch(
                      pendingWithdraw['date'])))) {
            if (exit == null) {
              removeWithdawalHashes.add(transactionHash);
              _configurationService.removePendingWithdraw(transactionHash,
                  name: 'hash');
            } else {
              String status = 'fail';
              pendingWithdraw['status'] = status;
              final withdrawalId = exit.accountIndex + exit.batchNum.toString();
              updateWithdawalIds.add(withdrawalId);
              updatePendingWithdraws.add(withdrawalId);
              _configurationService.updatePendingWithdraw(
                  'status', status, withdrawalId);
            }
          }
        }
        if (txInfo != null) {
          web3.TransactionReceipt receipt =
              await _contractService.getTxReceipt(transactionHash);
          if (receipt != null) {
            if (receipt.status == false) {
              // Tx didn't pass
              if (exit == null) {
                removeWithdawalHashes.add(transactionHash);
                _configurationService.removePendingWithdraw(transactionHash,
                    name: 'hash');
              } else {
                String status = 'fail';
                pendingWithdraw['status'] = status;
                final withdrawalId =
                    exit.accountIndex + exit.batchNum.toString();
                updateWithdawalIds.add(withdrawalId);
                updatePendingWithdraws.add(withdrawalId);
                _configurationService.updatePendingWithdraw(
                    'status', status, withdrawalId);
              }
            } else {
              if (status == 'initiated') {
                List<Exit> exits = await getExits(
                    tokenId: Token.fromJson(pendingWithdraw['token']).id);
                exit = exits.firstWhere(
                    (Exit exit) =>
                        pendingWithdraw['accountIndex'] == exit.accountIndex &&
                        (pendingWithdraw['amount'] as double)
                                .toInt()
                                .toString() ==
                            exit.balance &&
                        Token.fromJson(pendingWithdraw['token']).id ==
                            exit.token.id &&
                        (exit.instantWithdraw == null &&
                            exit.delayedWithdraw == null),
                    orElse: () => null);
                if (exit != null) {
                  removeWithdawalHashes.add(transactionHash);
                  _configurationService.removePendingWithdraw(transactionHash,
                      name: 'hash');
                }
              }
            }
          }
        }
      }
    });

    /*accountPendingWithdraws[accountPendingWithdraws.indexWhere(
            (pendingWithdraw) =>
                updateWithdawalIds.contains(pendingWithdraw['id']))] =
        updatePendingWithdraws[0];*/

    accountPendingWithdraws.removeWhere((pendingWithdraw) =>
        removeWithdawalIds.contains(pendingWithdraw['id']));

    accountPendingWithdraws.removeWhere((pendingWithdraw) =>
        removeWithdawalHashes.contains(pendingWithdraw['hash']));

    return accountPendingWithdraws;
  }

  /// Fetches the details of an exit
  /// @param {string} accountIndex - account index
  /// @param {number} batchNum - batch number
  /// @returns {Exit}
  Future<Exit> getExit(String accountIndex, int batchNum) {
    return _hermezService.getExit(batchNum, accountIndex);
  }

  /// Fetches the recommended fees from the Coordinator
  /// @returns {RecommendedFee}
  Future<RecommendedFee> fetchFees() {
    return _hermezService.getRecommendedFee();
  }

  Future<bool> getCreateAccountAuthorization(String ethereumAddress) async {
    final createAccountAuth =
        await _hermezService.getCreateAccountAuthorization(
            web3.EthereumAddress.fromHex(ethereumAddress));
    return createAccountAuth != null;
  }

  Future<bool> authorizeAccountCreation() async {
    final ethereumAddress = await _configurationService.getEthereumAddress();
    final accountCreated = await getCreateAccountAuthorization(ethereumAddress);
    if (!accountCreated) {
      final ethereumPrivateKey = await _configurationService.getPrivateKey();
      final hermezPrivateKey =
          await _configurationService.getHermezPrivateKey();
      final hermezAddress = await _configurationService.getHermezAddress();
      final hermezWallet =
          HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
      final signature =
          await hermezWallet.signCreateAccountAuthorization(ethereumPrivateKey);
      return _hermezService.authorizeAccountCreation(
          web3.EthereumAddress.fromHex(ethereumAddress),
          hermezWallet.publicKeyBase64,
          signature);
    } else {
      return true;
    }
  }

  Future<LinkedHashMap<String, BigInt>> depositGasLimit(
      BigInt amount, Token token) async {
    //_store.dispatch(TransactionStarted());
    final hermezPrivateKey = await _configurationService.getHermezPrivateKey();
    final hermezAddress = await _configurationService.getHermezAddress();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    return _hermezService.depositGasLimit(
        amount, hermezAddress, token, hermezWallet.publicKeyCompressedHex);
  }

  Future<bool> deposit(BigInt amount, Token token,
      {BigInt approveGasLimit, BigInt depositGasLimit, int gasPrice}) async {
    _store.dispatch(TransactionStarted());
    final hermezPrivateKey = await _configurationService.getHermezPrivateKey();
    final hermezAddress = await _configurationService.getHermezAddress();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    return _hermezService.deposit(amount, hermezAddress, token,
        hermezWallet.publicKeyCompressedHex, state.ethereumPrivateKey,
        approveGasLimit: approveGasLimit,
        depositGasLimit: depositGasLimit,
        gasPrice: gasPrice);
  }

  Future<BigInt> withdrawGasLimit(double amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal) async {
    //_store.dispatch(TransactionStarted());

    final hermezPrivateKey = await _configurationService.getHermezPrivateKey();
    final hermezAddress = await _configurationService.getHermezAddress();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    return _hermezService.withdrawGasLimit(
        amount,
        account,
        exit,
        completeDelayedWithdrawal,
        instantWithdrawal,
        hermezAddress,
        hermezWallet.publicKeyCompressedHex);
  }

  Future<bool> withdraw(double amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal,
      {BigInt gasLimit, int gasPrice = 0}) async {
    _store.dispatch(TransactionStarted());

    final hermezPrivateKey = await _configurationService.getHermezPrivateKey();
    final hermezAddress = await _configurationService.getHermezAddress();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    final success = await _hermezService.withdraw(
        amount,
        account,
        exit,
        completeDelayedWithdrawal,
        instantWithdrawal,
        hermezAddress,
        hermezWallet.publicKeyCompressedHex,
        state.ethereumPrivateKey,
        gasLimit: gasLimit,
        gasPrice: gasPrice);

    return success;
  }

  Future<bool> isInstantWithdrawalAllowed(double amount, Token token) async {
    final success =
        await _hermezService.isInstantWithdrawalAllowed(amount, token);
    return success;
  }

  void transactionFinished() {
    _store.dispatch(TransactionFinished());
  }

  Future<BigInt> forceExitGasLimit(BigInt amount, Account account) async {
    //_store.dispatch(TransactionStarted());
    final hermezAddress = await _configurationService.getHermezAddress();
    return _hermezService.forceExitGasLimit(amount, hermezAddress, account);
  }

  Future<bool> forceExit(BigInt amount, Account account,
      {BigInt gasLimit, int gasPrice = 0}) async {
    _store.dispatch(TransactionStarted());
    final hermezAddress = await _configurationService.getHermezAddress();

    return _hermezService.forceExit(
        amount, hermezAddress, account, state.ethereumPrivateKey,
        gasLimit: gasLimit, gasPrice: gasPrice);
  }

  Future<bool> exit(double amount, Account account, double fee) async {
    _store.dispatch(TransactionStarted());

    final hermezPrivateKey = await _configurationService.getHermezPrivateKey();
    final hermezAddress = await _configurationService.getHermezAddress();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);

    final exitTx = {
      'from': account.accountIndex,
      'type': 'Exit',
      'amount': HermezCompressedAmount.compressAmount(amount),
      'fee': fee,
    };

    final success = await _hermezService.generateAndSendL2Tx(
        exitTx, hermezWallet, account.token);

    //_store.dispatch(TransactionFinished());

    return success;
  }

  Future<bool> transfer(
      double amount, Account from, Account to, double fee) async {
    _store.dispatch(TransactionStarted());

    final hermezPrivateKey = await _configurationService.getHermezPrivateKey();
    final hermezAddress = await _configurationService.getHermezAddress();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);

    final transferTx = {
      'from': from.accountIndex,
      'to': to.accountIndex != null ? to.accountIndex : to.hezEthereumAddress,
      //'toBjj': null,
      'amount': HermezCompressedAmount.compressAmount(amount),
      'fee': fee,
      //'nonce': from.nonce
    };

    final success = await _hermezService.generateAndSendL2Tx(
        transferTx, hermezWallet, from.token);

    //if (success) {
    //_store.dispatch(TransactionFinished());
    //}
    return success;
  }

  Future<List<PoolTransaction>> getPoolTransactions(
      [String accountIndex]) async {
    final hermezPrivateKey = await _configurationService.getHermezPrivateKey();
    final hermezAddress = await _configurationService.getHermezAddress();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    return await tx_pool.getPoolTransactions(
        accountIndex, hermezWallet.publicKeyCompressedHex);
  }

  Future<bool> sendL2Transaction(Transaction transaction) async {
    final result = await _hermezService.sendL2Transaction(
        transaction, await _configurationService.getBabyJubJubHex());
    return result;
  }

  /// Calculates the fee for the transaction.
  /// It takes the appropriate recomended fee in USD from the coordinator
  /// and converts it to token value.
  /// @param {Object} fees - The recommended Fee object returned by the Coordinator
  /// @param {Boolean} iExistingAccount - Whether it's a existingAccount transfer
  /// @returns {number} - Transaction fee
  double getFee(RecommendedFee fees, bool isExistingAccount, Token token,
      TransactionType transactionType) {
    if (token.USD == 0) {
      return 0;
    }

    final fee = (isExistingAccount ||
            transactionType == TransactionType.EXIT ||
            transactionType == TransactionType.FORCEEXIT)
        ? fees.existingAccount
        : fees.createAccount;

    return double.parse((fee / token.USD).toStringAsFixed(6));
  }

  Future<GasPriceResponse> getGasPrice() async {
    GasPriceResponse gasPrice = await _contractService.getGasPrice();
    return gasPrice;
  }

  Future<BigInt> getGasLimit(String from, String to, BigInt amount, Token token,
      {Uint8List data}) async {
    web3.EthereumAddress fromAddress;
    web3.EthereumAddress toAddress;
    if (from != null && from.isNotEmpty) {
      fromAddress = web3.EthereumAddress.fromHex(from);
    }
    if (to != null && to.isNotEmpty) {
      toAddress = web3.EthereumAddress.fromHex(to);
    }

    BigInt maxGas = await _contractService.getEstimatedGas(
        fromAddress, toAddress, amount, data, token);
    return maxGas;
  }

  Future<BigInt> getEstimatedGas(String from, String to, BigInt amount,
      Token token, WalletDefaultFee feeSpeed,
      {Uint8List data}) async {
    web3.EthereumAddress fromAddress;
    web3.EthereumAddress toAddress;
    if (from != null && from.isNotEmpty) {
      fromAddress = web3.EthereumAddress.fromHex(from);
    }
    if (to != null && to.isNotEmpty) {
      toAddress = web3.EthereumAddress.fromHex(to);
    }
    GasPriceResponse gasPriceResponse = await getGasPrice();
    BigInt maxGas = await _contractService.getEstimatedGas(
        fromAddress, toAddress, amount, data, token);

    BigInt gasPrice = BigInt.zero;
    switch (feeSpeed) {
      case WalletDefaultFee.SLOW:
        gasPrice = BigInt.from(gasPriceResponse.safeLow * pow(10, 8));
        break;
      case WalletDefaultFee.AVERAGE:
        gasPrice = BigInt.from(gasPriceResponse.average * pow(10, 8));
        break;
      case WalletDefaultFee.FAST:
        gasPrice = BigInt.from(gasPriceResponse.fast * pow(10, 8));
        break;
    }

    BigInt estimatedFee = gasPrice * maxGas;

    return estimatedFee;
  }

  Future<void> updateDefaultCurrency(
      WalletDefaultCurrency defaultCurrency) async {
    _configurationService.setDefaultCurrency(defaultCurrency);
    _store.dispatch(ExchangeRatioUpdated(_configurationService
        .getExchangeRatio(defaultCurrency.toString().split(".").last)));
    _store.dispatch(DefaultCurrencyUpdated(defaultCurrency));
  }

  Future<void> updateDefaultFee(WalletDefaultFee defaultFee) async {
    _configurationService.setDefaultFee(defaultFee);
    _store.dispatch(DefaultFeeUpdated(defaultFee));
  }

  void updateLevel(TransactionLevel txLevel) async {
    await _configurationService.setLevelSelected(txLevel);
    _store.dispatch(LevelUpdated(txLevel));
  }

  Future<List<dynamic>> getEthereumTransactionsByAddress(
      String address, Token token, int fromItem) async {
    if (token.symbol == "ETH") {
      return _explorerService.getTransactionsByAccountAddress(address);
    } else {
      List<dynamic> transactions =
          await _explorerService.getTokenTransferEventsByAccountAddress(
              address, token.ethereumAddress);
      return transactions;
    }
  }

  Future<ForgedTransactionsResponse> getHermezTransactionsByAddress(
      String address, Account account, int fromItem) async {
    ForgedTransactionsRequest request = ForgedTransactionsRequest(
        ethereumAddress: addresses.getHermezAddress(address),
        accountIndex: account.accountIndex,
        batchNum: account.token.ethereumBlockNum,
        tokenId: account.token.id,
        fromItem: fromItem);
    return _hermezService.getForgedTransactions(request);
  }

  Future<void> resetWallet() async {
    await _configurationService.setMnemonic("");
    await _configurationService.setPrivateKey("");
    await _configurationService.setHermezPrivateKey("");
    await _configurationService.setBabyJubJubHex("");
    await _configurationService.setBabyJubJubBase64("");
    await _configurationService.setEthereumAddress("");
    await _configurationService.setHermezAddress("");
    await _configurationService.setPasscode("");
    await _configurationService.setBiometricsFingerprint(false);
    await _configurationService.setBiometricsFace(false);
    await _configurationService.setDefaultCurrency(WalletDefaultCurrency.USD);
    await _configurationService.setDefaultFee(WalletDefaultFee.AVERAGE);
    await _configurationService.setLevelSelected(TransactionLevel.LEVEL1);
    await _configurationService.setupDone(false);
    await _configurationService.backupDone(false);
  }
}
