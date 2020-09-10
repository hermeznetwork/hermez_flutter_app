class Coordinator {
  final String forgerAddr;
  final String withdrawAddr;
  final String URL;

  Coordinator({this.forgerAddr, this.withdrawAddr, this.URL});

  factory Coordinator.fromJson(Map<String, dynamic> json) {
    return Coordinator(
      forgerAddr: json['forgerAddr'],
      withdrawAddr: json['withdrawAddr'],
      URL: json['URL'],
    );
  }

  Map<String, dynamic> toJson() => {
    'forgerAddr': forgerAddr,
    'withdrawAddr': withdrawAddr,
    'URL': URL,
  };

}
