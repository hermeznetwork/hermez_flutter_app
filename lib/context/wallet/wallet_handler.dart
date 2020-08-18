import 'package:hermezwallet/model/wallet.dart';
import 'package:hermezwallet/service/address_service.dart';
import 'package:hermezwallet/service/configuration_service.dart';
import 'package:hermezwallet/service/contract_service.dart';
import 'package:hermezwallet/service/rollup_service.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'wallet_state.dart';

class WalletHandler {
  WalletHandler(
    this._store,
    this._addressService,
    this._contractService,
    this._configurationService,
    this._rollupService
  );

  final Store<Wallet, WalletAction> _store;
  final AddressService _addressService;
  final ConfigurationService _configurationService;
  final ContractService _contractService;
  final RollupService _rollupService;

  Wallet get state => _store.state;

  Future<void> initialise() async {
    final entropyMnemonic = await _configurationService.getMnemonic();
    final privateKey = await _configurationService.getPrivateKey();

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
    final defaultCurrency = await _configurationService.getDefaultCurrency();

    _store.dispatch(InitialiseWallet(address.toString(), privateKey, defaultCurrency));

    await _initialise();
  }

  Future<void> _initialiseFromPrivateKey(String privateKey) async {
    final address = await _addressService.getPublicAddress(privateKey);
    final defaultCurrency = await _configurationService.getDefaultCurrency();

    _store.dispatch(InitialiseWallet(address.toString(), privateKey, defaultCurrency));

    await _initialise();
  }

  Future<void> _initialise() async {
    await this.fetchOwnBalance();

    _contractService.listenTransfer((from, to, value) async {
      var fromMe = from.toString() == state.address;
      var toMe = to.toString() == state.address;

      if (!fromMe && !toMe) {
        return;
      }

      print('======= balance updated =======');

      await fetchOwnBalance();
    });
  }

  Future<void> fetchOwnBalance() async {
    _store.dispatch(UpdatingBalance());



    var tokenBalance = await _contractService
        .getTokenBalance(web3.EthereumAddress.fromHex(state.address));

    var ethBalance = await _contractService
        .getEthBalance(web3.EthereumAddress.fromHex(state.address));

    var accounts = await _rollupService
        .getAccounts(web3.EthereumAddress.fromHex(state.address));

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
    final cryptoList = List();

    _store.dispatch(BalanceUpdated(ethBalance.getInWei, tokenBalance, cryptoList));
  }

  void updateDefaultCurrency(WalletDefaultCurrency defaultCurrency) {
    _configurationService.setDefaultCurrency(defaultCurrency);
    _store.dispatch(DefaultCurrencyUpdated(defaultCurrency));
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
    await _configurationService.setMnemonic(null);
    await _configurationService.setDefaultCurrency(WalletDefaultCurrency.EUR);
    await _configurationService.setupDone(false);
  }
}
