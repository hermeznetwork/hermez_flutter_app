class RegisterRequest {
  final String timestamp;
  final String ethAddr;
  final String bjj;
  final String signature;

  RegisterRequest({this.timestamp, this.ethAddr, this.bjj, this.signature});

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
        timestamp: json['timestamp'],
        ethAddr: json['ethAddr'],
        bjj: json['bjj'],
        signature: json['signature']);
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'ethAddr': ethAddr,
    'bjj': bjj,
    'signature': signature,
  };

}
