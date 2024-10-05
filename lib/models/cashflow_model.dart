class CashflowModel {
  final int id;
  final int transactionId;
  final String type;
  final double amount;
  final double balance;
  final DateTime date;

  CashflowModel({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.balance,
    required this.date,
  });

  factory CashflowModel.fromJson(Map<String, dynamic> json) {
    return CashflowModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      type: json['type'],
      amount: json['amount'] != null ? double.parse(json['amount']) : 0.0,
      balance: json['balance'] != null ? double.parse(json['balance']) : 0.0,
      date: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
