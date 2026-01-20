import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  final String id;
  final ClientType type;
  final String identityNumber; // ID or CR Number
  final String name;
  final ClientContact contact;
  final AgencyData? agencyData;
  final ClientStats stats;
  final DateTime createdAt;
  final String? userId; // Optional link to user document

  ClientModel({
    required this.id,
    required this.type,
    required this.identityNumber,
    required this.name,
    required this.contact,
    this.agencyData,
    required this.stats,
    required this.createdAt,
    this.userId,
  });

  factory ClientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClientModel(
      id: doc.id,
      type: ClientType.fromString(data['type'] as String),
      identityNumber: data['identityNumber'] as String,
      name: data['name'] as String,
      contact: ClientContact.fromMap(data['contact'] as Map<String, dynamic>),
      agencyData: data['agencyData'] != null
          ? AgencyData.fromMap(data['agencyData'] as Map<String, dynamic>)
          : null,
      stats: ClientStats.fromMap(data['stats'] as Map<String, dynamic>),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.value,
      'identityNumber': identityNumber,
      'name': name,
      'contact': contact.toMap(),
      if (agencyData != null) 'agencyData': agencyData!.toMap(),
      'stats': stats.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      if (userId != null) 'userId': userId,
    };
  }

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      type: ClientType.fromString(json['type'] as String),
      identityNumber: json['identityNumber'] as String,
      name: json['name'] as String,
      contact: ClientContact.fromMap(json['contact'] as Map<String, dynamic>),
      agencyData: json['agencyData'] != null
          ? AgencyData.fromMap(json['agencyData'] as Map<String, dynamic>)
          : null,
      stats: ClientStats.fromMap(json['stats'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'identityNumber': identityNumber,
      'name': name,
      'contact': contact.toMap(),
      if (agencyData != null) 'agencyData': agencyData!.toMap(),
      'stats': stats.toMap(),
      'createdAt': createdAt.toIso8601String(),
      if (userId != null) 'userId': userId,
    };
  }

  ClientModel copyWith({
    String? id,
    ClientType? type,
    String? identityNumber,
    String? name,
    ClientContact? contact,
    AgencyData? agencyData,
    ClientStats? stats,
    DateTime? createdAt,
    String? userId,
  }) {
    return ClientModel(
      id: id ?? this.id,
      type: type ?? this.type,
      identityNumber: identityNumber ?? this.identityNumber,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      agencyData: agencyData ?? this.agencyData,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}

enum ClientType {
  individual('individual'),
  business('business');

  final String value;
  const ClientType(this.value);

  static ClientType fromString(String value) {
    return ClientType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClientType.individual,
    );
  }
}

class ClientContact {
  final String phone;
  final String email;
  final String address;

  ClientContact({
    required this.phone,
    required this.email,
    required this.address,
  });

  factory ClientContact.fromMap(Map<String, dynamic> map) {
    return ClientContact(
      phone: map['phone'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}

class AgencyData {
  final String agencyNumber;
  final String attachmentUrl; // Image/PDF of agency

  AgencyData({
    required this.agencyNumber,
    required this.attachmentUrl,
  });

  factory AgencyData.fromMap(Map<String, dynamic> map) {
    return AgencyData(
      agencyNumber: map['agencyNumber'] as String,
      attachmentUrl: map['attachmentUrl'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'agencyNumber': agencyNumber,
      'attachmentUrl': attachmentUrl,
    };
  }
}

class ClientStats {
  final int activeCases;
  final double totalInvoiced;

  ClientStats({
    required this.activeCases,
    required this.totalInvoiced,
  });

  factory ClientStats.fromMap(Map<String, dynamic> map) {
    return ClientStats(
      activeCases: (map['activeCases'] as num).toInt(),
      totalInvoiced: (map['totalInvoiced'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activeCases': activeCases,
      'totalInvoiced': totalInvoiced,
    };
  }

  ClientStats copyWith({
    int? activeCases,
    double? totalInvoiced,
  }) {
    return ClientStats(
      activeCases: activeCases ?? this.activeCases,
      totalInvoiced: totalInvoiced ?? this.totalInvoiced,
    );
  }
}

