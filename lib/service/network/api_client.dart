library api_testing_flutter_kata;

import 'dart:convert';
import 'dart:io';

import 'package:hermez/service/network/api_client_exceptions.dart';
import 'package:hermez/service/network/model/account.dart';
import 'package:hermez/service/network/model/accounts_response.dart';
import 'package:hermez/service/network/model/coordinators_response.dart';
import 'package:hermez/service/network/model/exits_request.dart';
import 'package:hermez/service/network/model/forged_transactions_request.dart';
import 'package:hermez/service/network/model/forged_transactions_response.dart';
import 'package:hermez/service/network/model/register_request.dart';
import 'package:hermez/service/network/model/tokens_request.dart';
import 'package:hermez/service/network/model/tokens_response.dart';
import 'package:http/http.dart' as http;

import 'model/accounts_request.dart';
import 'model/coordinator.dart';
import 'model/coordinators_request.dart';
import 'model/exit.dart';
import 'model/exits_response.dart';
import 'model/forged_transaction.dart';
import 'model/recommended_fees.dart';
import 'model/token.dart';
import 'model/transaction.dart';

class ApiClient {
  final String _baseAddress;

  final String REGISTER_AUTH_URL = "/account-creation-authorization";
  final String ACCOUNTS_URL = "/accounts/";
  final String EXITS_URL = "/exits/";

  final String TRANSACTIONS_POOL_URL = "/transactions-pool";
  final String TRANSACTIONS_HISTORY_URL = "/transactions-history";

  final String TOKENS_URL = "/tokens";
  final String RECOMMENDED_FEES_URL = "/recommendedFee";
  final String COORDINATORS_URL = "/coordinators";

  ApiClient(this._baseAddress);

  // ACCOUNT

  Future<bool> authorizeAccountCreation(RegisterRequest request) async {
    final response = await _post(REGISTER_AUTH_URL, request.toJson());
    return response.statusCode == 200;
  }

  Future<bool> getCreationAuthorization(String hermezEthereumAddress) async {
    final response =
        await _get(REGISTER_AUTH_URL + '/' + hermezEthereumAddress, null);
    return response.statusCode == 200;
  }

  Future<List<Account>> getAccounts(AccountsRequest request) async {
    final response =
        await _get(ACCOUNTS_URL + request.hermezEthereumAddress, null);
    final AccountsResponse accountsResponse =
        AccountsResponse.fromJson(json.decode(response.body));
    return accountsResponse.accounts;
  }

  Future<List<Exit>> getExits(ExitsRequest request) async {
    final response = await _get(
        EXITS_URL + request.hermezEthereumAddress, request.toQueryParams());
    final ExitsResponse exitsResponse =
        ExitsResponse.fromJson(json.decode(response.body));
    return exitsResponse.exits;
  }

  // TRANSACTION

  Future<bool> sendL2Transaction(Transaction transaction) async {
    final response = await _post(TRANSACTIONS_POOL_URL, transaction.toJson());
    return response.statusCode == 200;
  }

  // Get historical transactions. This endpoint will return all the different types
  // of transactions except for:

  // Transactions that are still in the transaction pool of any coordinator.
  // This transactions can be fetched using GET /transactions-pool/{id}.

  // L1 transactions that have not been forged yet. This transactions can be fetched
  // using GET /transactions-history/{id}.

  Future<List<ForgedTransaction>> getForgedTransactions(
      ForgedTransactionsRequest request) async {
    final response = await _get(TRANSACTIONS_HISTORY_URL, request.toJson());
    final ForgedTransactionsResponse forgedTransactionsResponse =
        ForgedTransactionsResponse.fromJson(json.decode(response.body));
    return forgedTransactionsResponse.transactions;
  }

  Future<ForgedTransaction> getTransactionById(String transactionId) async {
    final response =
        await _get(TRANSACTIONS_HISTORY_URL + '/' + transactionId, null);
    final ForgedTransaction forgedtransaction =
        ForgedTransaction.fromJson(json.decode(response.body));
    return forgedtransaction;
  }

  // Get transaction by id. This endpoint is specially useful for tracking the status of
  // a transaction that may not be forged yet. Only transactions from the pool will be
  // returned. Note that the transaction pool is different for each coordinator and
  // therefore only a coordinator that has received a specific transaction will be able
  // to provide information about that transaction.

