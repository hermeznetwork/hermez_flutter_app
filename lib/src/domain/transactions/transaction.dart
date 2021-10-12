import 'package:hermez_sdk/model/pool_transaction.dart';

enum TransactionLevel { LEVEL1, LEVEL2 }

enum TransactionType { DEPOSIT, SEND, RECEIVE, WITHDRAW, EXIT, FORCEEXIT }

enum TransactionStatus { DRAFT, PENDING, CONFIRMED, INVALID }

class Transaction {
  final String id;
  final String block;

  final TransactionLevel level;
  final TransactionStatus status;
  final TransactionType type;

  final String from;
  final String to;
  final String timestamp;

  final num amount;
  final num fee;
  final int tokenId;

  final num price;
  final String currency;

  Transaction({
    this.id,
    this.block,
    this.level,
    this.status,
    this.type,
    this.from,
    this.to,
    this.timestamp,
    this.amount,
    this.fee,
    this.tokenId,
    this.price,
    this.currency,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      currency: json['currency'],
      //baseCurrency: json['baseCurrency'],
      price: json['price'],
    );
  }

  factory Transaction.fromTransaction(PoolTransaction transaction) {
    //Token token = Token.fromJson(json['token']);
    //MerkleProof merkleProof = MerkleProof.fromJson(json['merkleProof']);
    return Transaction();
    /*return Exit(
      //batchNum: json['batchNum'],
      accountIndex: transaction!.fromAccountIndex,
      //itemId: transaction.id,
      //merkleProof: merkleProof,
      balance: transaction.amount,
      //instantWithdraw: json['instantWithdraw'],
      //delayedWithdrawRequest: json['delayedWithdrawRequest'],
      //delayedWithdraw: json['delayedWithdraw'],
      tokenId: transaction.token!.id,
      //bjj: json['bjj'],
      //hezEthereumAddress: json['hezEthereumAddress']
    );*/
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        //'baseCurrency': baseCurrency,
        'price': price,
      };
}
