class ExpenseType {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? createdById;
  final int? modifiedById;

  ExpenseType({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.modifiedById,
  });

  factory ExpenseType.fromJson(Map<String, dynamic> json) {
    return ExpenseType(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdById: json['createdById'] as int?,
      modifiedById: json['modifiedById'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}
