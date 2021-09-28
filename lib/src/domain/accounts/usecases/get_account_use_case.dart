import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/accounts/account_repository.dart';
import 'package:hermez/src/domain/prices/price_repository.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/tokens/token_repository.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez_sdk/addresses.dart';
import 'package:hermez_sdk/model/account.dart' as hezAccount;
import 'package:hermez_sdk/model/token.dart';

class GetAccountUseCase {
  final TokenRepository _tokenRepository;
  final PriceRepository _priceRepository;
  final AccountRepository _accountRepository;

  GetAccountUseCase(
    this._tokenRepository,
    this._priceRepository,
    this._accountRepository,
  );

  Future<Account> execute(
      [TransactionLevel transactionLevel = TransactionLevel.LEVEL2,
      String address = "",
      String accountIndex,
      int tokenId = 0]) async {
    /*if (address == null || address == "") {
      hezAddress = addresses.getHermezAddress(state.ethereumAddress);
    }*/

    Token token = await _tokenRepository.getTokenById(tokenId);
    PriceToken priceToken = await _priceRepository.getTokenPrice(tokenId);

    switch (transactionLevel) {
      case TransactionLevel.LEVEL2:
        bool validAddress = false;
        validAddress = isHermezAccountIndex(accountIndex);
        if (validAddress) {
          hezAccount.Account hermezAccount =
              await _accountRepository.getL2AccountByAccountIndex(accountIndex);

          bool l2Account =
              hermezAccount.bjj != null && hermezAccount.bjj.length > 0;
          return Account(l2Account: l2Account, token: token, price: priceToken);
        }
        break;
      case TransactionLevel.LEVEL1:
        String ethereumAddress = address;
        bool validAddress = false;
        validAddress = isEthereumAddress(ethereumAddress);
        if (!validAddress && isHermezEthereumAddress(address)) {
          ethereumAddress = getEthereumAddress(address);
          validAddress = isEthereumAddress(ethereumAddress);
        }
        if (validAddress) {
          hezAccount.Account hermezAccount =
              await _accountRepository.getL1Account(ethereumAddress, tokenId);

          bool l2Account =
              hermezAccount.bjj != null && hermezAccount.bjj.length > 0;
          return Account(
              l2Account: l2Account,
              address: ethereumAddress,
              token: token,
              price: priceToken);
        }
        break;
    }
  }
}
