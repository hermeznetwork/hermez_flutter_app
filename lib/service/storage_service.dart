import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hermez/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IStorageService {
  Future<Map> getStorage(String key, bool secure);
  Future<Map> addItem(String key, String chainId, String hermezEthereumAddress,
      dynamic item, bool secure);
  void removeItem(String key, String chainId, String hermezEthereumAddress,
      String name, String value, bool secure);
  dynamic getItemsByHermezAddress(
      Map storage, String chainId, String hermezEthereumAddress);
}

class StorageService implements IStorageService {
  SharedPreferences _localStorage;
  FlutterSecureStorage _secureStorage;
  StorageService(this._localStorage, this._secureStorage);

  Future<Map<String, dynamic>> initStorage(String key, bool secure) async {
    final initialStorage = Map<String, dynamic>();

    if (secure) {
      await _secureStorage.write(key: key, value: json.encode(initialStorage));
    } else {
      await _localStorage.setString(key, json.encode(initialStorage));
    }

    return initialStorage;
  }

  @override
  Future<Map<String, dynamic>> getStorage(String key, bool secure) async {
    var storage;
    var storageVersion;
    if (secure) {
      storage = json.decode(await _secureStorage.read(key: key));
      storageVersion =
          json.decode(await _secureStorage.read(key: STORAGE_VERSION_KEY));

      if (storageVersion == null) {
        _secureStorage.write(
            key: STORAGE_VERSION_KEY, value: json.encode(STORAGE_VERSION));
      }
    } else {
      if (_localStorage.containsKey(key)) {
        storage = json.decode(_localStorage.getString(key));
      }
      if (_localStorage.containsKey(STORAGE_VERSION_KEY)) {
        storageVersion =
            json.decode(_localStorage.getString(STORAGE_VERSION_KEY));
      }

      if (storageVersion == null) {
        _localStorage.setString(
            STORAGE_VERSION_KEY, json.encode(STORAGE_VERSION));
      }
    }
    if (storage == null ||
        storageVersion == null ||
        storageVersion != STORAGE_VERSION) {
      return initStorage(key, secure);
    }

    return storage;
  }

  @override
  Future<Map> addItem(String key, String chainId, String hermezEthereumAddress,
      dynamic item, bool secure) async {
    final Map<String, dynamic> storage = await getStorage(key, secure);
    final Map<String, dynamic> chainIdStorage = storage.containsKey(chainId)
        ? storage[chainId]
        : Map<String, dynamic>();
    final List accountStorage =
        chainIdStorage.containsKey(hermezEthereumAddress)
            ? chainIdStorage[hermezEthereumAddress]
            : [];

    final List newAccountStorage = List()..addAll(accountStorage);
    newAccountStorage.add(item);

    final Map<String, dynamic> newChainIdStorage = Map<String, dynamic>()
      ..addAll(chainIdStorage);
    newChainIdStorage.update(
        hermezEthereumAddress, (value) => newAccountStorage,
        ifAbsent: () => newAccountStorage);

    final Map<String, dynamic> newStorage = Map<String, dynamic>()
      ..addAll(storage);
    newStorage.update(chainId, (value) => newChainIdStorage,
        ifAbsent: () => newChainIdStorage);

    if (secure) {
      await _secureStorage.write(key: key, value: json.encode(newStorage));
    } else {
      await _localStorage.setString(key, json.encode(newStorage));
    }

    return newStorage;
  }

  @override
  Future<Map> removeItem(
      String key,
      String chainId,
      String hermezEthereumAddress,
      String name,
      String value,
      bool secure) async {
    final Map storage = await getStorage(key, secure);
    final Map chainIdStorage =
        storage.containsKey(chainId) ? storage[chainId] : {};
    final List accountStorage =
        chainIdStorage.containsKey(hermezEthereumAddress)
            ? chainIdStorage[hermezEthereumAddress]
            : [];

    accountStorage.removeWhere((item) => item[name] == value);

    final Map<String, dynamic> newChainIdStorage = Map<String, dynamic>()
      ..addAll(chainIdStorage);
    newChainIdStorage.update(hermezEthereumAddress, (value) => accountStorage,
        ifAbsent: () => accountStorage);

    final Map<String, dynamic> newStorage = Map<String, dynamic>()
      ..addAll(storage);
    newStorage.update(chainId, (value) => newChainIdStorage,
        ifAbsent: () => newChainIdStorage);

    if (secure) {
      await _secureStorage.write(key: key, value: json.encode(newStorage));
    } else {
      await _localStorage.setString(key, json.encode(newStorage));
    }

    return newStorage;
  }

  @override
  Future<Map> updatePartialItemByCustomProp(
      String key,
      String chainId,
      String hermezEthereumAddress,
      Map<String, dynamic> prop,
      Map<String, dynamic> partialItem,
      bool secure) async {
    final Map storage = await getStorage(key, secure);
    final Map chainIdStorage =
        storage.containsKey(chainId) ? storage[chainId] : {};
    final List accountStorage =
        chainIdStorage.containsKey(hermezEthereumAddress)
            ? chainIdStorage[hermezEthereumAddress]
            : [];

    final Map<String, dynamic> newStorage = Map<String, dynamic>()
      ..addAll(storage);

    final Map<String, dynamic> newChainIdStorage = Map<String, dynamic>()
      ..addAll(chainIdStorage);

    final List newAccountStorage = accountStorage.map((item) {
      if (item[prop['name']] == prop['value']) {
        return {...item, ...partialItem};
      } else {
        return item;
      }
    }).toList();

    newChainIdStorage.update(
        hermezEthereumAddress, (value) => newAccountStorage,
        ifAbsent: () => newAccountStorage);

    newStorage.update(chainId, (value) => newChainIdStorage,
        ifAbsent: () => newChainIdStorage);

    if (secure) {
      await _secureStorage.write(key: key, value: json.encode(newStorage));
    } else {
      await _localStorage.setString(key, json.encode(newStorage));
    }

    return newStorage;
  }

  @override
  dynamic getItemsByHermezAddress(
      Map storage, String chainId, String hermezEthereumAddress) {
    final chainIdIdStorage =
        storage.containsKey(chainId) ? storage[chainId] : {};
    final accountStorage = chainIdIdStorage.containsKey(hermezEthereumAddress)
        ? chainIdIdStorage[hermezEthereumAddress]
        : [];

    return accountStorage;
  }
}
