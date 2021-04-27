import 'dart:async';
import 'dart:convert';

import 'package:hermez_plugin/environment.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

typedef TransferEvent = void Function(
    EthereumAddress from, EthereumAddress to, BigInt value);

abstract class IExplorerService {
  Future<List<dynamic>> getTokenTransferEventsByAccountAddress(
      String tokenAddress, String accountAddress,
      {String sort = 'desc', int startblock = 0});
  Future<List<dynamic>> getTransferEventsByAccountAddress(String address,
      {String sort = 'desc', int startblock = 0});
  Future<BigInt> getTokenBalanceByAccountAddress(
      String tokenAddress, String accountAddress);
  Future<Map<String, dynamic>> getTokenInfo(String tokenAddress);
  Future<List<dynamic>> getListOfTokensByAddress(String address);
}

class ExplorerService implements IExplorerService {
  String _base;
  String _apiKey;
  Client _client;

  ExplorerService(String base, String apiKey) {
    _base = base;
    _apiKey = apiKey;
    _client = new Client();
  }

  Future<List<dynamic>> getTokenTransferEventsByAccountAddress(
      String tokenAddress, String accountAddress,
      {String sort = 'desc', int startblock = 0}) async {
    try {
      Map<String, dynamic> resp = await _get(
          '?module=account&action=tokentx&contractaddress=$tokenAddress&address=$accountAddress&startblock=$startblock&sort=$sort');
      if (resp['message'] == 'OK' && resp['status'] == '1') {
        List transfers = [];
        for (dynamic transferEvent in resp['result']) {
          transfers.add({
            'blockNumber': num.parse(transferEvent['blockNumber']),
            'txHash': transferEvent['hash'],
            'to': transferEvent['to'],
            'from': transferEvent["from"],
            'status': "CONFIRMED",
            'timestamp': DateTime.fromMillisecondsSinceEpoch(
                    DateTime.fromMillisecondsSinceEpoch(
                                int.parse(transferEvent['timeStamp']))
                            .millisecondsSinceEpoch *
                        1000)
                .millisecondsSinceEpoch,
            'value': transferEvent['value'],
            'tokenAddress': tokenAddress,
            'type': transferEvent["from"].toString().toLowerCase() ==
                    accountAddress.toLowerCase()
                ? 'SEND'
                : 'RECEIVE',
          });
        }
        return transfers;
      } else {
        return [];
      }
    } catch (e) {
      throw 'Error! Get token transfers events failed for - accountAddress: $accountAddress --- $e';
    }
  }

