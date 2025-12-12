class Payable {
  final int id;
  final String type; // Always 'Advance Payment'
  final int clientId;
  final int miningSiteId;
  final DateTime date;
  final String? description;
  final double totalAmount;
  final double remainingBalance;
  final String status; // 'Active', 'Partially Used', 'Fully Used'
  final List<String>? proof;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? createdById;
  final int? modifiedById;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? miningSite;

  Payable({
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
    this.createdById,
    this.modifiedById,
    this.client,
    this.miningSite,
  });

  factory Payable.fromJson(Map<String, dynamic> json) {
    return Payable(
      id: json['id'] as int,
      type: json['type'] as String,
      clientId: json['clientId'] as int,
      miningSiteId: json['miningSiteId'] as int,
      date: DateTime.parse(json['date']),
      description: json['description'] as String?,
      totalAmount: double.parse(json['totalAmount'].toString()),
      remainingBalance: double.parse(json['remainingBalance'].toString()),
      status: json['status'] as String,
      proof: json['proof'] != null ? List<String>.from(json['proof']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'] as int? ?? 0,
      modifiedById: json['modifiedById'] as int?,
      client: json['client'] as Map<String, dynamic>?,
      miningSite: json['miningSite'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'Advance Payment',
      'clientId': clientId,
      'miningSiteId': miningSiteId,
      'date': date.toIso8601String().split('T')[0],
      'description': description,
      'totalAmount': totalAmount,
      'proof': proof,
    };
  }

  bool get isActive => status == 'Active';
  bool get isPartiallyUsed => status == 'Partially Used';
  bool get isFullyUsed => status == 'Fully Used';
}
