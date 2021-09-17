import 'package:hermez/service/contract_service.dart';
import 'package:hermez/service/hermez_service.dart';
import 'package:hermez/src/domain/accounts/account_repository.dart';
import 'package:hermez_sdk/api.dart' as api;
import 'package:hermez_sdk/constants.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:web3dart/web3dart.dart' as web3;

class AccountInNetworkRepository implements AccountRepository {
  final ContractService _contractService;
  final HermezService _hermezService;

  AccountInNetworkRepository(this._contractService, this._hermezService);

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
      bool showZeroBalanceAccounts, List<int> tokenIds) async {}

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
}
