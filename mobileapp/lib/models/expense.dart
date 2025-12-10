class Expense {
  final int? id;
  final int? siteId;
  final int? categoryId;
  final String amount;
  final String date;
  final String? description;
  final String? paidTo;
  final String? paymentMethod;
  final String? receiptNumber;
  final String? createdAt;
  final String? updatedAt;

  Expense({
    this.id,
    this.siteId,
    this.categoryId,
    required this.amount,
    required this.date,
    this.description,
    this.paidTo,
    this.paymentMethod,
    this.receiptNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      siteId: json['siteId'],
      categoryId: json['categoryId'],
      amount: json['amount']?.toString() ?? '0',
      date: json['date'] ?? '',
      description: json['description'],
      paidTo: json['paidTo'],
      paymentMethod: json['paymentMethod'],
      receiptNumber: json['receiptNumber'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (siteId != null) 'siteId': siteId,
      if (categoryId != null) 'categoryId': categoryId,
      'amount': amount,
      'date': date,
      if (description != null) 'description': description,
      if (paidTo != null) 'paidTo': paidTo,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (receiptNumber != null) 'receiptNumber': receiptNumber,
    };
  }
}
