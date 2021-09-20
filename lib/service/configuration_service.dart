import 'dart:collection';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hermez/constants.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/service/storage_service.dart';
import 'package:hermez_sdk/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IConfigurationService {
  Future<void> setMnemonic(String value);
  Future<void> setPrivateKey(String value);
  Future<void> setHermezPrivateKey(String value);
  Future<void> setBabyJubJubHex(String value);
  Future<void> setBabyJubJubBase64(String value);
  Future<void> setEthereumAddress(String value);
  Future<void> setHermezAddress(String value);
  Future<void> setDefaultCurrency(WalletDefaultCurrency defaultCurrency);
  Future<void> setDefaultFee(WalletDefaultFee defaultFee);
  Future<void> setPasscode(String value);
  Future<void> setBiometricsFingerprint(bool value);
  Future<void> setBiometricsFace(bool value);
  Future<void> setExchangeRatio(LinkedHashMap<String, dynamic> value);
  Future<void> setLevelSelected(TransactionLevel value);
  Future<void> setupDone(bool value);
  Future<void> backupDone(bool value);
  Future<String> getMnemonic();
  Future<String> getPrivateKey();
  Future<String> getHermezPrivateKey();
  Future<String> getBabyJubJubHex();
  Future<String> getBabyJubJubBase64();
  Future<String> getEthereumAddress();
  Future<String> getHermezAddress();
  Future<WalletDefaultCurrency> getDefaultCurrency();
  Future<WalletDefaultFee> getDefaultFee();
  Future<String> getPasscode();
  bool getBiometricsFingerprint();
  bool getBiometricsFace();
  double getExchangeRatio(String currency);
  Future<TransactionLevel> getLevelSelected();
  bool didSetupWallet();
  bool didBackupWallet();
  /*Future<bool> setLatestNonce(int value);
  int getLatestNonce();*/
  Future<List<dynamic>> getPendingWithdraws();
  dynamic getPendingWithdraw(String pendingWithdrawId);
  Future<void> addPendingWithdraw(dynamic pendingWithdraw);
  Future<void> updatePendingWithdraw(
      String nameToUpdate, String valueToUpdate, String valueId,
      {String nameId = 'id'});
  Future<void> removePendingWithdraw(String value, {String name = 'id'});
  //dynamic getPendingDelayedWithdraw(String pendingWithdrawId);
  //void addPendingDelayedWithdraw(dynamic pendingDelayedWithdraw);
  //void removePendingDelayedWithdraw(String pendingDelayedWithdrawId);
  // L1 Deposits
  Future<List<dynamic>> getPendingDeposits();
  Future<void> addPendingDeposit(dynamic pendingDeposit);
  Future<void> updatePendingDepositId(
      String transactionHash, String transactionId);
  Future<void> removePendingDeposit(String pendingDepositId);
  // L1 Transfers
  Future<List<dynamic>> getPendingTransfers();
  Future<void> addPendingTransfer(dynamic pendingTransfer);
  Future<void> removePendingTransfer(String pendingTransferId);
  // L1 Force Exit
  Future<List<dynamic>> getPendingForceExits();
  Future<void> addPendingForceExit(dynamic pendingForceExit);
  Future<void> updatePendingForceExitId(
      String transactionHash, String transactionId);
  Future<void> removePendingForceExit(String value, {String name = 'id'});
}

class ConfigurationService implements IConfigurationService {
  SharedPreferences _preferences;
  FlutterSecureStorage _secureStorage;
  StorageService _storageService;
  ConfigurationService(
      this._preferences, this._secureStorage, this._storageService);

  @override
  Future<void> setMnemonic(String value) async {
    await _secureStorage.write(key: "mnemonic", value: value);
  }

  @override
  Future<void> setPrivateKey(String value) async {
    await _secureStorage.write(key: "privateKey", value: value);
  }

  @override
  Future<void> setHermezPrivateKey(String value) async {
    await _secureStorage.write(key: "hermezPrivateKey", value: value);
  }

