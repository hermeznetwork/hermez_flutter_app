class CoordinatorsRequest {
  final int offset;
  final int limit;

  CoordinatorsRequest({this.offset, this.limit});

  factory CoordinatorsRequest.fromJson(Map<String, dynamic> json) {
    return CoordinatorsRequest(
        offset: json['offset'],
        limit: json['limit']);
  }

  Map<String, dynamic> toJson() => {
    'offset': offset,
    'limit': limit,
  };

}
