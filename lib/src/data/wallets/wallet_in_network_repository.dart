import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/data/network/explorer_service.dart';
import 'package:hermez/src/data/network/hermez_service.dart';
import 'package:hermez/src/data/network/price_updater_service.dart';
import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/accounts/account_repository.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/tokens/token.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez/src/domain/wallets/wallet_repository.dart';
import 'package:hermez_sdk/model/account.dart' as hezAccount;
import 'package:hermez_sdk/model/token.dart' as hezToken;

class WalletInNetworkRepository implements WalletRepository {
  final ExplorerService _explorerService;
  final IHermezService _hermezService;
  final PriceUpdaterService _priceUpdaterService;
  final IConfigurationService _configurationService;
  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;
  WalletInNetworkRepository(
      this._explorerService,
      this._hermezService,
      this._priceUpdaterService,
      this._configurationService,
      this._accountRepository,
      this._transactionRepository);

  @override
  Future<List<Wallet>> getWallets() async {
    List<Wallet> wallets = [];
    List<Account> l2Accounts = [];
    List<Account> l1Accounts = [];
    List<hezToken.Token> tokens = await _hermezService.getTokens();
    List<PriceToken> priceTokens = await _priceUpdaterService.getTokensPrices();
    String ethereumAddress = await _configurationService.getEthereumAddress();
    String hermezAddress = await _configurationService.getHermezAddress();
    bool isBackedUp = _configurationService.didBackupWallet();
    if (_accountRepository != null) {
      List<hezAccount.Account> l2HezAccounts =
          await _accountRepository.getL2Accounts(hermezAddress, []);
      List<hezAccount.Account> l1HezAccounts =
          await _accountRepository.getL1Accounts(ethereumAddress);

      for (hezAccount.Account l2Account in l2HezAccounts) {
        hezToken.Token hermezToken =
            tokens.firstWhere((token) => token.id == l2Account.tokenId);
        PriceToken priceToken = priceTokens
            .firstWhere((priceToken) => priceToken.id == l2Account.tokenId);
        Token token = Token(token: hermezToken, price: priceToken);
        List<dynamic> transactions = await _transactionRepository
            .getTransactions(
                l2Account.hezEthereumAddress, l2Account.accountIndex,
                layerFilter: LayerFilter.L2,
                transactionStatusFilter: TransactionStatusFilter.ALL,
                transactionTypeFilter: TransactionTypeFilter.ALL,
                tokenIds: [hermezToken.id]);
        l2Accounts.add(Account(
            l2Account: true,
            address: l2Account.hezEthereumAddress,
            bjj: l2Account.bjj,
            accountIndex: l2Account.accountIndex,
            balance: double.tryParse(l2Account.balance),
            transactions: transactions,
            token: token));
      }

      /*l2HezAccounts.map((l2Account) async {
        hezToken.Token hermezToken =
            tokens.firstWhere((token) => token.id == l2Account.tokenId);
        PriceToken priceToken = priceTokens
            .firstWhere((priceToken) => priceToken.id == l2Account.tokenId);
        Token token = Token(token: hermezToken, price: priceToken);
        List<dynamic> transactions = await _transactionRepository
            .getTransactions(
                l2Account.hezEthereumAddress,
                l2Account.accountIndex,
                LayerFilter.L2,
                TransactionStatusFilter.ALL,
                TransactionTypeFilter.ALL,
                [hermezToken.id]);
        l2Accounts.add(Account(
            l2Account: true,
            address: l2Account.hezEthereumAddress,
            bjj: l2Account.bjj,
            accountIndex: l2Account.accountIndex,
            balance: l2Account.balance,
            transactions: transactions,
            token: token));
      });*/

      for (hezAccount.Account l1Account in l1HezAccounts) {
        hezToken.Token hermezToken =
            tokens.firstWhere((token) => token.id == l1Account.tokenId);
        PriceToken priceToken = priceTokens
            .firstWhere((priceToken) => priceToken.id == l1Account.tokenId);
        Token token = Token(token: hermezToken, price: priceToken);
        List<dynamic> transactions = await _transactionRepository
            .getTransactions(l1Account.hezEthereumAddress, "",
                layerFilter: LayerFilter.L1,
                transactionStatusFilter: TransactionStatusFilter.ALL,
                transactionTypeFilter: TransactionTypeFilter.ALL,
                tokenIds: [hermezToken.id]);
        /*List<dynamic> transactions = await _transactionInNetworkRepository
          .getEthereumTransactionsByAddress(
              ethereumAddress, token.id == 0 ? "" : token.ethereumAddress);*/
        l1Accounts.add(Account(
          l2Account: false,
          address: l1Account.hezEthereumAddress,
          token: token,
          balance: double.tryParse(l1Account.balance),
          transactions: transactions,
        ));
      }

      /*l1HezAccounts.map((l1Account) async {
        hezToken.Token hermezToken =
            tokens.firstWhere((token) => token.id == l1Account.tokenId);
        PriceToken priceToken = priceTokens
            .firstWhere((priceToken) => priceToken.id == l1Account.tokenId);
        Token token = Token(token: hermezToken, price: priceToken);
        List<dynamic> transactions = await _transactionRepository
            .getTransactions(
                l1Account.hezEthereumAddress,
                "",
                LayerFilter.L1,
                TransactionStatusFilter.ALL,
                TransactionTypeFilter.ALL,
                [hermezToken.id]);
        /*List<dynamic> transactions = await _transactionInNetworkRepository
          .getEthereumTransactionsByAddress(
              ethereumAddress, token.id == 0 ? "" : token.ethereumAddress);*/
        l1Accounts.add(Account(
          l2Account: false,
          address: l1Account.hezEthereumAddress,
          token: token,
          balance: l1Account.balance,
          transactions: transactions,
        ));
      });*/
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
    if (ethereumAddress != null && hermezAddress != null) {
      wallets.add(Wallet(
          l1Address: ethereumAddress,
          l2Address: hermezAddress,
          l1Accounts: l1Accounts,
          l2Accounts: l2Accounts,
          isBackedUp: isBackedUp));
    }
    return wallets;
  }
}
