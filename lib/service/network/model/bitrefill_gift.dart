class BitrefillGift {
  final String recipientName;
  final String recipientEmail;
  final String delivery; // instant, scheduled
  final String timezoneOffset;
  final String senderName;
  final String message;
  final String theme; // bitcoin

  BitrefillGift(
      {this.recipientName,
      this.recipientEmail,
      this.delivery,
      this.timezoneOffset,
      this.senderName,
      this.message,
      this.theme});

  factory BitrefillGift.fromJson(Map<String, dynamic> json) {
    return BitrefillGift(
      recipientName: json['recipientName'],
      recipientEmail: json['recipientEmail'],
      delivery: json['delivery'],
      timezoneOffset: json['timezoneOffset'],
    );
  }

  Map<String, dynamic> toJson() => {
        'recipientName': recipientName,
        'recipientEmail': recipientEmail,
        'delivery': delivery,
        'timezoneOffset': timezoneOffset,
      };
}
