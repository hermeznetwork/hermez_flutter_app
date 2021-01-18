import 'dart:math';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/service/address_service.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/service/contract_service.dart';
import 'package:hermez/service/explorer_service.dart';
import 'package:hermez/service/hermez_service.dart';
import 'package:hermez/service/network/model/account.dart';
import 'package:hermez/service/network/model/token.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
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
    final address = await _addressService.getPublicAddress(privateKey);

    _store.dispatch(InitialiseWallet(address.toString(), privateKey));

    await _initialise();
  }

  Future<void> _initialiseFromPrivateKey(String privateKey) async {
    final address = await _addressService.getPublicAddress(privateKey);

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
    if (state != null && state.address != null) {
      final supportedTokens = await _hermezService.getTokens();
      _store.dispatch(UpdatingBalance());

      List<Account> L1accounts = List();

      // GET L1 ETH Balance
      web3.EtherAmount ethBalance = await _contractService
          .getEthBalance(web3.EthereumAddress.fromHex(state.address));

      if (ethBalance.getInWei > BigInt.zero) {
        final account = Account(
          accountIndex: "0",
          balance: ethBalance.getInWei.toString(),
          bjj: "",
          hezEthereumAddress: state.address,
          itemId: 0,
          nonce: 0,
          token: Token(
              USD: 346,
              decimals: 18,
              ethereumAddress: "0x0000000000000000000000000000000000000000",
              ethereumBlockNum: 0,
              fiatUpdate: "2020-11-26T09:53:47.444444Z",
              id: 0,
              itemId: 1,
              name: "Ether",
              symbol: "ETH"),
        );
        L1accounts.add(account);
      }

      Map<String, BigInt> tokensBalance = Map();

      for (Token token in supportedTokens) {
        // if tokenId == 0 -> ETH
        final contractAddress =
            "0x5060b60cb8bd1c94b7adef4134555cda7b45c461"; // TGE Contract Address
        var tokenBalance = await _contractService.getTokenBalance(
            web3.EthereumAddress.fromHex(state.address),
            web3.EthereumAddress.fromHex(contractAddress
                /*token.ethereumAddress*/),
            token.name);
        if (tokenBalance > BigInt.zero) {
          var tokenAmount = web3.EtherAmount.fromUnitAndValue(
              web3.EtherUnit.wei, tokenBalance);
          final account = Account(
              accountIndex: "0",
              balance: tokenAmount.getInWei.toString(),
              bjj: "",
              hezEthereumAddress: state.address,
              itemId: 0,
              nonce: 0,
              token: token);
          L1accounts.add(account);
        }
        tokensBalance[token.symbol] = tokenBalance;
      }

      _store.dispatch(
          BalanceUpdated(ethBalance.getInWei, tokensBalance, L1accounts));
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
  }

  Future<void> fetchOwnL2Balance() async {
    final accounts = await _hermezService
        .getAccounts(web3.EthereumAddress.fromHex(state.address));
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
    if (state != null && state.address != null) {
      final supportedTokens = await _hermezService.getTokens();

      //_store.dispatch(UpdatingBalance());

      // GET L1 ETH Balance
      web3.EtherAmount ethBalance = await _contractService
          .getEthBalance(web3.EthereumAddress.fromHex(state.address));

      if (ethBalance.getInWei > BigInt.zero) {
        final account = Account(
          accountIndex: "0",
          balance: ethBalance.getInWei.toString(),
          bjj: "",
          hezEthereumAddress: state.address,
          itemId: 0,
          nonce: 0,
          token: Token(
              USD: 346,
              decimals: 18,
              ethereumAddress: "0x0000000000000000000000000000000000000000",
              ethereumBlockNum: 0,
              fiatUpdate: "2020-11-26T09:53:47.444444Z",
              id: 0,
              itemId: 1,
              name: "Ether",
              symbol: "ETH"),
        );
        accounts.add(account);
      }

      Map<String, BigInt> tokensBalance = Map();

      for (Token token in supportedTokens) {
        // if tokenId == 0 -> ETH
        final contractAddress =
            "0x5060b60cb8bd1c94b7adef4134555cda7b45c461"; // TGE Contract Address
        var tokenBalance = await _contractService.getTokenBalance(
            web3.EthereumAddress.fromHex(state.address),
            web3.EthereumAddress.fromHex(contractAddress
                /*token.ethereumAddress*/),
            token.name);
        if (tokenBalance > BigInt.zero) {
          var tokenAmount = web3.EtherAmount.fromUnitAndValue(
              web3.EtherUnit.wei, tokenBalance);
          final account = Account(
              accountIndex: "0",
              balance: tokenAmount.getInWei.toString(),
              bjj: "",
              hezEthereumAddress: state.address,
              itemId: 0,
              nonce: 0,
              token: token);
          accounts.add(account);
        }
        tokensBalance[token.symbol] = tokenBalance;
      }

      /*_store.dispatch(
          BalanceUpdated(ethBalance.getInWei, tokensBalance, accounts));*/
    }
    return accounts;
  }

  Future<List<Account>> getAccounts() async {
    final accounts = await _hermezService
        .getAccounts(web3.EthereumAddress.fromHex(state.address));
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
    await _configurationService.setEthereumAddress("");
    await _configurationService.setDefaultCurrency(WalletDefaultCurrency.EUR);
    await _configurationService.setLevelSelected(TransactionLevel.LEVEL1);
    await _configurationService.setupDone(false);
  }
}
