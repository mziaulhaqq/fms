class Receivable {
  final int id;
  final int clientId;
  final int miningSiteId;
  final DateTime date;
  final String? description;
  final double totalAmount;
  final double remainingBalance;
  final String status; // 'Pending', 'Partially Paid', 'Fully Paid'
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? createdById;
  final int? modifiedById;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? miningSite;

  Receivable({
    required this.id,
    required this.clientId,
    required this.miningSiteId,
    required this.date,
    this.description,
    required this.totalAmount,
    required this.remainingBalance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.modifiedById,
    this.client,
    this.miningSite,
  });

  factory Receivable.fromJson(Map<String, dynamic> json) {
    return Receivable(
      id: json['id'] as int,
      clientId: json['clientId'] as int,
      miningSiteId: json['miningSiteId'] as int,
      date: DateTime.parse(json['date']),
      description: json['description'] as String?,
      totalAmount: double.parse(json['totalAmount'].toString()),
      remainingBalance: double.parse(json['remainingBalance'].toString()),
      status: json['status'] as String,
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
      'clientId': clientId,
      'miningSiteId': miningSiteId,
      'date': date.toIso8601String().split('T')[0],
      'description': description,
      'totalAmount': totalAmount,
    };
  }

  bool get isPending => status == 'Pending';
  bool get isPartiallyPaid => status == 'Partially Paid';
  bool get isFullyPaid => status == 'Fully Paid';
  
  String get clientName => client?['businessName'] ?? 'Unknown Client';
  String get siteName => miningSite?['name'] ?? 'Unknown Site';
}
