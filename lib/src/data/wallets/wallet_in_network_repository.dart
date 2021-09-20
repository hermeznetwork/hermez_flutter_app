import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/src/data/accounts/account_in_network_repository.dart';
import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/data/network/explorer_service.dart';
import 'package:hermez/src/data/network/hermez_service.dart';
import 'package:hermez/src/data/network/price_updater_service.dart';
import 'package:hermez/src/data/transactions/transaction_in_network_repository.dart';
import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez/src/domain/wallets/wallet_repository.dart';
import 'package:hermez_sdk/model/account.dart' as hezAccount;
import 'package:hermez_sdk/model/token.dart';

class WalletInNetworkRepository implements WalletRepository {
  final ExplorerService _explorerService;
  final IHermezService _hermezService;
  final PriceUpdaterService _priceUpdaterService;
  final IConfigurationService _configurationService;
  final AccountInNetworkRepository _accountInNetworkRepository;
  final TransactionInNetworkRepository _transactionInNetworkRepository;
  WalletInNetworkRepository(
      this._explorerService,
      this._hermezService,
      this._priceUpdaterService,
      this._configurationService,
      this._accountInNetworkRepository,
      this._transactionInNetworkRepository);

  @override
  Future<List<Wallet>> getWallets() async {
    List<Wallet> wallets = [];
    List<Account> l2Accounts = [];
    List<Account> l1Accounts = [];
    List<Token> tokens = await _hermezService.getTokens();
    List<PriceToken> priceTokens = await _priceUpdaterService.getTokensPrices();
    String ethereumAddress = await _configurationService.getEthereumAddress();
    String hermezAddress = await _configurationService.getHermezAddress();
    if (_accountInNetworkRepository != null) {
      List<hezAccount.Account> l2HezAccounts =
          await _accountInNetworkRepository.getL2Accounts(hermezAddress, []);
      List<hezAccount.Account> l1HezAccounts =
          await _accountInNetworkRepository.getL1Accounts(ethereumAddress);

      l2HezAccounts.map((l2Account) async {
        Token token =
            tokens.firstWhere((token) => token.id == l2Account.tokenId);
        PriceToken priceToken = priceTokens
            .firstWhere((priceToken) => priceToken.id == l2Account.tokenId);
        /* ForgedTransactionsRequest transactionsRequest =
          ForgedTransactionsRequest();
      ForgedTransactionsResponse transactionsResponse =
          await _transactionInNetworkRepository
              .getForgedTransactions(transactionsRequest);*/
        l2Accounts.add(Account(
            l2Account: true,
            address: l2Account.hezEthereumAddress,
            bjj: l2Account.bjj,
            accountIndex: l2Account.accountIndex,
            balance: l2Account.balance,
            //transactions: transactionsResponse.transactions,
            token: token,
            price: priceToken));
      });

      l1HezAccounts.map((l1Account) async {
        Token token =
            tokens.firstWhere((token) => token.id == l1Account.tokenId);
        PriceToken priceToken = priceTokens
            .firstWhere((priceToken) => priceToken.id == l1Account.tokenId);
        /*List<dynamic> transactions = await _transactionInNetworkRepository
          .getEthereumTransactionsByAddress(
              ethereumAddress, token.id == 0 ? "" : token.ethereumAddress);*/
        l1Accounts.add(Account(
            l2Account: false,
            address: l1Account.hezEthereumAddress,
            token: token,
            balance: l1Account.balance,
            //transactions: transactions,
            price: priceToken));
      });
    }

    /*List<Token> tokens = await getTokens(needRefresh: true);
    List<PriceToken> priceTokens = await getPriceTokens(needRefresh: true);
    List<Account> l1Accounts = await getL1Accounts(true);
    List<Account> l2Accounts = await getL2Accounts();


    List<Exit> exits = await getExits();
    List<PoolTransaction> pendingL2Txs = await getPoolTransactions();
    List<dynamic> pendingL1Transfers = await getPendingTransfers();
    List<dynamic> pendingDeposits = await getPendingDeposits();
    List<dynamic> pendingWithdraws = await getPendingWithdraws();
    List<dynamic> pendingForceExits = await getPendingForceExits();*/
    wallets.add(Wallet(
        l1Address: ethereumAddress,
        l2Address: hermezAddress,
        l1Accounts: l1Accounts,
        l2Accounts: l2Accounts));
    return wallets;
  }

  @override
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
