import 'package:hermez/service/network/model/purchase.dart';

class PurchasesResponse {
  final List<Purchase> purchases;

  PurchasesResponse({this.purchases});

  factory PurchasesResponse.fromJson(List<dynamic> json) {
    if (json != null) {
      List<Purchase> purchases =
          json.map((item) => Purchase.fromJson(item)).toList();
      return PurchasesResponse(
        purchases: purchases,
      );
    } else {
      return PurchasesResponse();
    }
  }

  Map<String, dynamic> toJson() => {
        'purchases': purchases,
      };
}
