class Worker {
  final int? id;
  final String fullName;
  final String? employeeId;
  final String? role;
  final String? team;
  final String? phone;
  final String? email;
  final String status; // 'active', 'inactive'
  final bool isActive;
  final String? hireDate;
  final String? photoUrl;
  final int? supervisorId;
  final String? supervisorName;

  Worker({
    this.id,
    required this.fullName,
    this.employeeId,
    this.role,
    this.team,
    this.phone,
    this.email,
    this.status = 'active',
    this.isActive = true,
    this.hireDate,
    this.photoUrl,
    this.supervisorId,
    this.supervisorName,
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
      status: json['status'] as String? ?? 'active',
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      hireDate: json['hireDate'] as String? ?? json['hire_date'] as String?,
      photoUrl: json['photoUrl'] as String? ?? json['photo_url'] as String?,
      supervisorId: json['supervisorId'] as int? ?? json['supervisor_id'] as int?,
      supervisorName: json['supervisorName'] as String? ?? json['supervisor_name'] as String?,
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
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
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
      'supervisorId': supervisorId,
    };
  }
}
