class TruckDelivery {
  final int id;
  final int siteId;
  final DateTime deliveryDate;
  final String buyerName;
  final String vehicleNumber;
  final double quantityTons;
  final double totalPrice;
  final String? status;
  final List<String>? evidencePhotos;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TruckDelivery({
    required this.id,
    required this.siteId,
    required this.deliveryDate,
    required this.buyerName,
    required this.vehicleNumber,
    required this.quantityTons,
    required this.totalPrice,
    this.status,
    this.evidencePhotos,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory TruckDelivery.fromJson(Map<String, dynamic> json) {
    return TruckDelivery(
      id: json['id'] as int,
      siteId: json['siteId'] is Map
          ? json['siteId']['id'] as int
          : json['siteId'] as int,
      deliveryDate: DateTime.parse(json['deliveryDate'] as String),
      buyerName: json['buyerName'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      quantityTons: double.tryParse(json['quantityTons'].toString()) ?? 0.0,
      totalPrice: double.tryParse(json['totalPrice'].toString()) ?? 0.0,
      status: json['status'] as String?,
      evidencePhotos: json['evidencePhotos'] != null
          ? List<String>.from(json['evidencePhotos'] as List)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteId': siteId,
      'deliveryDate': deliveryDate.toIso8601String(),
      'buyerName': buyerName,
      'vehicleNumber': vehicleNumber,
      'quantityTons': quantityTons,
      'totalPrice': totalPrice,
      'status': status,
      'evidencePhotos': evidencePhotos,
      'notes': notes,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
