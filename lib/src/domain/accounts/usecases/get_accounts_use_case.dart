import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/accounts/account_repository.dart';
import 'package:hermez/src/domain/prices/price_repository.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/tokens/token_repository.dart';
import 'package:hermez_sdk/model/account.dart' as hezAccount;
import 'package:hermez_sdk/model/token.dart';

class GetAccountsUseCase {
  final TokenRepository _tokenRepository;
  final PriceRepository _priceRepository;
  final AccountRepository _accountRepository;

  GetAccountsUseCase(
    this._tokenRepository,
    this._priceRepository,
    this._accountRepository,
  );

  Future<List<Account>> execute(
      {String hezAddress = "", List<int> tokenIds}) async {
    /*if (hezAddress == null) {
      hezAddress = addresses.getHermezAddress(state.ethereumAddress);
    }*/

    if (tokenIds == null) {
      tokenIds = [];
    }
    List<Token> tokens = await _tokenRepository.getTokens();
    List<PriceToken> priceTokens = await _priceRepository.getTokensPrices();
    List<hezAccount.Account> hezAccounts =
        await _accountRepository.getL2Accounts(hezAddress, tokenIds);

    List<Account> accounts = hezAccounts.map((hezAccount) {
      bool l2Account = hezAccount.bjj != null && hezAccount.bjj.length > 0;
      Token token =
          tokens.firstWhere((token) => token.id == hezAccount.tokenId);
      PriceToken priceToken = priceTokens
          .firstWhere((priceToken) => priceToken.id == hezAccount.tokenId);
      return Account(l2Account: l2Account, token: token, price: priceToken);
    });

    return accounts; //Account.createEmpty(); _accountRepository.getAccounts();
  }
}
