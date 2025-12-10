class Expense {
  final int? id;
  final int siteId;
  final int? categoryId;
  final String expenseDate;
  final double amount;
  final String? notes;
  final int? laborCostId;
  final String? createdAt;
  final String? updatedAt;

  // Navigation properties (for display)
  final String? siteName;
  final String? categoryName;

  Expense({
    this.id,
    required this.siteId,
    this.categoryId,
    required this.expenseDate,
    required this.amount,
    this.notes,
    this.laborCostId,
    this.createdAt,
    this.updatedAt,
    this.siteName,
    this.categoryName,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      siteId: json['siteId'] ?? json['site_id'] ?? 0,
      categoryId: json['categoryId'] ?? json['category_id'],
      expenseDate: json['expenseDate'] ?? json['expense_date'] ?? '',
      amount: _parseAmount(json['amount']),
      notes: json['notes'],
      laborCostId: json['laborCostId'] ?? json['labor_cost_id'],
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
      siteName: json['site']?['name'] ?? json['siteName'],
      categoryName: json['category']?['name'] ?? json['categoryName'],
    );
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'siteId': siteId,
      if (categoryId != null) 'categoryId': categoryId,
      'expenseDate': expenseDate,
      'amount': amount,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (laborCostId != null) 'laborCostId': laborCostId,
    };
  }

  Map<String, dynamic> toJsonRequest() {
    return {
      'siteId': siteId,
      if (categoryId != null) 'categoryId': categoryId,
      'expenseDate': expenseDate,
      'amount': amount,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (laborCostId != null) 'laborCostId': laborCostId,
    };
  }
}
