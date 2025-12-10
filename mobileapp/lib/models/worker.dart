class Worker {
  final int? id;
  final String fullName;
  final String? employeeId;
  final String? role;
  final String? team;
  final String? phone;
  final String? email;
  final String status; // 'On Shift', 'Off Duty', 'On Leave'
  final bool isActive;
  final String? hireDate;
  final String? photoUrl;

  Worker({
    this.id,
    required this.fullName,
    this.employeeId,
    this.role,
    this.team,
    this.phone,
    this.email,
    this.status = 'Off Duty',
    this.isActive = true,
    this.hireDate,
    this.photoUrl,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as int?,
      fullName: json['fullName'] as String? ?? json['full_name'] as String? ?? '',
      employeeId: json['employeeId'] as String? ?? json['employee_id'] as String?,
      role: json['role'] as String?,
      team: json['team'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'Off Duty',
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      hireDate: json['hireDate'] as String? ?? json['hire_date'] as String?,
      photoUrl: json['photoUrl'] as String? ?? json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'employeeId': employeeId,
      'role': role,
      'team': team,
      'phone': phone,
      'email': email,
      'status': status,
      'isActive': isActive,
      'hireDate': hireDate,
      'photoUrl': photoUrl,
    };
  }

  Map<String, dynamic> toJsonRequest() {
    return {
      'fullName': fullName,
      'employeeId': employeeId,
      'role': role,
      'team': team,
      'phone': phone,
      'email': email,
      'status': status,
      'isActive': isActive,
      'hireDate': hireDate,
      'photoUrl': photoUrl,
    };
  }
}
