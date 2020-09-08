class RegisterRequest {
  final String timestamp;
  final String ethereumAddress;
  final String bjj;
  final String signature;

  RegisterRequest({this.timestamp, this.ethereumAddress, this.bjj, this.signature});

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
        timestamp: json['timestamp'],
        ethereumAddress: json['ethereumAddress'],
        bjj: json['bjj'],
        signature: json['signature']);
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'ethereumAddress': ethereumAddress,
    'bjj': bjj,
    'signature': signature,
  };

}
