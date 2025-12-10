class Partner {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String cnic;
  final double? sharePercentage;
  final String? address;
  final String? lease;
  final int? mineNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Partner({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.cnic,
    this.sharePercentage,
    this.address,
    this.lease,
    this.mineNumber,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
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
      lease: json['lease'] as String?,
      mineNumber: json['mineNumber'] != null
          ? (json['mineNumber'] is Map
              ? json['mineNumber']['id'] as int?
              : json['mineNumber'] as int?)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
      'lease': lease,
      'mineNumber': mineNumber,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
