class Production {
  final int id;
  final DateTime date;
  final double quantity;
  final String? quality;
  final String? shift;
  final String? notes;
  final int? siteId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Production({
    required this.id,
    required this.date,
    required this.quantity,
    this.quality,
    this.shift,
    this.notes,
    this.siteId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
      quality: json['quality'] as String?,
      shift: json['shift'] as String?,
      notes: json['notes'] as String?,
      siteId: json['site'] != null
          ? (json['site'] is Map
              ? json['site']['id'] as int?
              : json['site'] as int?)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'quantity': quantity,
      'quality': quality,
      'shift': shift,
      'notes': notes,
      'site': siteId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonRequest() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'siteId': siteId,
      'quantity': quantity.toString(),
      if (quality != null && quality!.isNotEmpty) 'quality': quality,
      if (shift != null && shift!.isNotEmpty) 'shift': shift,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}
