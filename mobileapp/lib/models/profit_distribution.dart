class ProfitDistribution {
  final int id;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalRevenue;
  final double totalExpenses;
  final double totalProfit;
  final String status;
  final DateTime? approvedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfitDistribution({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalProfit,
    required this.status,
    this.approvedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfitDistribution.fromJson(Map<String, dynamic> json) {
    return ProfitDistribution(
      id: json['id'] as int,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalRevenue: double.tryParse(json['totalRevenue'].toString()) ?? 0.0,
      totalExpenses: double.tryParse(json['totalExpenses'].toString()) ?? 0.0,
      totalProfit: double.tryParse(json['totalProfit'].toString()) ?? 0.0,
      status: json['status'] as String,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodStart': periodStart.toIso8601String().split('T')[0],
      'periodEnd': periodEnd.toIso8601String().split('T')[0],
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'totalProfit': totalProfit,
      'status': status,
      if (approvedAt != null) 'approvedAt': approvedAt!.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
