class Payment {
  final int id;
  final int clientId;
  final int miningSiteId;
  final String paymentType; // 'Payable Deduction' or 'Receivable Payment'
  final double amount;
  final DateTime paymentDate;
  final String? paymentMethod;
  final List<String>? proof;
  final String? receivedBy;
  final String? notes;
  final DateTime createdAt;
  final int? createdBy;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? miningSite;
  final Map<String, dynamic>? creator;

  Payment({
    required this.id,
    required this.clientId,
    required this.miningSiteId,
    required this.paymentType,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.proof,
    this.receivedBy,
    this.notes,
    required this.createdAt,
    this.createdBy,
    this.client,
    this.miningSite,
    this.creator,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      clientId: json['clientId'] as int,
      miningSiteId: json['miningSiteId'] as int,
      paymentType: json['paymentType'] as String,
      amount: double.parse(json['amount'].toString()),
      paymentDate: DateTime.parse(json['paymentDate']),
      paymentMethod: json['paymentMethod'] as String?,
      proof: json['proof'] != null ? List<String>.from(json['proof']) : null,
      receivedBy: json['receivedBy'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'] as int?,
      client: json['client'] as Map<String, dynamic>?,
      miningSite: json['miningSite'] as Map<String, dynamic>?,
      creator: json['creator'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'miningSiteId': miningSiteId,
      'paymentType': paymentType,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String().split('T')[0],
      'paymentMethod': paymentMethod,
      'proof': proof,
      'receivedBy': receivedBy,
      'notes': notes,
    };
  }

  bool get isPayableDeduction => paymentType == 'Payable Deduction';
  bool get isReceivablePayment => paymentType == 'Receivable Payment';
  
  String get clientName => client?['businessName'] ?? 'Unknown Client';
  String get siteName => miningSite?['name'] ?? 'Unknown Site';
  String get creatorName => creator?['fullName'] ?? 'Unknown';
}
