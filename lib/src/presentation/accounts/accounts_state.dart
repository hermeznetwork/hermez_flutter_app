import 'package:flutter/widgets.dart';
import 'package:hermez/src/domain/accounts/account.dart';

abstract class AccountsState {
  final AccountsItemState accountsItem;
  AccountsState({@required this.accountsItem});

  factory AccountsState.init() => LoadingAccountsState();

  factory AccountsState.loading() => LoadingAccountsState();

  factory AccountsState.loaded(AccountsItemState accountsItem) =>
      LoadedAccountsState(accountsItem: accountsItem);

  factory AccountsState.error(String message) =>
      ErrorAccountsState(message: message);
}

class LoadingAccountsState extends AccountsState {
  LoadingAccountsState();
}

class LoadedAccountsState extends AccountsState {
  final AccountsItemState accountsItem;

  LoadedAccountsState({@required this.accountsItem});
}

class ErrorAccountsState<T> extends AccountsState {
  final String message;

  ErrorAccountsState({@required this.message});
}

class AccountsItemState {
  final List<Account> accounts;

  AccountsItemState(this.accounts);
}
