import 'bitrefill_gift.dart';

class BitrefillItem {
  final String id;
  final String name;
  final String baseName;
  final String slug;
  final String iconImage;
  final String iconVersion;
  final String recipient;
  final num value;
  final String displayValue;
  final int amount;
  final String currency;

  final BitrefillGift giftInfo;

  BitrefillItem(
      {this.id,
      this.name,
      this.baseName,
      this.slug,
      this.iconImage,
      this.iconVersion,
      this.recipient,
      this.value,
      this.displayValue,
      this.amount,
      this.currency,
      this.giftInfo});

  factory BitrefillItem.fromJson(Map<String, dynamic> json) {
    BitrefillGift giftInfo = BitrefillGift.fromJson(json['giftInfo']);
    return BitrefillItem(
      id: json['id'],
      name: json['name'],
      baseName: json['baseName'],
      slug: json['slug'],
      iconImage: json['iconImage'],
      iconVersion: json['iconVersion'],
      recipient: json['recipient'],
      value: json['value'],
      displayValue: json['displayValue'],
      amount: json['amount'],
      currency: json['currency'],
      giftInfo: giftInfo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseName': baseName,
        'slug': slug,
        'iconImage': iconImage,
        'iconVersion': iconVersion,
        'recipient': recipient,
        'value': value,
        'displayValue': displayValue,
        'amount': amount,
        'currency': currency,
        'giftInfo': giftInfo.toJson(),
      };
}
