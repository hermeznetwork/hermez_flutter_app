import 'bitrefill_gift.dart';

class BitrefillItem {
  final String id;
  final String slug;
  final String recipient;
  final num value;
  final int amount;
  final BitrefillGift giftInfo;

  BitrefillItem(
      {this.id,
      this.slug,
      this.recipient,
      this.value,
      this.amount,
      this.giftInfo});

  factory BitrefillItem.fromJson(Map<String, dynamic> json) {
    BitrefillGift giftInfo = BitrefillGift.fromJson(json['giftInfo']);
    return BitrefillItem(
      id: json['id'],
      slug: json['slug'],
      recipient: json['recipient'],
      value: json['value'],
      amount: json['amount'],
      giftInfo: giftInfo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'recipient': recipient,
        'value': value,
        'amount': amount,
        'giftInfo': giftInfo.toJson(),
      };
}
