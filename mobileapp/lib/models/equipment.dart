class EquipmentModel {
  final int? id;
  final String name;
  final String? type;
  final String? model;
  final String? serialNumber;
  final String? purchaseDate;
  final double? purchasePrice;
  final String status;
  final String? notes;
  final int? siteId;
  final String? createdAt;
  final String? updatedAt;

  // Navigation property
  final String? siteName;

  EquipmentModel({
    this.id,
    required this.name,
    this.type,
    this.model,
    this.serialNumber,
    this.purchaseDate,
    this.purchasePrice,
    this.status = 'active',
    this.notes,
    this.siteId,
    this.createdAt,
    this.updatedAt,
    this.siteName,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'],
      model: json['model'],
      serialNumber: json['serialNumber'] ?? json['serial_number'],
      purchaseDate: json['purchaseDate'] ?? json['purchase_date'],
      purchasePrice: _parseDouble(json['purchasePrice'] ?? json['purchase_price']),
      status: json['status'] ?? 'active',
      notes: json['notes'],
      siteId: json['siteId'] ?? json['site_id'],
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
      'name': name,
      if (type != null && type!.isNotEmpty) 'type': type,
      if (model != null && model!.isNotEmpty) 'model': model,
      if (serialNumber != null && serialNumber!.isNotEmpty) 'serialNumber': serialNumber,
      if (purchaseDate != null) 'purchaseDate': purchaseDate,
      if (purchasePrice != null) 'purchasePrice': purchasePrice,
      'status': status,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (siteId != null) 'siteId': siteId,
    };
  }

  Map<String, dynamic> toJsonRequest() {
    return {
      'name': name,
      if (type != null && type!.isNotEmpty) 'type': type,
      if (model != null && model!.isNotEmpty) 'model': model,
      if (serialNumber != null && serialNumber!.isNotEmpty) 'serialNumber': serialNumber,
      if (purchaseDate != null) 'purchaseDate': purchaseDate,
      if (purchasePrice != null) 'purchasePrice': purchasePrice,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (siteId != null) 'siteId': siteId,
    };
  }
}
