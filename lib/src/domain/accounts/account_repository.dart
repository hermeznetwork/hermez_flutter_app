import 'package:hermez_sdk/api.dart';
import 'package:hermez_sdk/constants.dart';
import 'package:hermez_sdk/model/account.dart';

abstract class AccountRepository {
  Future<List<Account>> getL2Accounts(String hezAddress, List<int> tokenIds,
      {int fromItem = 0,
      PaginationOrder order = PaginationOrder.ASC,
      int limit = DEFAULT_PAGE_SIZE});
  Future<Account> getL2AccountByAccountIndex(String accountIndex);
  Future<List<Account>> getL1Accounts(String ethereumAddress,
      {bool showZeroBalanceAccounts, List<int> tokenIds});
  Future<Account> getL1Account(String ethereumAddress, int tokenId);
}
