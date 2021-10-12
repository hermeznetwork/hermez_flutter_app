import 'dart:async';
import 'dart:convert';

import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez_sdk/environment.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

typedef TransferEvent = void Function(
    EthereumAddress from, EthereumAddress to, BigInt value);

abstract class IExplorerService {
  Future<List<dynamic>> getTransactionsByAccountAddress(String address,
      {String sort = 'desc', int startblock = 0});
  Future<List<dynamic>> getTokenTransferEventsByAccountAddress(
      String address, String tokenAddress,
      {String sort = 'desc', int startblock = 0});
  Future<BigInt> getTokenBalanceByAccountAddress(
      String tokenAddress, String accountAddress);
  // TODO UNUSED
  Future<Map<String, dynamic>> getTokenInfo(String tokenAddress);
  // TODO DEPRECATED??
  Future<List<dynamic>> getListOfTokensByAddress(String address);
  Future<void> getBlockAvgTime({String sort = 'desc'});
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

  Future<List<dynamic>> getTransactionsByAccountAddress(String address,
      {String sort = 'desc', int startblock = 0}) async {
    try {
      Map<String, dynamic> resp = await _get(
          '?module=account&action=txlist&address=$address&startblock=$startblock&sort=$sort');
      if (resp['message'] == 'OK' && resp['status'] == '1') {
        List transfers = [];
        for (dynamic transferEvent in resp['result']) {
          bool addTransfer = true;
          if (transferEvent['contractAddress'] == "") {
            String type;
            dynamic value = transferEvent['value'];
            if (transferEvent["to"].toString().toLowerCase() ==
                getCurrentEnvironment()
                    .contracts['Hermez']
                    .toString()
                    .toLowerCase()) {
              List<dynamic> decodedInput = decodeCall(transferEvent["input"]);
              if (decodedInput.length > 2) {
                type = 'DEPOSIT';
                if ((decodedInput[4] as BigInt).toInt() != 0) {
                  addTransfer = false;
                }
              } else {
                type = 'WITHDRAW';
                if ((decodedInput[0] as BigInt).toInt() != 0) {
                  addTransfer = false;
                }
                value = (decodedInput[1] as BigInt).toInt().toString();
              }
            } else if (transferEvent["from"].toString().toLowerCase() ==
                address.toLowerCase()) {
              type = 'SEND';
              if (transferEvent['value'] == '0') {
                addTransfer = false;
              }
            } else if (transferEvent["to"].toString().toLowerCase() ==
                address.toLowerCase()) {
              type = 'RECEIVE';
            }
            if (addTransfer) {
              transfers.add({
                'blockNumber': num.parse(transferEvent['blockNumber']),
                'txHash': transferEvent['hash'],
                'to': transferEvent['to'],
                'from': transferEvent["from"],
                'status':
                    transferEvent["isError"] == "0" ? "CONFIRMED" : "INVALID",
                'timestamp': DateTime.fromMillisecondsSinceEpoch(
                        DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(transferEvent['timeStamp']))
                                .millisecondsSinceEpoch *
                            1000)
                    .millisecondsSinceEpoch,
                'value': value,
                'fee': (int.parse(transferEvent['gasUsed']) *
                        int.parse(transferEvent['gasPrice']))
                    .toString(),
                'tokenAddress': transferEvent['contractAddress'],
                'type': type,
              });
            }
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

  List<dynamic> decodeCall(String data) {
    String method = data.substring(0, 10);
    TransactionType type;
    if (method == "0xd9d4ca44") {
      type = TransactionType.WITHDRAW;
    } else if (method == "0xc7273053") {
      type = TransactionType.DEPOSIT;
    }
    String noMethodData = '0x' + data.substring(10);
    List<AbiType> list = [];
    if (type == TransactionType.WITHDRAW) {
      list = [
        UintType(length: 32),
        UintType(length: 192),
      ];
    } else if (type == TransactionType.DEPOSIT) {
      list = [
        UintType(),
        UintType(length: 48),
        UintType(length: 40),
        UintType(length: 40),
        UintType(length: 32)
      ];
    }

    final buffer = hexToBytes(noMethodData).buffer;
    dynamic tuple = TupleType(list);
    final parsedData = tuple.decode(buffer, 0);
    return parsedData.data;
  }

  Future<List<dynamic>> getTokenTransferEventsByAccountAddress(
      String address, String tokenAddress,
      {int tokenId = -1, String sort = 'desc', int startblock = 0}) async {
    try {
      Map<String, dynamic> resp = await _get(
          '?module=account&action=tokentx&contractaddress=$tokenAddress&address=$address&startblock=$startblock&sort=$sort');
      if (resp['message'] == 'OK' && resp['status'] == '1') {
        List transfers = [];
        for (dynamic transferEvent in resp['result']) {
          String type;
          if (transferEvent["from"].toString().toLowerCase() ==
              getCurrentEnvironment()
                  .contracts['Hermez']
                  .toString()
                  .toLowerCase()) {
            type = 'WITHDRAW';
          } else if (transferEvent["to"].toString().toLowerCase() ==
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
            'fee': (int.parse(transferEvent['gasUsed']) *
                    int.parse(transferEvent['gasPrice']))
                .toString(),
            'tokenId': tokenId,
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

  // TODO UNUSED
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

  Future<void> getBlockAvgTime({String sort = 'desc'}) async {
    String startdate = "2021-06-09";
    String enddate = "2021-06-10";
    try {
      Map<String, dynamic> resp = await _get(
          '?module=stats&action=dailyavgblocktime&startdate=$startdate&enddate=$enddate&sort=$sort');
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
    } catch (e) {}
  }

  Future<Map<String, dynamic>> _get(String endpoint) async {
    Response response;
    if ([null, ''].contains(_apiKey)) {
      var url = Uri.parse('$_base$endpoint');
      response = await _client.get(url);
    } else {
      var url = Uri.parse('$_base$endpoint&apikey=$_apiKey');
      response = await _client.get(url);
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
