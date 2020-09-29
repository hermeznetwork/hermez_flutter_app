import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/service/address_service.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/service/contract_service.dart';
import 'package:hermez/service/hermez_service.dart';
import 'package:hermez/service/network/model/L1_account.dart';
import 'package:hermez/service/network/model/token.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:web3dart/web3dart.dart' as web3;

import 'wallet_state.dart';

class WalletHandler {
  WalletHandler(this._store, this._addressService, this._contractService,
      this._configurationService, this._hermezService);

  final Store<Wallet, WalletAction> _store;
  final AddressService _addressService;
  final ConfigurationService _configurationService;
  final ContractService _contractService;
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

  Future<void> fetchOwnBalance() async {
    final supportedTokens = await _hermezService.getTokens();
    _store.dispatch(UpdatingBalance());

    List<L1Account> L1accounts = List();

    // GET L1 ETH Balance
    web3.EtherAmount ethBalance = await _contractService
        .getEthBalance(web3.EthereumAddress.fromHex(state.address));

    if (ethBalance.getInWei > BigInt.zero) {
      final account = L1Account(
          accountIndex: 0,
          tokenId: 0,
          tokenSymbol: "ETH",
          nonce: 0,
          balance: ethBalance.getInEther.toString(),
          publicKey: "Ethereum",
          ethereumAddress: state.address,
          USD: 346.67);
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
        var tokenAmount =
            web3.EtherAmount.fromUnitAndValue(web3.EtherUnit.wei, tokenBalance);
        final account = L1Account(
            accountIndex: 0,
            tokenId: token.id,
            tokenSymbol: token.symbol,
            nonce: 0,
            balance: tokenAmount.getInEther.toString(),
            publicKey: token.name,
            ethereumAddress: state.address,
            USD: token.USD);
        L1accounts.add(account);
      }
      tokensBalance[token.symbol] = tokenBalance;
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
        BalanceUpdated(ethBalance.getInEther, tokensBalance, L1accounts));
  }

  Future<List<Token>> getTokens() async {
    final supportedTokens = await _hermezService.getTokens();
    return supportedTokens;
  }

  Future<Token> getTokenById(int tokenId) async {
    final supportedToken = await _hermezService.getTokenById(tokenId);
    return supportedToken;
  }

  void updateDefaultCurrency(WalletDefaultCurrency defaultCurrency) {
    _configurationService.setDefaultCurrency(defaultCurrency);
    _store.dispatch(DefaultCurrencyUpdated(defaultCurrency));
  }

  void updateLevel(TransactionLevel txLevel) {
    _configurationService.setLevelSelected(txLevel);
    _store.dispatch(LevelUpdated(txLevel));
  }

  //this means that the function will be executed sometime in the future (in this case does not return data)
  /*Future<void> getCryptoPrices() async {
    //async to use await, which suspends the current function, while it does other stuff and resumes when data ready
    print('getting crypto prices'); //print
    // TEST ENVIRONMENT
    Map<String, String> headers = {
      'X-CMC_PRO_API_KEY': '87529169-9e17-4393-939e-39c4737dbd80',
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
    };
    String _apiURL =
        "https://sandbox-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?start=1&limit=100&convert=USD";

    String symbols = "ETH,USDT,BNB,LINK,LEO,USDC,HT,VEST,COMP,MKR,HEDG,BAT,INO,CRO,ZRX,OKB,KNC,SNX,LEND";//,HT,VEST,COMP,MKR,HEDG,cUSDC,BAT,INO,CRO,ZRX,OKB,KNC,SNX,LEND";
    String _apiURL2 =
        "https://sandbox-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=$symbols&convert=USD";


    // PRO ENVIRONMENT
    /*Map<String, String> headers = {
      'X-CMC_PRO_API_KEY': '339c75a5-5761-4528-924e-6b5d941a8489',
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
    };
    String _apiURL =
        "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?start=1&limit=5000&convert=USD";*/
    setState(() {
      this._loading = true; //before calling the api, set the loading to true
    });


    http.Response response = await http.get(_apiURL2, headers: headers); //waits for response
    setState(() {
      String body = response.body;
      Map result = jsonDecode(body);
      this.cryptoList =
          result["data"].values.toList(); //sets the state of our widget
      this._loading = false; //set the loading to false after we get a response
      print(cryptoList); //prints the list
    });
    return;
  }*/

  Future<void> resetWallet() async {
    await _configurationService.setMnemonic("");
    await _configurationService.setDefaultCurrency(WalletDefaultCurrency.EUR);
    await _configurationService.setupDone(false);
  }
}
