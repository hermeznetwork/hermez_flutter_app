import 'package:hermez/src/domain/accounts/account_repository.dart';

class CreateAccountAuthUseCase {
  final AccountRepository _accountRepository;

  CreateAccountAuthUseCase(
    this._accountRepository,
  );

  Future<bool> authorizeAccountCreation([String address = ""]) async {
    /*if (address == null || address == "") {
      hezAddress = addresses.getHermezAddress(state.ethereumAddress);
    }*/

    return await _accountRepository.authorizeAccountCreation(address);
  }

  Future<bool> getCreateAccountAuthorization([String address = ""]) async {
    /*if (address == null || address == "") {
      hezAddress = addresses.getHermezAddress(state.ethereumAddress);
    }*/

    return await _accountRepository.getCreateAccountAuthorization(address);
  }
}
