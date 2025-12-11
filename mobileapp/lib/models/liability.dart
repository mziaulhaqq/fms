class Liability {
  final int id;
  final String type; // 'Loan' or 'Advanced Payment'
  final int clientId;
  final int miningSiteId;
  final DateTime date;
  final String? description;
  final double totalAmount;
  final double remainingBalance;
  final String status; // 'Active', 'Partially Settled', 'Fully Settled'
  final List<String>? proof;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int createdById;
  final int? modifiedById;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? miningSite;

  Liability({
    required this.id,
    required this.type,
    required this.clientId,
    required this.miningSiteId,
    required this.date,
    this.description,
    required this.totalAmount,
    required this.remainingBalance,
    required this.status,
    this.proof,
    required this.createdAt,
    required this.updatedAt,
    required this.createdById,
    this.modifiedById,
    this.client,
    this.miningSite,
  });

  factory Liability.fromJson(Map<String, dynamic> json) {
    return Liability(
      id: json['id'],
      type: json['type'],
      clientId: json['clientId'],
      miningSiteId: json['miningSiteId'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      totalAmount: double.parse(json['totalAmount'].toString()),
      remainingBalance: double.parse(json['remainingBalance'].toString()),
      status: json['status'],
      proof: json['proof'] != null ? List<String>.from(json['proof']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'],
      modifiedById: json['modifiedById'],
      client: json['client'],
      miningSite: json['miningSite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'clientId': clientId,
      'miningSiteId': miningSiteId,
      'date': date.toIso8601String().split('T')[0],
      'description': description,
      'totalAmount': totalAmount,
      'proof': proof,
    };
  }

  bool get isActive => status == 'Active';
  bool get isPartiallySettled => status == 'Partially Settled';
  bool get isFullySettled => status == 'Fully Settled';
  bool get isLoan => type == 'Loan';
  bool get isAdvancedPayment => type == 'Advanced Payment';
}
