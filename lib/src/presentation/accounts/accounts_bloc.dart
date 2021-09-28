import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/accounts/usecases/get_accounts_use_case.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez/src/presentation/accounts/accounts_state.dart';

class AccountsBloc extends Bloc<AccountsState> {
  final GetAccountsUseCase _getAccountsUseCase;

  AccountsBloc(this._getAccountsUseCase) {
    changeState(AccountsState.init());
  }

  void getAccounts(
      [LayerFilter layerFilter = LayerFilter.ALL, String address = ""]) {
    changeState(AccountsState.loading());
    _getAccountsUseCase.execute(layerFilter, address).then((accounts) {
      changeState(AccountsState.loaded(AccountsItemState(accounts)));
    }).catchError((error) {
      changeState(AccountsState.error('A network error has occurred'));
    });
  }
}
