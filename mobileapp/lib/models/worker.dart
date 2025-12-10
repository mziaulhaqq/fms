class Worker {
  final int? id;
  final String fullName;
  final String? employeeId; // CNIC
  final String? role;
  final String? team;
  final String? phone;
  final String? email;
  final String status; // 'active', 'inactive'
  final bool isActive;
  final String? hireDate; // onboarding_date
  final String? photoUrl;
  final int? supervisorId;
  final String? supervisorName;
  
  // Additional fields from database
  final String? fatherName;
  final String? address;
  final String? mobileNumber;
  final String? emergencyNumber;
  final String? startDate;
  final String? endDate;
  final double? dailyWage;
  final String? notes;
  final String? otherDetail;

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
    this.fatherName,
    this.address,
    this.mobileNumber,
    this.emergencyNumber,
    this.startDate,
    this.endDate,
    this.dailyWage,
    this.notes,
    this.otherDetail,
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
      fatherName: json['fatherName'] as String? ?? json['father_name'] as String?,
      address: json['address'] as String?,
      mobileNumber: json['mobileNumber'] as String? ?? json['mobile_number'] as String?,
      emergencyNumber: json['emergencyNumber'] as String? ?? json['emergency_number'] as String?,
      startDate: json['startDate'] as String? ?? json['start_date'] as String?,
      endDate: json['endDate'] as String? ?? json['end_date'] as String?,
      dailyWage: json['dailyWage'] != null ? (json['dailyWage'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      otherDetail: json['otherDetail'] as String? ?? json['other_detail'] as String?,
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
      'fatherName': fatherName,
      'address': address,
      'mobileNumber': mobileNumber,
      'emergencyNumber': emergencyNumber,
      'startDate': startDate,
      'endDate': endDate,
      'dailyWage': dailyWage,
      'notes': notes,
      'otherDetail': otherDetail,
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
      'fatherName': fatherName,
      'address': address,
      'mobileNumber': mobileNumber,
      'emergencyNumber': emergencyNumber,
      'startDate': startDate,
      'endDate': endDate,
      'dailyWage': dailyWage,
      'notes': notes,
      'otherDetail': otherDetail,
    };
  }
}
