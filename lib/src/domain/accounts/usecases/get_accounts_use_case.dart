import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/accounts/account_repository.dart';
import 'package:hermez/src/domain/prices/price_repository.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/tokens/token.dart';
import 'package:hermez/src/domain/tokens/token_repository.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez_sdk/addresses.dart';
import 'package:hermez_sdk/model/account.dart' as hezAccount;
import 'package:hermez_sdk/model/token.dart' as hezToken;

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
      [LayerFilter layerFilter = LayerFilter.ALL,
      String address = "",
      List<int> tokenIds]) async {
    /*if (address == null || address == "") {
      hezAddress = addresses.getHermezAddress(state.ethereumAddress);
    }*/

    if (tokenIds == null) {
      tokenIds = [];
    }
    List<hezToken.Token> tokens = await _tokenRepository.getTokens();
    List<PriceToken> priceTokens = await _priceRepository.getTokensPrices();

    List<Account> accounts = [];

    if (layerFilter == LayerFilter.ALL || layerFilter == LayerFilter.L2) {
      String hermezAddress = address;
      bool validAddress = false;
      validAddress = isHermezEthereumAddress(hermezAddress);
      if (!validAddress && isEthereumAddress(address)) {
        hermezAddress = getHermezAddress(address);
        validAddress = isHermezEthereumAddress(hermezAddress);
      }
      if (validAddress) {
        List<hezAccount.Account> hezAccounts =
            await _accountRepository.getL2Accounts(hermezAddress, tokenIds);

        accounts.addAll(hezAccounts.map((hezAccount) {
          bool l2Account = hezAccount.bjj != null && hezAccount.bjj.length > 0;
          hezToken.Token hermezToken =
              tokens.firstWhere((token) => token.id == hezAccount.tokenId);
          PriceToken priceToken = priceTokens
              .firstWhere((priceToken) => priceToken.id == hezAccount.tokenId);
          Token token = Token(token: hermezToken, price: priceToken);
          return Account(l2Account: l2Account, token: token);
        }));
      }
    }

    if (layerFilter == LayerFilter.ALL || layerFilter == LayerFilter.L1) {
      String ethereumAddress = address;
      bool validAddress = false;
      validAddress = isEthereumAddress(ethereumAddress);
      if (!validAddress && isHermezEthereumAddress(address)) {
        ethereumAddress = getEthereumAddress(address);
        validAddress = isEthereumAddress(ethereumAddress);
      }
      if (validAddress) {
        List<hezAccount.Account> hezAccounts =
            await _accountRepository.getL1Accounts(ethereumAddress);

        accounts.addAll(hezAccounts.map((hezAccount) {
          bool l2Account = hezAccount.bjj != null && hezAccount.bjj.length > 0;
          hezToken.Token hermezToken =
              tokens.firstWhere((token) => token.id == hezAccount.tokenId);
          PriceToken priceToken = priceTokens
              .firstWhere((priceToken) => priceToken.id == hezAccount.tokenId);
          Token token = Token(token: hermezToken, price: priceToken);
          return Account(
              l2Account: l2Account, address: ethereumAddress, token: token);
        }));
      }
    }

    return accounts; //Account.createEmpty(); _accountRepository.getAccounts();
  }
}