  @override
  Future<void> setBabyJubJubHex(String value) async {
    await _secureStorage.write(key: "babyJubJubHex", value: value);
  }

  @override
  Future<void> setBabyJubJubBase64(String value) async {
    await _secureStorage.write(key: "babyJubJubBase64", value: value);
  }

  @override
  Future<void> setEthereumAddress(String value) async {
    await _secureStorage.write(key: "ethereumAddress", value: value);
  }

  @override
  Future<void> setHermezAddress(String value) async {
    await _secureStorage.write(key: "hermezAddress", value: value);
  }

  @override
  Future<void> setDefaultCurrency(WalletDefaultCurrency value) async {
    await _secureStorage.write(
        key: "defaultCurrency", value: value.toString().split(".").last);
  }

  @override
  Future<void> setDefaultFee(WalletDefaultFee value) async {
    await _secureStorage.write(
        key: "defaultFee", value: value.toString().split(".").last);
  }

  @override
  Future<void> setPasscode(String value) async {
    await _secureStorage.write(key: 'passcode', value: value);
  }

  @override
  Future<void> setBiometricsFingerprint(bool value) async {
    await _preferences.setBool('biometrics_fingerprint', value);
  }

  @override
  Future<void> setBiometricsFace(bool value) async {
    await _preferences.setBool('biometrics_face', value);
  }

  @override
  Future<void> setExchangeRatio(LinkedHashMap<String, dynamic> value) async {
    List<String> exchangeRatios = List.empty(growable: true);
    value.forEach(
        (key, value) => exchangeRatios.add(key + "," + value.toString()));
    await _preferences.setStringList("exchangeRatio", exchangeRatios);
  }

  @override
  Future<void> setLevelSelected(TransactionLevel value) async {
    await _secureStorage.write(
        key: "levelSelected", value: value.toString().split(".").last);
  }

  @override
  Future<void> setupDone(bool value) async {
    await _preferences.setBool("didSetupWallet", value);
  }

  @override
  Future<void> backupDone(bool value) async {
    await _preferences.setBool("didBackupWallet", value);
  }

  // gets
  @override
  Future<String> getMnemonic() async {
    return await _secureStorage.read(key: "mnemonic");
  }

  @override
  Future<String> getPrivateKey() async {
    return _secureStorage.read(key: "privateKey");
  }

  @override
  Future<String> getHermezPrivateKey() async {
    return _secureStorage.read(key: "hermezPrivateKey");
  }

  @override
  Future<String> getBabyJubJubHex() async {
    return _secureStorage.read(key: "babyJubJubHex");
  }

  @override
  Future<String> getBabyJubJubBase64() async {
    return _secureStorage.read(key: "babyJubJubBase64");
  }

  @override
  Future<String> getEthereumAddress() async {
    return _secureStorage.read(key: "ethereumAddress");
  }

  @override
  Future<String> getHermezAddress() async {
    return _secureStorage.read(key: "hermezAddress");
  }

  @override
  Future<WalletDefaultCurrency> getDefaultCurrency() async {
    String defaultCurrencyString =
        await _secureStorage.read(key: "defaultCurrency");
    if (defaultCurrencyString == "EUR") {
      return WalletDefaultCurrency.EUR;
    } else if (defaultCurrencyString == "CNY") {
      return WalletDefaultCurrency.CNY;
    } else if (defaultCurrencyString == "JPY") {
      return WalletDefaultCurrency.JPY;
    } else if (defaultCurrencyString == "GBP") {
      return WalletDefaultCurrency.GBP;
    } else {
      return WalletDefaultCurrency.USD;
    }
  }

  @override
  Future<WalletDefaultFee> getDefaultFee() async {
    String defaultFeeString = await _secureStorage.read(key: "defaultFee");
    if (defaultFeeString == "SLOW") {
      return WalletDefaultFee.SLOW;
    } else if (defaultFeeString == "FAST") {
      return WalletDefaultFee.FAST;
    } else {
      return WalletDefaultFee.AVERAGE;
    }
  }

