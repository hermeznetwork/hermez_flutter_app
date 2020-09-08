class ExitsRequest {
  final String hermezEthereumAddress;
  final int offset;
  final int limit;

  ExitsRequest({this.hermezEthereumAddress, this.offset, this.limit});

  factory ExitsRequest.fromJson(Map<String, dynamic> json) {
    return ExitsRequest(
        hermezEthereumAddress: json['hermezEthereumAddress'],
        offset: json['offset'],
        limit: json['limit']);
  }

  Map<String, dynamic> toJson() => {
    'hermezEthereumAddress': hermezEthereumAddress,
    'offset': offset,
    'limit': limit,
  };

  Map<String, String> toQueryParams() => {
    'offset': offset.toString(),
    'limit': limit.toString(),
  };

}
