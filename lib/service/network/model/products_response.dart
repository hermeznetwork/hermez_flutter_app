import 'package:hermez/service/network/model/pay_product.dart';

class ProductsResponse {
  final List<PayProduct> products;

  ProductsResponse({this.products});

  factory ProductsResponse.fromJson(List<dynamic> json) {
    if (json != null) {
      List<PayProduct> products =
          json.map((item) => PayProduct.fromJson(item)).toList();
      return ProductsResponse(
        products: products,
      );
    } else {
      return ProductsResponse();
    }
  }

  Map<String, dynamic> toJson() => {
        'products': products,
      };
}
