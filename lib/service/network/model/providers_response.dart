import 'package:hermez/service/network/model/pay_provider.dart';

class ProvidersResponse {
  final List<PayProvider> providers;

  ProvidersResponse({this.providers});

  factory ProvidersResponse.fromJson(List<dynamic> json) {
    if (json != null) {
      List<PayProvider> providers =
          json.map((item) => PayProvider.fromJson(item)).toList();
      return ProvidersResponse(
        providers: providers,
      );
    } else {
      return ProvidersResponse();
    }
  }

  Map<String, dynamic> toJson() => {
        'providers': providers,
      };
}
