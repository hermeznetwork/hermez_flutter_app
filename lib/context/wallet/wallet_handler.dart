import 'dart:math';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/service/address_service.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/service/contract_service.dart';
import 'package:hermez/service/explorer_service.dart';
import 'package:hermez/service/hermez_service.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:hermez_plugin/environment.dart';
import 'package:hermez_plugin/hermez_wallet.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/exit.dart';
import 'package:hermez_plugin/model/recommended_fee.dart';
import 'package:hermez_plugin/model/token.dart';
import 'package:hermez_plugin/model/transaction.dart';
import 'package:hermez_plugin/tx_utils.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3;

import 'wallet_state.dart';

class WalletHandler {
  WalletHandler(this._store, this._addressService, this._contractService,
      this._explorerService, this._configurationService, this._hermezService);

  final Store<Wallet, WalletAction> _store;
  final AddressService _addressService;
  final ConfigurationService _configurationService;
  final ContractService _contractService;
  final ExplorerService _explorerService;
  final HermezService _hermezService;

  Wallet get state => _store.state;

  Future<void> initialise() async {
    final entropyMnemonic = await _configurationService.getMnemonic();

    if (entropyMnemonic != null && entropyMnemonic.isNotEmpty) {
      _initialiseFromMnemonic(entropyMnemonic);
      return;
    }

    final privateKey = await _configurationService.getPrivateKey();
    _initialiseFromPrivateKey(privateKey);
  }

  Future<void> initialiseReadOnly() async {
    final entropyMnemonic = await _configurationService.getMnemonic();
    final privateKey = await _configurationService.getPrivateKey();
    final ethereumAddress = await _configurationService.getEthereumAddress();

    if (privateKey != null &&
        privateKey.isNotEmpty &&
        ethereumAddress != null &&
        ethereumAddress.isNotEmpty) {
      _initialiseFromStoredData(privateKey, ethereumAddress);
      return;
    }

    if (entropyMnemonic != null && entropyMnemonic.isNotEmpty) {
      _initialiseFromMnemonic(entropyMnemonic);
      return;
    }

    _initialiseFromPrivateKey(privateKey);
  }

  Future<void> _initialiseFromMnemonic(String entropyMnemonic) async {
    final mnemonic = _addressService.entropyToMnemonic(entropyMnemonic);
    final privateKey = _addressService.getPrivateKey(mnemonic);
    final address = await _addressService.getEthereumAddress(privateKey);

    _store.dispatch(InitialiseWallet(address.toString(), privateKey));

    await _initialise();
  }

  Future<void> _initialiseFromPrivateKey(String privateKey) async {
    final address = await _addressService.getEthereumAddress(privateKey);

    _store.dispatch(InitialiseWallet(address.toString(), privateKey));

    await _initialise();
  }

  Future<void> _initialiseFromStoredData(
      String privateKey, String ethereumAddress) async {
    _store.dispatch(InitialiseWallet(ethereumAddress, privateKey));

    await _initialise();
  }

