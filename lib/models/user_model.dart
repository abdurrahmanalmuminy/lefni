import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // Firebase Auth UID, doc_id
  final String email;
  final String? phoneNumber;
  final UserRole role;
  final UserProfile profile;
  final List<String> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.profile,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      phoneNumber: data['phoneNumber'] as String?,
      role: UserRole.fromString(data['role'] as String),
      profile: UserProfile.fromMap(data['profile'] as Map<String, dynamic>),
      permissions: (data['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'role': role.value,
      'profile': profile.toMap(),
      'permissions': permissions,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      if (lastLogin != null) 'lastLogin': Timestamp.fromDate(lastLogin!),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      role: UserRole.fromString(json['role'] as String),
      profile: UserProfile.fromMap(json['profile'] as Map<String, dynamic>),
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'role': role.value,
      'profile': profile.toMap(),
      'permissions': permissions,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    UserRole? role,
    UserProfile? profile,
    List<String>? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profile: profile ?? this.profile,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

enum UserRole {
  admin('admin'),
  lawyer('lawyer'),
  student('student'),
  engineer('engineer'),
  accountant('accountant'),
  translator('translator'),
  client('client');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.client,
    );
  }
}

class UserProfile {
  // Common fields
  final String? name; // User's display name
  
  // Role-specific fields
  final String? specialization; // for lawyers
  final String? cvUrl; // for students
  final bool? isTraining; // for students
  final String? licenseNumber; // for engineers/accountants
  final String? firmName; // for engineers/accountants
  final String? university; // for students
  final CooperationType? cooperationType; // for students
  final String? bankAccount; // for students
  
  // License and registration fields (for non-client users)
  final LicenseType? licenseType; // نوع الرخصة
  final DateTime? licenseExpiryDate; // تاريخ سريان الرخصة
  final String? experience; // الخبرة
  final String? region; // المنطقة
  final String? city; // المدينة
  final String? collaborationNature; // طبيعة التعاون (for collaborators)
  final String? idNumber; // رقم الهوية

  UserProfile({
    this.name,
    this.specialization,
    this.cvUrl,
    this.isTraining,
    this.licenseNumber,
    this.firmName,
    this.university,
    this.cooperationType,
    this.bankAccount,
    this.licenseType,
    this.licenseExpiryDate,
    this.experience,
    this.region,
    this.city,
    this.collaborationNature,
    this.idNumber,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String?,
      specialization: map['specialization'] as String?,
      cvUrl: map['cvUrl'] as String?,
      isTraining: map['isTraining'] as bool?,
      licenseNumber: map['licenseNumber'] as String?,
      firmName: map['firmName'] as String?,
      university: map['university'] as String?,
      cooperationType: map['cooperationType'] != null
          ? CooperationType.fromString(map['cooperationType'] as String)
          : null,
      bankAccount: map['bankAccount'] as String?,
      licenseType: map['licenseType'] != null
          ? LicenseType.fromString(map['licenseType'] as String)
          : null,
      licenseExpiryDate: map['licenseExpiryDate'] != null
          ? (map['licenseExpiryDate'] as Timestamp).toDate()
          : null,
      experience: map['experience'] as String?,
      region: map['region'] as String?,
      city: map['city'] as String?,
      collaborationNature: map['collaborationNature'] as String?,
      idNumber: map['idNumber'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (specialization != null) 'specialization': specialization,
      if (cvUrl != null) 'cvUrl': cvUrl,
      if (isTraining != null) 'isTraining': isTraining,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      if (firmName != null) 'firmName': firmName,
      if (university != null) 'university': university,
      if (cooperationType != null) 'cooperationType': cooperationType!.value,
      if (bankAccount != null) 'bankAccount': bankAccount,
      if (licenseType != null) 'licenseType': licenseType!.value,
      if (licenseExpiryDate != null)
        'licenseExpiryDate': Timestamp.fromDate(licenseExpiryDate!),
      if (experience != null) 'experience': experience,
      if (region != null) 'region': region,
      if (city != null) 'city': city,
      if (collaborationNature != null) 'collaborationNature': collaborationNature,
      if (idNumber != null) 'idNumber': idNumber,
    };
  }

  UserProfile copyWith({
    String? name,
    String? specialization,
    String? cvUrl,
    bool? isTraining,
    String? licenseNumber,
    String? firmName,
    String? university,
    CooperationType? cooperationType,
    String? bankAccount,
    LicenseType? licenseType,
    DateTime? licenseExpiryDate,
    String? experience,
    String? region,
    String? city,
    String? collaborationNature,
    String? idNumber,
  }) {
    return UserProfile(
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      cvUrl: cvUrl ?? this.cvUrl,
      isTraining: isTraining ?? this.isTraining,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      firmName: firmName ?? this.firmName,
      university: university ?? this.university,
      cooperationType: cooperationType ?? this.cooperationType,
      bankAccount: bankAccount ?? this.bankAccount,
      licenseType: licenseType ?? this.licenseType,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      experience: experience ?? this.experience,
      region: region ?? this.region,
      city: city ?? this.city,
      collaborationNature: collaborationNature ?? this.collaborationNature,
      idNumber: idNumber ?? this.idNumber,
    );
  }
}

enum CooperationType {
  training('training'),
  caseSourcing('case_sourcing');

  final String value;
  const CooperationType(this.value);

  static CooperationType fromString(String value) {
    return CooperationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CooperationType.training,
    );
  }
}

enum LicenseType {
  licensedLawyer('licensed_lawyer', 'محامي مرخص'),
  legalConsultant('legal_consultant', 'مستشار قانوني'),
  traineeLawyer('trainee_lawyer', 'محامي متدرب'),
  collaborator('collaborator', 'المتعاون');

  final String value;
  final String arabicLabel;
  const LicenseType(this.value, this.arabicLabel);

  static LicenseType fromString(String value) {
    return LicenseType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LicenseType.licensedLawyer,
    );
  }
}
