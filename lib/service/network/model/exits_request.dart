class ExitsRequest {
  final String hermezEthereumAddress;
  final bool onlyPendingWithdraws;

  ExitsRequest({this.hermezEthereumAddress, this.onlyPendingWithdraws});

  factory ExitsRequest.fromJson(Map<String, dynamic> json) {
    return ExitsRequest(
      hermezEthereumAddress: json['hermezEthereumAddress'],
      onlyPendingWithdraws: json['onlyPendingWithdraws'],
    );
  }

  Map<String, dynamic> toJson() => {
        'hermezEthereumAddress': hermezEthereumAddress,
        'onlyPendingWithdraws': onlyPendingWithdraws,
      };
}