  Future<void> _initialise() async {
    final levelSelected = await _configurationService.getLevelSelected();
    _store.dispatch(LevelUpdated(levelSelected));

    final defaultCurrency = await _configurationService.getDefaultCurrency();
    _store.dispatch(DefaultCurrencyUpdated(defaultCurrency));

    //final state = await _hermezService.getState();

    final exchangeRatio = await _hermezService.getEURUSDExchangeRatio();
    _configurationService.setExchangeRatio(exchangeRatio);
    _store.dispatch(ExchangeRatioUpdated(exchangeRatio));
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

  Future<void> fetchOwnL1Balance() async {
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
  }

  Future<List<Account>> getL1Accounts() async {
    List<Account> accounts = List();
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
            //tokensBalance[token.symbol] = tokenBalance;
          }
        }
      }

      // _store.dispatch(
      //     BalanceUpdated(ethBalance.getInWei, tokensBalance, accounts));
    }
    return accounts;
  }

  Future<List<Account>> getAccounts() async {
    final accounts = await _hermezService.getAccounts(
        web3.EthereumAddress.fromHex(state.ethereumAddress), [3, 87, 91]);
    return accounts;
  }

  Future<List<Token>> getTokens() async {
    final supportedTokens = await _hermezService.getTokens();
    return supportedTokens;
  }

  Future<Token> getTokenById(int tokenId) async {
    final supportedToken = await _hermezService.getTokenById(tokenId);
    return supportedToken;
  }

  Future<List<Exit>> getExits() async {
    final exits = await _hermezService
        .getExits(web3.EthereumAddress.fromHex(state.ethereumAddress));
    return exits;
  }

  /// Fetches the details of an exit
  /// @param {string} accountIndex - account index
  /// @param {number} batchNum - batch number
  /// @returns {void}
  Future<Exit> getExit(String accountIndex, int batchNum) {
    _hermezService.getAccount(accountIndex);
    _hermezService.getExit(batchNum, accountIndex);
  }

  /// Fetches the recommended fees from the Coordinator
  /// @returns {RecommendedFee}
  Future<RecommendedFee> fetchFees() {
    return _hermezService.getRecommendedFee();
  }

  Future<bool> authorizeAccountCreation() async {
    final ethereumPrivateKey = await _configurationService.getPrivateKey();
    final ethereumAddress = await _configurationService.getEthereumAddress();
    final hermezPrivateKey = await _configurationService.getHermezPrivateKey();
    final hermezAddress = await _configurationService.getHermezAddress();
    final chainId = getCurrentEnvironment().chainId;
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    final createAccountAuth =
        await _hermezService.getCreateAccountAuthorization(
            web3.EthereumAddress.fromHex(ethereumAddress));
    if (createAccountAuth == null) {
      final signature = await hermezWallet.signCreateAccountAuthorization(
          BigInt.from(chainId).toRadixString(16), ethereumPrivateKey);
      return _hermezService.authorizeAccountCreation(
          web3.EthereumAddress.fromHex(ethereumAddress),
          hermezWallet.publicKeyBase64,
          signature);
    }
  }

  Future<bool> deposit(BigInt amount, Account account) {
    return _hermezService.deposit(amount, state.ethereumAddress, account.token,
        state.hermezPublicKeyHex, state.ethereumPrivateKey);
  }

  Future<void> withdraw(BigInt amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal) async {
    await getExit(account.accountIndex, null /*batchNum*/);
    return _hermezService.withdraw(
        amount, account, exit, completeDelayedWithdrawal, instantWithdrawal);
  }

  Future<void> forceExit(BigInt amount, Account account) {
    _hermezService.forceExit(amount, account);
  }

  Future<void> exit(BigInt amount, Account account, BigInt fee) {
    Transaction transaction = Transaction(
        type: TxType.Exit.toString(),
        fromAccountIndex: account.accountIndex,
        amount: amount.toInt(),
        fee: fee.toInt(),
        nonce: account.nonce);
    _hermezService.generateAndSendL2Tx(
        transaction, state.hermezWallet, account.token);
  }

  Future<void> transfer(BigInt amount, Account from, Account to, fee) {
    Transaction transaction = Transaction(
        type: TxType.Transfer.toString(),
        fromAccountIndex: from.accountIndex,
        toAccountIndex:
            to.accountIndex != null ? to.accountIndex : to.hezEthereumAddress,
        amount: amount.toInt(),
        fee: fee.toInt(),
        nonce: from.nonce);
    _hermezService.generateAndSendL2Tx(
        transaction, state.hermezWallet, from.token);
  }

  Future<bool> sendL2Transaction(Transaction transaction) async {
    final result = await _hermezService.sendL2Transaction(
        transaction, await _configurationService.getBabyJubJubHex());
    return result;
  }

  Future<BigInt> getEstimatedFee(String from, String to, BigInt amount) async {
    web3.EthereumAddress fromAddress;
    web3.EthereumAddress toAddress;
    web3.EtherAmount gasPrice = await _contractService.getGasPrice();
    if (from != null && from.isNotEmpty) {
      fromAddress = web3.EthereumAddress.fromHex(from);
    }
    if (to != null && to.isNotEmpty) {
      toAddress = web3.EthereumAddress.fromHex(to);
    }
    BigInt estimatedGas = await _contractService.getEstimatedGas(
      fromAddress,
      toAddress,
      web3.EtherAmount.fromUnitAndValue(
        web3.EtherUnit.wei,
        BigInt.from(
          amount.toDouble() * pow(10, 18),
        ),
      ),
    );

    BigInt estimatedFee = gasPrice.getInWei * estimatedGas;

    return estimatedFee;
  }

  void updateDefaultCurrency(WalletDefaultCurrency defaultCurrency) {
    _configurationService.setDefaultCurrency(defaultCurrency);
    _store.dispatch(DefaultCurrencyUpdated(defaultCurrency));
  }

  void updateLevel(TransactionLevel txLevel) {
    _configurationService.setLevelSelected(txLevel);
    _store.dispatch(LevelUpdated(txLevel));
  }

  Future<List<dynamic>> getTransferEventsByAddress(String address) {
    return _explorerService.getTransferEventsByAccountAddress(address);
  }

  Future<List<dynamic>> getTransactionsByAddress(String address) {
    return _explorerService.getTransactionsByAccountAddress(address);
  }

  Future<void> resetWallet() async {
    await _configurationService.setMnemonic("");
    await _configurationService.setPrivateKey("");
    await _configurationService.setHermezPrivateKey("");
    await _configurationService.setBabyJubJubHex("");
    await _configurationService.setBabyJubJubBase64("");
    await _configurationService.setEthereumAddress("");
    await _configurationService.setHermezAddress("");
    await _configurationService.setDefaultCurrency(WalletDefaultCurrency.EUR);
    await _configurationService.setLevelSelected(TransactionLevel.LEVEL1);
    await _configurationService.setupDone(false);
  }
}