  Future<List<dynamic>> getTransactionsByAccountAddress(String address,
      {String sort = 'desc', int startblock = 0}) async {
    try {
      Map<String, dynamic> resp = await _get(
          '?module=account&action=txlist&address=$address&startblock=$startblock&sort=$sort');
      if (resp['message'] == 'OK' && resp['status'] == '1') {
        List transfers = [];
        for (dynamic transferEvent in resp['result']) {
          if (double.parse(transferEvent['value']) > 0) {
            String type;
            if (transferEvent["to"].toString().toLowerCase() ==
                getCurrentEnvironment()
                    .contracts['Hermez']
                    .toString()
                    .toLowerCase()) {
              type = 'WITHDRAW';
            } else if (transferEvent["from"].toString().toLowerCase() ==
                getCurrentEnvironment()
                    .contracts['Hermez']
                    .toString()
                    .toLowerCase()) {
              type = 'DEPOSIT';
            } else if (transferEvent["from"].toString().toLowerCase() ==
                address.toLowerCase()) {
              type = 'SEND';
            } else if (transferEvent["to"].toString().toLowerCase() ==
                address.toLowerCase()) {
              type = 'RECEIVE';
            }
            transfers.add({
              'blockNumber': num.parse(transferEvent['blockNumber']),
              'txHash': transferEvent['hash'],
              'to': transferEvent['to'],
              'from': transferEvent["from"],
              'status': "CONFIRMED",
              'timestamp': DateTime.fromMillisecondsSinceEpoch(
                      DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(transferEvent['timeStamp']))
                              .millisecondsSinceEpoch *
                          1000)
                  .millisecondsSinceEpoch,
              'value': transferEvent['value'],
              'tokenAddress': transferEvent['contractAddress'],
              'type': type,
            });
          }
        }
        return transfers;
      } else {
        return [];
      }
    } catch (e) {
      throw 'Error! Get transactions failed for - address: $address --- $e';
    }
  }

  Future<List<dynamic>> getTransferEventsByAccountAddress(String address,
      {String sort = 'desc', int startblock = 0}) async {
    try {
      Map<String, dynamic> resp = await _get(
          '?module=account&action=tokentx&address=$address&startblock=$startblock&sort=$sort');
      if (resp['message'] == 'OK' && resp['status'] == '1') {
        List transfers = [];
        for (dynamic transferEvent in resp['result']) {
          String type;
          if (transferEvent["to"].toString().toLowerCase() ==
              getCurrentEnvironment()
                  .contracts['Hermez']
                  .toString()
                  .toLowerCase()) {
            type = 'WITHDRAW';
          } else if (transferEvent["from"].toString().toLowerCase() ==
              getCurrentEnvironment()
                  .contracts['Hermez']
                  .toString()
                  .toLowerCase()) {
            type = 'DEPOSIT';
          } else if (transferEvent["from"].toString().toLowerCase() ==
              address.toLowerCase()) {
            type = 'SEND';
          } else if (transferEvent["to"].toString().toLowerCase() ==
              address.toLowerCase()) {
            type = 'RECEIVE';
          }
          transfers.add({
            'blockNumber': num.parse(transferEvent['blockNumber']),
            'txHash': transferEvent['hash'],
            'to': transferEvent['to'],
            'from': transferEvent["from"],
            'status': "CONFIRMED",
            'timestamp': DateTime.fromMillisecondsSinceEpoch(
                    DateTime.fromMillisecondsSinceEpoch(
                                int.parse(transferEvent['timeStamp']))
                            .millisecondsSinceEpoch *
                        1000)
                .millisecondsSinceEpoch,
            'value': transferEvent['value'],
            'tokenAddress': transferEvent['contractAddress'],
            'type': type,
          });
        }
        return transfers;
      } else {
        return [];
      }
    } catch (e) {
      throw 'Error! Get token transfers events failed for - address: $address --- $e';
    }
  }

  Future<BigInt> getTokenBalanceByAccountAddress(
    String tokenAddress,
    String accountAddress,
  ) async {
    try {
      Map<String, dynamic> resp = await _get(
          '?module=account&action=tokenbalance&contractaddress=$tokenAddress&address=$accountAddress');
      return BigInt.from(num.parse(resp['result']));
    } catch (e) {
      throw 'Error! Get token balance failed for - accountAddress: $accountAddress --- $e';
    }
  }

  Future<Map<String, dynamic>> getTokenInfo(String tokenAddress) async {
    try {
      Map<String, dynamic> resp = await _get(
          '?module=token&action=getToken&contractaddress=$tokenAddress');
      if (resp['message'] == 'OK' && resp['status'] == '1') {
        return Map.from({
          ...resp['result'],
          'decimals': int.parse(resp['result']['decimals'])
        });
      }
      return Map();
    } catch (e) {
      throw 'Error! Get token failed $tokenAddress - $e';
    }
  }

  // TODO DEPRECATED??
  Future<List<dynamic>> getListOfTokensByAddress(String address) async {
    try {
      Map<String, dynamic> resp =
          await _get('?module=account&action=tokenlist&address=$address');
      if (resp['message'] == 'OK' && resp['status'] == '1') {
        List tokens = [];
        for (dynamic token in resp['result']) {
          tokens.add({
            "amount": token['balance'],
            "originNetwork": 'mainnet',
            "address": token['contractAddress'].toLowerCase(),
            "decimals": int.parse(token['decimals']),
            "name": token['name'],
            "symbol": token['symbol']
          });
        }
        return tokens;
      } else {
        return [];
      }
    } catch (e) {
      throw 'Error! Get token list failed for - address: $address --- $e';
    }
  }

  Future<Map<String, dynamic>> _get(String endpoint) async {
    Response response;
    if ([null, ''].contains(_apiKey)) {
      response = await _client.get('$_base$endpoint');
    } else {
      response = await _client.get('$_base$endpoint&apikey=$_apiKey');
    }
    return responseHandler(response);
  }

  Map<String, dynamic> responseHandler(Response response) {
    print('response: ${response.statusCode}, ${response.reasonPhrase}');
    switch (response.statusCode) {
      case 200:
        Map<String, dynamic> obj = json.decode(response.body);
        return obj;
      case 401:
        throw 'Error! Unauthorized';
        break;
      default:
        throw 'Error! status: ${response.statusCode}, reason: ${response.reasonPhrase}';
    }
  }
}