  @override
  Future<String> getPasscode() async {
    return _secureStorage.read(key: 'passcode');
  }

  @override
  bool getBiometricsFingerprint() {
    return _preferences.getBool("biometrics_fingerprint") ?? false;
  }

  @override
  bool getBiometricsFace() {
    return _preferences.getBool("biometrics_face") ?? false;
  }

  @override
  double getExchangeRatio(String currency) {
    List<String> currencyRatios = _preferences.getStringList("exchangeRatio");
    for (int i = 0; i < currencyRatios.length; i++) {
      if (currencyRatios[i].split(",")[0] == currency) {
        return double.parse(currencyRatios[i].split(",")[1]);
      }
    }
    return 0.0;
  }

  @override
  Future<TransactionLevel> getLevelSelected() async {
    String levelSelected = await _secureStorage.read(key: "levelSelected");
    if (levelSelected == "LEVEL2") {
      return TransactionLevel.LEVEL2;
    } else {
      return TransactionLevel.LEVEL1;
    }
  }

  @override
  bool didSetupWallet() {
    return _preferences.getBool("didSetupWallet") ?? false;
  }

  @override
  bool didBackupWallet() {
    return _preferences.getBool("didBackupWallet") ?? false;
  }

  /*@override
  int getLatestNonce() {
    return _preferences.getInt("latest_nonce") ?? 1;
  }

  Future<bool> setLatestNonce(int value) async {
    return await _preferences.setInt("latest_nonce", value);
  }*/

  @override
  Future<List<dynamic>> getPendingForceExits() async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final ethereumAddress = await getEthereumAddress();

    final storage =
        await _storageService.getStorage(PENDING_FORCE_EXITS_KEY, false);

    final List accountPendingForceExits = _storageService
        .getItemsByHermezAddress(storage, chainId, ethereumAddress);
    return accountPendingForceExits;
  }

  @override
  Future<List<dynamic>> getPendingWithdraws() async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    final storage =
        await _storageService.getStorage(PENDING_WITHDRAWS_KEY, false);

    final List accountPendingWithdraws = _storageService
        .getItemsByHermezAddress(storage, chainId, hermezEthereumAddress);
    return accountPendingWithdraws;
  }

  /// Gets a pendingWithdraw from the pendingWithdraw pool
  /// @param {string} pendingWithdrawId - The pendingWithdraw id
  /// @returns {object} pendingWithdraw - The pendingWithdraw to add to the pool
  @override
  dynamic getPendingWithdraw(String pendingWithdrawId) async {
    final List accountPendingWithdraws = await getPendingWithdraws();
    dynamic result;
    if (accountPendingWithdraws != null) {
      result = accountPendingWithdraws.firstWhere(
          (pendingWithdraw) => pendingWithdraw['id'] == pendingWithdrawId,
          orElse: () => null);
    }
    return result;
  }

  /// Adds a pendingWithdraw to the pendingWithdraw pool
  /// @param {string} hermezEthereumAddress - The account with which the pendingWithdraw was made
  /// @param {string} pendingWithdraw - The pendingWithdraw to add to the pool
  /// @returns {void}
  @override
  Future<void> addPendingWithdraw(dynamic pendingWithdraw) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    await _storageService.addItem(PENDING_WITHDRAWS_KEY, chainId,
        hermezEthereumAddress, pendingWithdraw, false);
  }

  /// Removes a pendingWithdraw from the pendingWithdraw pool
  /// @param {string} pendingWithdrawId - The pendingWithdraw identifier to remove from the pool
  /// @returns {void}
  @override
  Future<void> removePendingWithdraw(String value, {String name = 'id'}) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    await _storageService.removeItem(PENDING_WITHDRAWS_KEY, chainId,
        hermezEthereumAddress, name, value, false);
  }

  @override
  Future<void> updatePendingWithdraw(
      String nameToUpdate, String valueToUpdate, String valueId,
      {String nameId = 'id'}) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    await _storageService.updatePartialItemByCustomProp(
        PENDING_WITHDRAWS_KEY,
        chainId,
        hermezEthereumAddress,
        {'name': nameId, 'value': valueId},
        {nameToUpdate: valueToUpdate},
        false);
  }

  @override
  Future<List<dynamic>> getPendingTransfers() async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final ethereumAddress = await getEthereumAddress();

    final storage =
        await _storageService.getStorage(PENDING_TRANSFERS_KEY, false);

    final List accountPendingTransfers = _storageService
        .getItemsByHermezAddress(storage, chainId, ethereumAddress);
    return accountPendingTransfers;
  }

