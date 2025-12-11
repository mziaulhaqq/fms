class MiningSite {
  final int? id;
  final String name;
  final String location;
  final String? description;
  final bool isActive;
  final int? leaseId;
  final String? createdAt;
  final String? updatedAt;

  MiningSite({
    this.id,
    required this.name,
    required this.location,
    this.description,
    this.isActive = true,
    this.leaseId,
    this.createdAt,
    this.updatedAt,
  });

  factory MiningSite.fromJson(Map<String, dynamic> json) {
    return MiningSite(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      leaseId: json['leaseId'] ?? json['lease_id'],
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'location': location,
      if (description != null && description!.isNotEmpty) 'description': description,
      'isActive': isActive,
      if (leaseId != null) 'leaseId': leaseId,
    };
  }

  Map<String, dynamic> toJsonRequest() {
    return {
      'name': name,
      'location': location,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (leaseId != null) 'leaseId': leaseId,
    };
  }
}
