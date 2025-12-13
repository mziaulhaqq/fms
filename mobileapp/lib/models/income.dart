class Income {
  final int? id;
  final int siteId;
  final int? clientId;
  final String truckNumber;
  final String loadingDate;
  final String driverName;
  final String? driverPhone;
  final double coalPrice;
  final double companyCommission;
  final String? destinationFactory;
  final double? netAmount;
  final String? paymentStatus;
  final int? liabilityId;
  final double? amountFromLiability;
  final double? amountCash;
  final int? receivableId;
  final int? createdBy;
  final int? modifiedBy;
  final String? createdAt;
  final String? updatedAt;

  // Navigation properties
  final String? siteName;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? liability;
  final Map<String, dynamic>? receivable;
  final Map<String, dynamic>? creator;
  final Map<String, dynamic>? modifier;

  Income({
    this.id,
    required this.siteId,
    this.clientId,
    required this.truckNumber,
    required this.loadingDate,
    required this.driverName,
    this.driverPhone,
    required this.coalPrice,
    required this.companyCommission,
    this.destinationFactory,
    this.netAmount,
    this.paymentStatus,
    this.liabilityId,
    this.amountFromLiability,
    this.amountCash,
    this.receivableId,
    this.createdBy,
    this.modifiedBy,
    this.createdAt,
    this.updatedAt,
    this.siteName,
    this.client,
    this.liability,
    this.receivable,
    this.creator,
    this.modifier,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      siteId: json['siteId'] ?? json['site_id'] ?? 0,
      clientId: json['clientId'] ?? json['client_id'],
      truckNumber: json['truckNumber'] ?? json['truck_number'] ?? '',
      loadingDate: json['loadingDate'] ?? json['loading_date'] ?? '',
      driverName: json['driverName'] ?? json['driver_name'] ?? '',
      driverPhone: json['driverPhone'] ?? json['driver_phone'],
      coalPrice: _parseDouble(json['coalPrice'] ?? json['coal_price']) ?? 0.0,
      companyCommission: _parseDouble(json['companyCommission'] ?? json['company_commission']) ?? 0.0,
      destinationFactory: json['destinationFactory'] ?? json['destination_factory'],
      netAmount: _parseDouble(json['netAmount'] ?? json['net_amount'] ?? json['totalPrice'] ?? json['total_price']),
      paymentStatus: json['paymentStatus'] ?? json['payment_status'],
      liabilityId: json['liabilityId'] ?? json['liability_id'],
      amountFromLiability: _parseDouble(json['amountFromLiability'] ?? json['amount_from_liability']),
      amountCash: _parseDouble(json['amountCash'] ?? json['amount_cash']),
      receivableId: json['receivableId'] ?? json['receivable_id'],
      createdBy: json['createdBy'] ?? json['created_by'],
      modifiedBy: json['modifiedBy'] ?? json['modified_by'],
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
      siteName: json['site']?['name'] ?? json['siteName'],
      client: json['client'],
      liability: json['liability'],
      receivable: json['receivable'],
      creator: json['creator'],
      modifier: json['modifier'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'siteId': siteId,
      'truckNumber': truckNumber,
      'loadingDate': loadingDate,
      'driverName': driverName,
      if (driverPhone != null && driverPhone!.isNotEmpty) 'driverPhone': driverPhone,
      'coalPrice': coalPrice,
      'companyCommission': companyCommission,
      if (destinationFactory != null && destinationFactory!.isNotEmpty) 'destinationFactory': destinationFactory,
      if (netAmount != null) 'netAmount': netAmount,
      if (paymentStatus != null && paymentStatus!.isNotEmpty) 'paymentStatus': paymentStatus,
    };
  }

  Map<String, dynamic> toJsonRequest() {
    return {
      'siteId': siteId,
      if (clientId != null) 'clientId': clientId,
      'truckNumber': truckNumber,
      'loadingDate': loadingDate,
      'driverName': driverName,
      if (driverPhone != null && driverPhone!.isNotEmpty) 'driverPhone': driverPhone,
      'coalPrice': coalPrice,
      'companyCommission': companyCommission,
      if (destinationFactory != null && destinationFactory!.isNotEmpty) 'destinationFactory': destinationFactory,
      if (netAmount != null) 'netAmount': netAmount,
      if (paymentStatus != null && paymentStatus!.isNotEmpty) 'paymentStatus': paymentStatus,
      if (liabilityId != null) 'liabilityId': liabilityId,
      if (amountFromLiability != null) 'amountFromLiability': amountFromLiability,
      if (amountCash != null) 'amountCash': amountCash,
    };
  }
}
