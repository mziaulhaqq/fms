class GeneralLedger {
  final int id;
  final String accountCode;
  final String accountName;
  final int accountTypeId;
  final int miningSiteId;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int createdById;
  final int? modifiedById;
  final Map<String, dynamic>? accountType;
  final Map<String, dynamic>? miningSite;

  GeneralLedger({
    required this.id,
    required this.accountCode,
    required this.accountName,
    required this.accountTypeId,
    required this.miningSiteId,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdById,
    this.modifiedById,
    this.accountType,
    this.miningSite,
  });

  factory GeneralLedger.fromJson(Map<String, dynamic> json) {
    return GeneralLedger(
      id: json['id'],
      accountCode: json['accountCode'],
      accountName: json['accountName'],
      accountTypeId: json['accountTypeId'],
      miningSiteId: json['miningSiteId'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'],
      modifiedById: json['modifiedById'],
      accountType: json['accountType'],
      miningSite: json['miningSite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountCode': accountCode,
      'accountName': accountName,
      'accountTypeId': accountTypeId,
      'miningSiteId': miningSiteId,
      'description': description,
      'isActive': isActive,
    };
  }
}
