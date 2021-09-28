import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/accounts/usecases/get_account_use_case.dart';
import 'package:hermez/src/domain/accounts/usecases/get_accounts_use_case.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez/src/presentation/accounts/account_state.dart';

class AccountBloc extends Bloc<AccountState> {
  final GetAccountsUseCase _getAccountsUseCase;
  final GetAccountUseCase _getAccountUseCase;

  AccountBloc(this._getAccountsUseCase, this._getAccountUseCase) {
    changeState(AccountState.init());
  }

  Future<List<Account>> getAccounts(
      [LayerFilter layerFilter = LayerFilter.ALL, String address = ""]) {
    return _getAccountsUseCase.execute(layerFilter, address).then((accounts) {
      return accounts;
      //changeState(AccountState.mnemonicCreated(QrcodeItemState(mnemonic)));
    }).catchError((error) {
      return null;
      //changeState(QrcodeState.error('A network error has occurred'));
    });
  }

  Future<Account> getAccount(TransactionLevel transactionLevel, String address,
      String accountIndex, int tokenId) {
    return _getAccountUseCase
        .execute(transactionLevel, address, accountIndex, tokenId)
        .then((account) {
      return account;
      //changeState(AccountState.mnemonicCreated(QrcodeItemState(mnemonic)));
    }).catchError((error) {
      return null;
      //changeState(QrcodeState.error('A network error has occurred'));
    });
  }
}