  Future<Transaction> getPoolTransactionById(String transactionId) async {
    final response =
        await _get(TRANSACTIONS_POOL_URL + '/' + transactionId, null);
    final Transaction transaction =
        Transaction.fromJson(json.decode(response.body));
    return transaction;
  }

  // HERMEZ

  Future<List<Token>> getSupportedTokens(TokensRequest request) async {
    final response =
        await _get(TOKENS_URL, request != null ? request.toJson() : null);
    final TokensResponse tokensResponse =
        TokensResponse.fromJson(json.decode(response.body));
    return tokensResponse.tokens;
  }

  Future<Token> getSupportedTokenById(String tokenId) async {
    final response = await _get(TOKENS_URL + '/' + tokenId, null);
    final tokenResponse = Token.fromJson(json.decode(response.body));
    return tokenResponse;
  }

  Future<RecommendedFees> getRecommendedFees() async {
    final response = await _get(RECOMMENDED_FEES_URL, null);
    final recommendedFees =
        RecommendedFees.fromJson(json.decode(response.body));
    return recommendedFees;
  }

  Future<List<Coordinator>> getCoordinators(CoordinatorsRequest request) async {
    final response = await _get(COORDINATORS_URL, request.toJson());
    final coordinatorsResponse =
        CoordinatorsResponse.fromJson(json.decode(response.body));
    return coordinatorsResponse.coordinators;
  }

  Future<Coordinator> getCoordinatorByAddr(String forgerAddr) async {
    final response = await _get(COORDINATORS_URL + '/' + forgerAddr, null);
    final coordinatorResponse =
        Coordinator.fromJson(json.decode(response.body));
    return coordinatorResponse;
  }

  /*Future<List<Task>> getAllTasks() async {
    final response = await _get('/todos');

    final decodedTasks = json.decode(response.body) as List;

    return decodedTasks.map((jsonTask) => Task.fromJson(jsonTask)).toList();
  }*/

  Future<http.Response> _get(
      String endpoint, Map<String, String> queryParameters) async {
    try {
      var uri;
      if (queryParameters != null) {
        uri = Uri.http(_baseAddress, endpoint, queryParameters);
      } else {
        uri = Uri.http(_baseAddress, endpoint);
      }
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException catch (e) {
      print(e.toString());
      throw NetworkException();
    }
  }

  Future<http.Response> _post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        '$_baseAddress$endpoint',
        body: json.encode(body),
        headers: {
          HttpHeaders.acceptHeader: '*/*',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException {
      throw NetworkException();
    }
  }

  Future<http.Response> _put(dynamic task) async {
    try {
      final response = await http.put(
        '$_baseAddress/todos/${task.id}',
        body: json.encode(task.toJson()),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException {
      throw NetworkException();
    }
  }

  Future<http.Response> _delete(String id) async {
    try {
      final response = await http.delete(
        '$_baseAddress/todos/$id',
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException {
      throw NetworkException();
    }
  }

  http.Response returnResponseOrThrowException(http.Response response) {
    if (response.statusCode == 404) {
      // Not found
      throw ItemNotFoundException();
    } else if (response.statusCode == 500) {
      throw InternalServerErrorException();
    } else if (response.statusCode > 400) {
      throw UnknownApiException(response.statusCode);
    } else {
      return response;
    }
  }

/*var apiClient =
                                new ApiClient("http://10.0.2.2:4010");
                            var params = {
                              "timestamp": "2020-09-08T14:19:19.128Z",
                              "ethereumAddress":
                                  "hez:0xaa942cfcd25ad4d90a62358b0dd84f33b398262a",
                              "bjj":
                                  "hez:HVrB8xQHAYt9QTpPUsj3RGOzDmrCI4IgrYslTeTqo6Ix",
                              "signature":
                                  "72024a43f546b0e1d9d5d7c4c30c259102a9726363adcc4ec7b6aea686bcb5116f485c5542d27c4092ae0ceaf38e3bb44417639bd2070a58ba1aa1aab9d92c03"
                            };
                            var request = RegisterRequest.fromJson(params);
                            bool result = await apiClient
                                .authorizeAccountCreation(request);

                            /*if (result) {
                    Navigator.of(context).pushNamed("/token_selector", arguments: TransactionType.SEND);
                  }*/
                            var params2 = {
                              "hermezEthereumAddress":
                                  "hez:0xaa942cfcd25ad4d90a62358b0dd84f33b398262a",
                            };
                            var request2 = AccountsRequest.fromJson(params2);
                            await apiClient.getAccounts(request2);*/
}
