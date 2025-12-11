class Client {
  final int? id;
  final String businessName;
  final String ownerName;
  final String? address;
  final String? ownerContact;
  final String? munshiName;
  final String? munshiContact;
  final String? description;
  final String? onboardingDate;
  final bool isActive;
  final int? clientTypeId;
  final List<String> documentFiles;
  final String? createdAt;
  final String? updatedAt;

  Client({
    this.id,
    required this.businessName,
    required this.ownerName,
    this.address,
    this.ownerContact,
    this.munshiName,
    this.munshiContact,
    this.description,
    this.onboardingDate,
    this.isActive = true,
    this.clientTypeId,
    this.documentFiles = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      businessName: json['businessName'] ?? '',
      ownerName: json['ownerName'] ?? '',
      address: json['address'],
      ownerContact: json['ownerContact'],
      munshiName: json['munshiName'],
      munshiContact: json['munshiContact'],
      description: json['description'],
      onboardingDate: json['onboardingDate'],
      isActive: json['isActive'] ?? true,
      clientTypeId: json['clientTypeId'],
      documentFiles: json['documentFiles'] != null 
          ? List<String>.from(json['documentFiles'])
          : [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'businessName': businessName,
      'ownerName': ownerName,
      if (address != null) 'address': address,
      if (ownerContact != null) 'ownerContact': ownerContact,
      if (munshiName != null) 'munshiName': munshiName,
      if (munshiContact != null) 'munshiContact': munshiContact,
      if (description != null) 'description': description,
      if (onboardingDate != null) 'onboardingDate': onboardingDate,
      'isActive': isActive,
      if (clientTypeId != null) 'clientTypeId': clientTypeId,
      'documentFiles': documentFiles,
    };
  }
}
