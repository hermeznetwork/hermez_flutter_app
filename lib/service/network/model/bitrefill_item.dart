import 'bitrefill_gift.dart';

class BitrefillItem {
  final String id;
  final String slug;
  final String recipient;
  final num value;
  final int amount;
  final String currency;
  final BitrefillGift giftInfo;

  BitrefillItem(
      {this.id,
      this.slug,
      this.recipient,
      this.value,
      this.amount,
      this.currency,
      this.giftInfo});

  factory BitrefillItem.fromJson(Map<String, dynamic> json) {
    BitrefillGift giftInfo = BitrefillGift.fromJson(json['giftInfo']);
    return BitrefillItem(
      id: json['id'],
      slug: json['slug'],
      recipient: json['recipient'],
      value: json['value'],
      amount: json['amount'],
      currency: json['currency'],
      giftInfo: giftInfo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'recipient': recipient,
        'value': value,
        'amount': amount,
        'currency': currency,
        'giftInfo': giftInfo.toJson(),
      };
}
