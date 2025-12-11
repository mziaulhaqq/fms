class Partner {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String cnic;
  final double? sharePercentage;
  final String? address;
  final int? leaseId;
  final int? miningSiteId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Navigation properties (from backend relations)
  final String? leaseName;
  final String? siteName;

  Partner({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.cnic,
    this.sharePercentage,
    this.address,
    this.leaseId,
    this.miningSiteId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.leaseName,
    this.siteName,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      cnic: json['cnic'] as String,
      sharePercentage: json['sharePercentage'] != null
          ? double.tryParse(json['sharePercentage'].toString())
          : null,
      address: json['address'] as String?,
      leaseId: json['leaseId'] as int?,
      miningSiteId: json['miningSiteId'] != null
          ? (json['miningSiteId'] is Map
              ? json['miningSiteId']['id'] as int?
              : json['miningSiteId'] as int?)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      leaseName: json['leaseName'] as String?,
      siteName: json['siteName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'cnic': cnic,
      'sharePercentage': sharePercentage,
      'address': address,
      'leaseId': leaseId,
      'miningSiteId': miningSiteId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
