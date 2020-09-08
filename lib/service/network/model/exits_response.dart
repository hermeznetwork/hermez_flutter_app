import 'package:hermez/service/network/model/pagination.dart';

import 'exit.dart';

class ExitsResponse {
  final List<Exit> exits;
  final Pagination pagination;

  ExitsResponse({this.exits, this.pagination});

  factory ExitsResponse.fromJson(Map<String, dynamic> json) {
    return ExitsResponse(
        exits: json['exits'],
        pagination: json['pagination']);
  }

  Map<String, dynamic> toJson() => {
    'exits': exits,
    'pagination': pagination
  };

}
