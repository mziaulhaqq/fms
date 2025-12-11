class Income {
  final int? id;
  final int siteId;
  final String truckNumber;
  final String loadingDate;
  final String driverName;
  final String? driverPhone;
  final double coalPrice;
  final double companyCommission;
  final String? destinationFactory;
  final double? netAmount;
  final String? paymentStatus;
  final String? createdAt;
  final String? updatedAt;

  // Navigation property
  final String? siteName;

  Income({
    this.id,
    required this.siteId,
    required this.truckNumber,
    required this.loadingDate,
    required this.driverName,
    this.driverPhone,
    required this.coalPrice,
    required this.companyCommission,
    this.destinationFactory,
    this.netAmount,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
    this.siteName,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      siteId: json['siteId'] ?? json['site_id'] ?? 0,
      truckNumber: json['truckNumber'] ?? json['truck_number'] ?? '',
      loadingDate: json['loadingDate'] ?? json['loading_date'] ?? '',
      driverName: json['driverName'] ?? json['driver_name'] ?? '',
      driverPhone: json['driverPhone'] ?? json['driver_phone'],
      coalPrice: _parseDouble(json['coalPrice'] ?? json['coal_price']) ?? 0.0,
      companyCommission: _parseDouble(json['companyCommission'] ?? json['company_commission']) ?? 0.0,
      destinationFactory: json['destinationFactory'] ?? json['destination_factory'],
      netAmount: _parseDouble(json['netAmount'] ?? json['net_amount'] ?? json['totalPrice'] ?? json['total_price']),
      paymentStatus: json['paymentStatus'] ?? json['payment_status'],
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
      siteName: json['site']?['name'] ?? json['siteName'],
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
}
