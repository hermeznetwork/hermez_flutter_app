import 'package:hermez/src/data/network/contract_service.dart';
import 'package:hermez/src/data/network/hermez_service.dart';
import 'package:hermez/src/data/transactions/transaction_in_network_repository.dart';
import 'package:hermez/src/domain/accounts/account_repository.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez_sdk/api.dart' as api;
import 'package:hermez_sdk/constants.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:web3dart/web3dart.dart' as web3;

class AccountInNetworkRepository implements AccountRepository {
  final ContractService _contractService;
  final HermezService _hermezService;
  final TransactionInNetworkRepository _transactionInNetworkRepository;

  AccountInNetworkRepository(this._contractService, this._hermezService,
      this._transactionInNetworkRepository);

  @override
  Future<List<Account>> getL2Accounts(String hezAddress, List<int> tokenIds,
      {int fromItem = 0,
      api.PaginationOrder order = api.PaginationOrder.ASC,
      int limit = DEFAULT_PAGE_SIZE}) async {
    final accountsResponse = await api.getAccounts(hezAddress, tokenIds,
        fromItem: fromItem, order: order, limit: limit);
    return accountsResponse.accounts;
  }

  @override
  Future<Account> getL2AccountByAddress(String hezAddress) async {
    // TODO: implement
    //final response = await api.getAccount(accountIndex);
    //return response;
  }

  @override
  Future<Account> getL2AccountByAccountIndex(String accountIndex) async {
    final response = await api.getAccount(accountIndex);
    return response;
  }

  Future<List<Account>> getL1Accounts(String ethereumAddress,
      {bool showZeroBalanceAccounts, List<int> tokenIds}) async {
    List<Account> accounts = [];
    if (ethereumAddress != null) {
      final supportedTokens =
          await _hermezService.getTokens(tokenIds: tokenIds);

      for (Token token in supportedTokens) {
        if (token.id == 0) {
          // GET L1 ETH Balance
          web3.EtherAmount ethBalance = await _contractService
              .getEthBalance(web3.EthereumAddress.fromHex(ethereumAddress));
          if (ethBalance.getInWei > BigInt.zero) {
            final account = Account(
                accountIndex: token.id.toString(),
                balance: ethBalance.getInWei.toString(),
                bjj: "",
                hezEthereumAddress: ethereumAddress,
                itemId: 0,
                nonce: 0,
                tokenId: token.id);
            accounts.add(account);
          } else {
            List<dynamic> transactions =
                await _transactionInNetworkRepository.getTransactions(
                    layerFilter: LayerFilter.L1,
                    address: ethereumAddress,
                    tokenId: token.id);
            if (transactions != null && transactions.isNotEmpty) {
              final account = Account(
                  accountIndex: token.id.toString(),
                  balance: ethBalance.getInWei.toString(),
                  bjj: "",
                  hezEthereumAddress: ethereumAddress,
                  itemId: 0,
                  nonce: 0,
                  tokenId: token.id);
              accounts.add(account);
            }
          }
        } else {
          var tokenBalance = BigInt.zero;
          try {
            tokenBalance = await _contractService.getTokenBalance(
                web3.EthereumAddress.fromHex(ethereumAddress),
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
                hezEthereumAddress: ethereumAddress,
                itemId: 0,
                nonce: 0,
                tokenId: token.id);
            accounts.add(account);
          } else {
            if (showZeroBalanceAccounts) {
              List<dynamic> transactions =
                  await _transactionInNetworkRepository.getTransactions(
                      layerFilter: LayerFilter.L1,
                      address: ethereumAddress,
                      tokenId: token.id);
              if (transactions != null && transactions.isNotEmpty) {
                final account = Account(
                    accountIndex: token.id.toString(),
                    balance: tokenAmount.getInWei.toString(),
                    bjj: "",
                    hezEthereumAddress: ethereumAddress,
                    itemId: 0,
                    nonce: 0,
                    tokenId: token.id);
                accounts.add(account);
              }
            }
          }
        }
      }
    }
    return accounts;
  }

  Future<Account> getL1Account(String ethereumAddress, int tokenId) async {
    final supportedTokens = await _hermezService.getTokens();
    Token token = supportedTokens.firstWhere(
        (supportedToken) => supportedToken.id == tokenId,
        orElse: () => null);
    if (token != null) {
      if (tokenId == 0) {
        // GET L1 ETH Balance
        web3.EtherAmount ethBalance = await _contractService
            .getEthBalance(web3.EthereumAddress.fromHex(ethereumAddress));
        final account = Account(
            accountIndex: tokenId.toString(),
            balance: ethBalance.getInWei.toString(),
            bjj: "",
            hezEthereumAddress: ethereumAddress,
            itemId: 0,
            nonce: 0,
            tokenId: tokenId);
        return account;
      } else {
        var tokenBalance = BigInt.zero;
        try {
          tokenBalance = await _contractService.getTokenBalance(
              web3.EthereumAddress.fromHex(ethereumAddress),
              web3.EthereumAddress.fromHex(token.ethereumAddress),
              token.name);
        } catch (error) {
          throw error;
        }
        var tokenAmount =
            web3.EtherAmount.fromUnitAndValue(web3.EtherUnit.wei, tokenBalance);

        final account = Account(
            accountIndex: token.id.toString(),
            balance: tokenAmount.getInWei.toString(),
            bjj: "",
            hezEthereumAddress: ethereumAddress,
            itemId: 0,
            nonce: 0,
            tokenId: tokenId);
        return account;
      }
    } else {
      return null;
    }
  }

  Future<bool> getCreateAccountAuthorization(String hermezAddress) async {
    final createAccountAuth =
        await _hermezService.getCreateAccountAuthorization(hermezAddress);
    return createAccountAuth != null;
  }

  Future<bool> authorizeAccountCreation(String hermezAddress) async {
    final accountCreated = await getCreateAccountAuthorization(hermezAddress);
    if (!accountCreated) {
      return _hermezService.authorizeAccountCreation();
    } else {
      return true;
    }
  }
}
