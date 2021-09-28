import 'package:flutter/widgets.dart';
import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';

abstract class AccountState {
  final AccountItemState accountItem;
  AccountState({@required this.accountItem});

  factory AccountState.init() => InitAccountState();

  factory AccountState.loaded(AccountItemState accountItem) =>
      LoadedAccountState(accountItem: accountItem);

  factory AccountState.error(String message) =>
      ErrorAccountState(message: message);
}

class InitAccountState extends AccountState {
  InitAccountState();
}

class LoadedAccountState extends AccountState {
  final AccountItemState accountItem;

  LoadedAccountState({@required this.accountItem});
}

class ErrorAccountState<T> extends AccountState {
  final String message;

  ErrorAccountState({@required this.message});
}

class AccountItemState {
  final TransactionLevel txLevel;
  final List<Account> accounts;

  AccountItemState(this.txLevel, this.accounts);
}
