class ExpenseCategory {
  final int? id;
  final String name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  ExpenseCategory({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
    };
  }

  // Use this for create/update requests (excludes id, createdAt, updatedAt)
  Map<String, dynamic> toJsonRequest() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty) 
        'description': description,
    };
  }
}
