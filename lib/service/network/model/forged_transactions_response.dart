import 'package:hermez/service/network/model/forged_transaction.dart';
import 'package:hermez/service/network/model/pagination.dart';

class ForgedTransactionsResponse {
  final List<ForgedTransaction> transactions;
  final Pagination pagination;

  ForgedTransactionsResponse({this.transactions, this.pagination});

  factory ForgedTransactionsResponse.fromJson(Map<String, dynamic> json) {
    return ForgedTransactionsResponse(
        transactions: json['transactions'], pagination: json['pagination']);
  }

  Map<String, dynamic> toJson() => {
        'transactions': transactions,
        'pagination': pagination,
      };
}
