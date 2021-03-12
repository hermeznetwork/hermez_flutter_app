import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hermez/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IStorageService {
  Future<Map> initStorage(String key, bool secure);
  Future<Map> getStorage(String key, bool secure);
  Future<Map> addItem(String key, String chainId, String hermezEthereumAddress,
      dynamic item, bool secure);
  void removeItem(String key, String chainId, String hermezEthereumAddress,
      String id, bool secure);
}

class StorageService implements IStorageService {
  SharedPreferences _localStorage;
  FlutterSecureStorage _secureStorage;
  StorageService(this._localStorage, this._secureStorage);

  @override
  Future<Map> initStorage(String key, bool secure) async {
    final initialStorage = {};

    if (secure) {
      await _secureStorage.write(key: key, value: json.encode(initialStorage));
    } else {
      await _localStorage.setString(key, json.encode(initialStorage));
    }

    return initialStorage;
  }

  @override
  Future<Map> getStorage(String key, bool secure) async {
    final storage = json.decode(_localStorage.getString(key));
    final storageVersion =
        json.decode(_localStorage.getString(STORAGE_VERSION_KEY));

    if (!storageVersion) {
      _localStorage.setString(
          STORAGE_VERSION_KEY, json.encode(STORAGE_VERSION));
    }

    if (!storage || storageVersion != STORAGE_VERSION) {
      return initStorage(key, secure);
    }

    return storage;
  }

  @override
  Future<Map> addItem(String key, String chainId, String hermezEthereumAddress,
      dynamic item, bool secure) async {
    final Map storage = await getStorage(key, secure);
    final Map chainIdStorage =
        storage.containsKey(chainId) ? storage[chainId] : {};
    final List accountStorage =
        chainIdStorage.containsKey(hermezEthereumAddress)
            ? chainIdStorage[hermezEthereumAddress]
            : [];
    /*const newStorage = {
      ...storage,
      [chainId]: {
        ...chainIdStorage,
        [hermezEthereumAddress]: [...accountStorage, item]
      }
    }

    localStorage.setItem(key, JSON.stringify(newStorage))

    return newStorage;*/
  }

  @override
  void removeItem(String key, String chainId, String hermezEthereumAddress,
      String id, bool secure) async {
    final Map storage = await getStorage(key, secure);
    final Map chainIdStorage =
        storage.containsKey(chainId) ? storage[chainId] : {};
    final List accountStorage =
        chainIdStorage.containsKey(hermezEthereumAddress)
            ? chainIdStorage[hermezEthereumAddress]
            : [];
    /*const newStorage = {
      ...storage,
      [chainId]: {
        ...chainIdStorage,
        [hermezEthereumAddress]: accountStorage.filter(item => item.id !== id)
      }
    }

    localStorage.setItem(key, JSON.stringify(newStorage))

    return newStorage;*/
  }

  /*function updatePartialItemByCustomProp (key, chainId, hermezEthereumAddress, prop, partialItem) {
    const storage = getStorage(key)
    const chainIdStorage = storage[chainId] || {}
    const accountStorage = chainIdStorage[hermezEthereumAddress] || []
    const newStorage = {
      ...storage,
      [chainId]: {
        ...chainIdStorage,
        [hermezEthereumAddress]: accountStorage.map((item) => {
        if (item[prop.name] === prop.value) {
            return { ...item, ...partialItem }
        }
            return item
        })
      }
    }

    localStorage.setItem(key, JSON.stringify(newStorage))

    return newStorage
  }*/

  /*function getItemsByHermezAddress (storage, chainId, hermezEthereumAddress) {
    const chainIdIdStorage = storage[chainId] || {}
    const accountStorage = chainIdIdStorage[hermezEthereumAddress] || []

    return accountStorage
  }*/
}
