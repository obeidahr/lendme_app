import 'dart:ui';

class Request {
  String id = '';
  String borrower = '';
  String lender = '';
  String desc = '';
  BigInt paybackTimestamp = BigInt.zero;
  BigInt amount = BigInt.zero;

  Request(
      {required this.borrower,
      required this.lender,
      required this.desc,
      required this.paybackTimestamp,
      required this.amount});

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    borrower = json['borrower'];
    lender = json['lender'];
    desc = json['desc'];
    paybackTimestamp = BigInt.parse(json['paybackTimestamp']);
    amount = BigInt.parse(json['amount']);
  }

  @override
  bool operator ==(other) => other is Request && id == other.id;

  @override
  int get hashCode =>
      hashValues(id, borrower, lender, desc, paybackTimestamp, amount);
}
