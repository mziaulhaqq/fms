class Role {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  Role({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class UserAssignedRole {
  final int id;
  final int userId;
  final int roleId;
  final String status;
  final DateTime? assignedAt;
  final Role? role;

  UserAssignedRole({
    required this.id,
    required this.userId,
    required this.roleId,
    required this.status,
    this.assignedAt,
    this.role,
  });

  factory UserAssignedRole.fromJson(Map<String, dynamic> json) {
    return UserAssignedRole(
      id: json['id'],
      userId: json['userId'],
      roleId: json['roleId'],
      status: json['status'] ?? 'active',
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'])
          : null,
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'roleId': roleId,
      'status': status,
      'assignedAt': assignedAt?.toIso8601String(),
      'role': role?.toJson(),
    };
  }
}
