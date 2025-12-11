class Lease {
  final int id;
  final String leaseName;
  final String? location;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int createdById;
  final int? modifiedById;
  final List<dynamic>? miningSites;
  final List<dynamic>? partners;

  Lease({
    required this.id,
    required this.leaseName,
    this.location,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdById,
    this.modifiedById,
    this.miningSites,
    this.partners,
  });

  factory Lease.fromJson(Map<String, dynamic> json) {
    return Lease(
      id: json['id'],
      leaseName: json['leaseName'],
      location: json['location'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'],
      modifiedById: json['modifiedById'],
      miningSites: json['miningSites'],
      partners: json['partners'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaseName': leaseName,
      'location': location,
      'isActive': isActive,
    };
  }
}
