import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/accounts/usecases/create_account_auth_use_case.dart';
import 'package:hermez/src/domain/accounts/usecases/get_account_use_case.dart';
import 'package:hermez/src/domain/accounts/usecases/get_accounts_use_case.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez/src/presentation/accounts/account_state.dart';

class AccountBloc extends Bloc<AccountState> {
  final GetAccountsUseCase _getAccountsUseCase;
  final GetAccountUseCase _getAccountUseCase;
  final CreateAccountAuthUseCase _createAccountAuthUseCase;

  AccountBloc(this._getAccountsUseCase, this._getAccountUseCase,
      this._createAccountAuthUseCase) {
    changeState(AccountState.init());
  }

  Future<List<Account>> getAccounts(
      [LayerFilter layerFilter = LayerFilter.ALL,
      String address = "",
      List<int> tokenIds]) {
    return _getAccountsUseCase
        .execute(layerFilter, address, tokenIds)
        .then((accounts) {
      return accounts;
      //changeState(AccountState.mnemonicCreated(QrcodeItemState(mnemonic)));
    }).catchError((error) {
      return null;
      //changeState(QrcodeState.error('A network error has occurred'));
    });
  }

  Future<Account> getAccount(String accountIndex, int tokenId,
      [TransactionLevel transactionLevel, String address]) {
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

  Future<bool> getCreateAccountAuthorization(String address) async {
    return await _createAccountAuthUseCase
        .getCreateAccountAuthorization(address);
  }

  Future<bool> authorizeAccountCreation(String address) async {
    return await _createAccountAuthUseCase.authorizeAccountCreation(address);
  }
}
