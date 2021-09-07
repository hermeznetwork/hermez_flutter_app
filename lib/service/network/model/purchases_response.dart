import 'package:hermez/service/network/model/purchase_old.dart';

class PurchasesResponse {
  final List<PurchaseOld> purchases;

  PurchasesResponse({this.purchases});

  factory PurchasesResponse.fromJson(List<dynamic> json) {
    if (json != null) {
      List<PurchaseOld> purchases =
          json.map((item) => PurchaseOld.fromJson(item)).toList();
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