/*/// Gets a pendingWithdraw from the pendingWithdraw pool
  /// @param {string} pendingWithdrawId - The pendingWithdraw id
  /// @returns {object} pendingWithdraw - The pendingWithdraw to add to the pool
  @override
  dynamic getPendingDelayedWithdraw(String pendingWithdrawId) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    final storage =
        await _storageService.getStorage(PENDING_DELAYED_WITHDRAWS_KEY, false);

    final List accountPendingDelayedWithdraws = _storageService
        .getItemsByHermezAddress(storage, chainId, hermezEthereumAddress);
    return accountPendingDelayedWithdraws.firstWhere(
        (pendingDelayedWithdraw) =>
            pendingDelayedWithdraw['id'] == pendingWithdrawId,
        orElse: () => null);
  }*/

  /*/// Adds a pendingDelayedWithdraw to the pendingDelayedWithdraw store
  /// @param {dynamic} pendingDelayedWithdraw - The pendingDelayedWithdraw to add to the store
  /// @returns {void}
  @override
  void addPendingDelayedWithdraw(dynamic pendingDelayedWithdraw) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    await _storageService.addItem(PENDING_DELAYED_WITHDRAWS_KEY, chainId,
        hermezEthereumAddress, pendingDelayedWithdraw, false);
  }

  /// Removes a pendingDelayedWithdraw from the pendingDelayedWithdraw store
  /// @param {string} pendingDelayedWithdrawId - The pendingDelayedWithdraw identifier to remove from the store
  /// @returns {void}
  @override
  void removePendingDelayedWithdraw(String pendingDelayedWithdrawId) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    await _storageService.removeItem(PENDING_DELAYED_WITHDRAWS_KEY, chainId,
        hermezEthereumAddress, 'id', pendingDelayedWithdrawId, false);
  }

  /// Updates the date in a delayed withdraw transaction
  /// to the time when the transaction was mined
  /// @param {String} transactionHash - The L1 transaction hash for a non-instant withdraw
  /// @param {Number} pendingDelayedWithdrawDate - The date when the L1 transaction was mined
  void updatePendingDelayedWithdrawDate(
      String transactionHash, num pendingDelayedWithdrawDate) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    await _storageService.updatePartialItemByCustomProp(
        PENDING_DELAYED_WITHDRAWS_KEY,
        chainId,
        hermezEthereumAddress,
        {'name': 'hash', 'value': transactionHash},
        {'date': pendingDelayedWithdrawDate},
        false);
  }*/

  /*@override
  function checkPendingDelayedWithdraw (exitId) {
    return (dispatch, getState) => {
    const { global: { wallet, pendingDelayedWithdraws, ethereumNetworkTask } } = getState()

    dispatch(globalActions.checkPendingDelayedWithdraw())
    const provider = Providers.getProvider()
    const accountPendingDelayedWithdraws = storage.getItemsByHermezAddress(
    pendingDelayedWithdraws,
    ethereumNetworkTask.data.chainId,
    wallet.hermezEthereumAddress
    )

    const pendingDelayedWithdraw = accountPendingDelayedWithdraws.find((delayedWithdraw) => delayedWithdraw.id === exitId)
    if (pendingDelayedWithdraw) {
      provider.getTransaction(pendingDelayedWithdraw.hash).then((transaction) => {
        provider.getBlock(transaction.blockNumber).then((block) => {
          // Converts timestamp from s to ms
          const newTimestamp = block.timestamp * 1000
          if (pendingDelayedWithdraw.date !== newTimestamp) {
            dispatch(updatePendingDelayedWithdrawDate(pendingDelayedWithdraw.hash, newTimestamp))
          }
          dispatch(globalActions.checkPendingDelayedWithdrawSuccess())
        })
      }).catch(console.log)
    } else {
    dispatch(globalActions.checkPendingDelayedWithdrawSuccess())
    }
  }
  }*/

  @override
  Future<List<dynamic>> getPendingDeposits() async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    final storage =
        await _storageService.getStorage(PENDING_DEPOSITS_KEY, false);

    final List accountPendingDeposits = _storageService.getItemsByHermezAddress(
        storage, chainId, hermezEthereumAddress);
    return accountPendingDeposits;
  }

  /// Adds a pendingDeposit to the pendingDeposits store
  /// @param {string} pendingDeposit - The pendingDeposit to add to the store
  /// @returns {void}
  @override
  Future<void> addPendingDeposit(dynamic pendingDeposit) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    await _storageService.addItem(PENDING_DEPOSITS_KEY, chainId,
        hermezEthereumAddress, pendingDeposit, false);
  }

  /// Removes a pendingDeposit from the pendingDeposit store
  /// @param {string} transactionId - The transaction identifier used to remove a pendingDeposit from the store
  /// @returns {void}
  @override
  Future<void> removePendingDeposit(String transactionHash) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    await _storageService.removeItem(PENDING_DEPOSITS_KEY, chainId,
        hermezEthereumAddress, 'hash', transactionHash, false);
  }

  Future<void> updatePendingDepositId(
      String transactionHash, String transactionId) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    await _storageService.updatePartialItemByCustomProp(
        PENDING_DEPOSITS_KEY,
        chainId,
        hermezEthereumAddress,
        {'name': 'hash', 'value': transactionHash},
        {'id': transactionId},
        false);
  }

  /*void checkPendingDeposits(Web3Client web3Client) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();
    final storage =
        await _storageService.getStorage(PENDING_DEPOSITS_KEY, false);

    final List accountPendingDeposits = _storageService.getItemsByHermezAddress(
        storage, chainId, hermezEthereumAddress);
    final pendingDepositsHashes =
        accountPendingDeposits.map((deposit) => deposit['hash']).toList();
    final pendingDepositsTxReceipts = pendingDepositsHashes
        .map((hash) async => await web3Client.getTransactionReceipt(hash))
        .toList();

    /*final txId = getL1UserTxId(l1UserTxEvent.args[0], l1UserTxEvent.args[1]);
    if (pendingDeposit && !pendingDeposit.id) {
      dispatch(updatePendingDepositId(txReceipt.transactionHash, txId));
    }*/

    /*pendingDepositsTxReceipts.forEach((List txReceipts) {
      txReceipts.removeWhere((txReceipt) => txReceipt != null && txReceipt.logs && txReceipt.logs.length > 0)
    });*/
  }*/

  /// Adds a pendingTransfer to the pendingTransfers store
  /// @param {string} pendingTransfer - The pendingTransfer to add to the store
  /// @returns {void}
  @override
  Future<void> addPendingTransfer(dynamic pendingTransfer) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final ethereumAddress = await getEthereumAddress();

    await _storageService.addItem(PENDING_TRANSFERS_KEY, chainId,
        ethereumAddress, pendingTransfer, false);
  }

  /// Removes a pendingTransfer from the pendingTransfer store
  /// @param {string} transactionId - The transaction identifier used to remove a pendingTransfer from the store
  /// @returns {void}
  @override
  Future<void> removePendingTransfer(String transactionHash) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final ethereumAddress = await getEthereumAddress();

    await _storageService.removeItem(PENDING_TRANSFERS_KEY, chainId,
        ethereumAddress, 'hash', transactionHash, false);
  }

  /// Adds a pendingTransfer to the pendingTransfers store
  /// @param {string} pendingTransfer - The pendingTransfer to add to the store
  /// @returns {void}
  @override
  Future<void> addPendingForceExit(dynamic pendingForceExit) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final ethereumAddress = await getEthereumAddress();

    await _storageService.addItem(PENDING_FORCE_EXITS_KEY, chainId,
        ethereumAddress, pendingForceExit, false);
  }

  /// Removes a pendingTransfer from the pendingTransfer store
  /// @param {string} transactionId - The transaction identifier used to remove a pendingTransfer from the store
  /// @returns {void}
  @override
  Future<void> removePendingForceExit(String value,
      {String name = 'id'}) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final ethereumAddress = await getEthereumAddress();

    await _storageService.removeItem(
        PENDING_FORCE_EXITS_KEY, chainId, ethereumAddress, name, value, false);
  }

  @override
  Future<void> updatePendingForceExitId(
      String transactionHash, String transactionId) async {
    final chainId = getCurrentEnvironment().chainId.toString();
    final hermezEthereumAddress = await getHermezAddress();

    await _storageService.updatePartialItemByCustomProp(
        PENDING_FORCE_EXITS_KEY,
        chainId,
        hermezEthereumAddress,
        {'name': 'hash', 'value': transactionHash},
        {'id': transactionId},
        false);
  }

  /*function checkPendingDeposits () {
    return (dispatch, getState) => {
    const { global: { wallet, pendingDeposits, ethereumNetworkTask } } = getState()

    dispatch(globalActions.checkPendingDeposits())
    const provider = Providers.getProvider()
    const accountPendingDeposits = storage.getItemsByHermezAddress(
    pendingDeposits,
    ethereumNetworkTask.data.chainId,
    wallet.hermezEthereumAddress
    )
    const pendingDepositsHashes = accountPendingDeposits.map(deposit => deposit.hash)
    const pendingDepositsTxReceipts = pendingDepositsHashes.map(hash => provider.getTransactionReceipt(hash))

    Promise.all(pendingDepositsTxReceipts).then((txReceipts) => {
    const transactionHistoryPromises = txReceipts
        .filter(txReceipt => txReceipt && txReceipt.logs && txReceipt.logs.length > 0)
        .map((txReceipt) => {
    const hermezContractInterface = new ethers.utils.Interface(HermezABI)
    // Need to parse logs, but only events from the Hermez SC. Ignore errors when trying to parse others
    const parsedLogs = []
    for (const txReceiptLog of txReceipt.logs) {
    try {
    const parsedLog = hermezContractInterface.parseLog(txReceiptLog)
    parsedLogs.push(parsedLog)
    } catch (e) {}
    }
    const l1UserTxEvent = parsedLogs.find((event) => event.name === 'L1UserTxEvent')

    if (!l1UserTxEvent) {
    return Promise.resolve()
    }

    const txId = TxUtils.getL1UserTxId(l1UserTxEvent.args[0], l1UserTxEvent.args[1])
    const pendingDeposit = accountPendingDeposits.find(deposit => deposit.hash === txReceipt.transactionHash)

    if (pendingDeposit && !pendingDeposit.id) {
    dispatch(updatePendingDepositId(txReceipt.transactionHash, txId))
    }

    return CoordinatorAPI.getHistoryTransaction(txId)
    })

    Promise.all(transactionHistoryPromises)
        .then((results) => {
    results
        .filter(result => result !== undefined)
        .forEach((transaction) => {
    if (transaction.batchNum !== null) {
    dispatch(removePendingDeposit(transaction.id))
    }
    })
    dispatch(globalActions.checkPendingDepositsSuccess())
    })
        .catch(() => dispatch(globalActions.checkPendingDepositsSuccess()))
    })
  }
  }*/
}
