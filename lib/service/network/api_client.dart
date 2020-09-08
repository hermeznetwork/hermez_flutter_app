library api_testing_flutter_kata;

import 'dart:convert';
import 'dart:io';

import 'package:hermez/service/network/api_client_exceptions.dart';
import 'package:hermez/service/network/model/account.dart';
import 'package:hermez/service/network/model/accounts_response.dart';
import 'package:hermez/service/network/model/exits_request.dart';
import 'package:hermez/service/network/model/register_request.dart';
import 'package:http/http.dart' as http;

import 'model/accounts_request.dart';
import 'model/exit.dart';
import 'model/exits_response.dart';

class ApiClient {
  final String _baseAddress;

  final String REGISTER_AUTH_URL = "/account-creation-authorization";
  final String ACCOUNTS_URL = "/accounts/";
  final String EXITS_URL = "/exits/";

  ApiClient(this._baseAddress);

  Future<bool> authorizeAccountCreation(RegisterRequest request) async {
    final response = await _post(REGISTER_AUTH_URL, request.toJson());
    return response.statusCode == 200;
  }

  Future<bool> getCreationAuthorization(String hermezEthereumAddress) async {
    final response = await _get(REGISTER_AUTH_URL + '/' + hermezEthereumAddress, null);
    return response.statusCode == 200;
  }

  Future<List<Account>> getAccounts(AccountsRequest request) async {
    final response = await _get(ACCOUNTS_URL + request.hermezEthereumAddress, null);
    final AccountsResponse accountsResponse = AccountsResponse.fromJson(json.decode(response.body));
    return accountsResponse.accounts;
  }

  Future<List<Exit>> getExits(ExitsRequest request) async {
    final response = await _get(EXITS_URL + request.hermezEthereumAddress, request.toQueryParams());
    final ExitsResponse exitsResponse = ExitsResponse.fromJson(json.decode(response.body));
    return exitsResponse.exits;
  }


  /*Future<List<Task>> getAllTasks() async {
    final response = await _get('/todos');

    final decodedTasks = json.decode(response.body) as List;

    return decodedTasks.map((jsonTask) => Task.fromJson(jsonTask)).toList();
  }

  Future<Task> getTasksById(String id) async {
    final response = await _get('/todos/$id');

    return Task.fromJson(json.decode(response.body));
  }

  Future<Task> addTask(Task task) async {
    final response = await _post(task);

    return Task.fromJson(json.decode(response.body));
  }

  Future<Task> updateTask(Task task) async {
    final response = await _put(task);

    return Task.fromJson(json.decode(response.body));
  }

  Future<void> deleteTaskById(String id) async {
    await _delete(id);
  }*/

  Future<http.Response> _get(String endpoint, Map<String, String> queryParameters) async {
    try {
      var uri;
      if (queryParameters != null) {
        uri = Uri.http("10.0.2.2:4010", endpoint, queryParameters);
      } else {
        uri = Uri.http("10.0.2.2:4010", endpoint);
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

  Future<http.Response> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        '$_baseAddress$endpoint',
        body: json.encode(body) ,
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
        body: json.encode(task.toJson()) ,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException  {
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
    } on IOException  {
      throw NetworkException();
    }
  }

  http.Response returnResponseOrThrowException(http.Response response) {
    if (response.statusCode == 404) { // Not found
      throw ItemNotFoundException();
    } else if (response.statusCode == 500) {
      throw InternalServerErrorException();
    } else if (response.statusCode > 400) {
      throw UnknownApiException(response.statusCode);
    } else {
      return response;
    }
  }
}
