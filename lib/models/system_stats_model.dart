import 'package:cloud_firestore/cloud_firestore.dart';

class SystemStatsModel {
  final String id; // 'dashboard_overview' (single document)
  final ClientsStats clients;
  final CasesStats cases;
  final ContractsStats contracts;
  final FinancesStats finances;
  final SessionsStats sessions;
  final DateTime lastUpdated;

  SystemStatsModel({
    required this.id,
    required this.clients,
    required this.cases,
    required this.contracts,
    required this.finances,
    required this.sessions,
    required this.lastUpdated,
  });

  factory SystemStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SystemStatsModel(
      id: doc.id,
      clients: ClientsStats.fromMap(data['clients'] as Map<String, dynamic>),
      cases: CasesStats.fromMap(data['cases'] as Map<String, dynamic>),
      contracts:
          ContractsStats.fromMap(data['contracts'] as Map<String, dynamic>),
      finances:
          FinancesStats.fromMap(data['finances'] as Map<String, dynamic>),
      sessions:
          SessionsStats.fromMap(data['sessions'] as Map<String, dynamic>),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clients': clients.toMap(),
      'cases': cases.toMap(),
      'contracts': contracts.toMap(),
      'finances': finances.toMap(),
      'sessions': sessions.toMap(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory SystemStatsModel.fromJson(Map<String, dynamic> json) {
    return SystemStatsModel(
      id: json['id'] as String,
      clients: ClientsStats.fromMap(json['clients'] as Map<String, dynamic>),
      cases: CasesStats.fromMap(json['cases'] as Map<String, dynamic>),
      contracts:
          ContractsStats.fromMap(json['contracts'] as Map<String, dynamic>),
      finances: FinancesStats.fromMap(json['finances'] as Map<String, dynamic>),
      sessions: SessionsStats.fromMap(json['sessions'] as Map<String, dynamic>),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clients': clients.toMap(),
      'cases': cases.toMap(),
      'contracts': contracts.toMap(),
      'finances': finances.toMap(),
      'sessions': sessions.toMap(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  SystemStatsModel copyWith({
    String? id,
    ClientsStats? clients,
    CasesStats? cases,
    ContractsStats? contracts,
    FinancesStats? finances,
    SessionsStats? sessions,
    DateTime? lastUpdated,
  }) {
    return SystemStatsModel(
      id: id ?? this.id,
      clients: clients ?? this.clients,
      cases: cases ?? this.cases,
      contracts: contracts ?? this.contracts,
      finances: finances ?? this.finances,
      sessions: sessions ?? this.sessions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ClientsStats {
  final int total;
  final int active;
  final int individuals;
  final int businesses;

  ClientsStats({
    required this.total,
    required this.active,
    required this.individuals,
    required this.businesses,
  });

  factory ClientsStats.fromMap(Map<String, dynamic> map) {
    return ClientsStats(
      total: (map['total'] as num).toInt(),
      active: (map['active'] as num).toInt(),
      individuals: (map['individuals'] as num).toInt(),
      businesses: (map['businesses'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'active': active,
      'individuals': individuals,
      'businesses': businesses,
    };
  }
}

class CasesStats {
  final int total;
  final int active;
  final int prospects;
  final int closed;

  CasesStats({
    required this.total,
    required this.active,
    required this.prospects,
    required this.closed,
  });

  factory CasesStats.fromMap(Map<String, dynamic> map) {
    return CasesStats(
      total: (map['total'] as num).toInt(),
      active: (map['active'] as num).toInt(),
      prospects: (map['prospects'] as num).toInt(),
      closed: (map['closed'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'active': active,
      'prospects': prospects,
      'closed': closed,
    };
  }
}

class ContractsStats {
  final int total;
  final int pending;
  final int signed;
  final int archived;

  ContractsStats({
    required this.total,
    required this.pending,
    required this.signed,
    required this.archived,
  });

  factory ContractsStats.fromMap(Map<String, dynamic> map) {
    return ContractsStats(
      total: (map['total'] as num).toInt(),
      pending: (map['pending'] as num).toInt(),
      signed: (map['signed'] as num).toInt(),
      archived: (map['archived'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'pending': pending,
      'signed': signed,
      'archived': archived,
    };
  }
}

class FinancesStats {
  final double totalInvoiced;
  final double totalPaid;
  final double totalPending;
  final double monthlyRevenue;

  FinancesStats({
    required this.totalInvoiced,
    required this.totalPaid,
    required this.totalPending,
    required this.monthlyRevenue,
  });

  factory FinancesStats.fromMap(Map<String, dynamic> map) {
    return FinancesStats(
      totalInvoiced: (map['totalInvoiced'] as num).toDouble(),
      totalPaid: (map['totalPaid'] as num).toDouble(),
      totalPending: (map['totalPending'] as num).toDouble(),
      monthlyRevenue: (map['monthlyRevenue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalInvoiced': totalInvoiced,
      'totalPaid': totalPaid,
      'totalPending': totalPending,
      'monthlyRevenue': monthlyRevenue,
    };
  }
}

class SessionsStats {
  final int upcoming;
  final int today;
  final int thisWeek;

  SessionsStats({
    required this.upcoming,
    required this.today,
    required this.thisWeek,
  });

  factory SessionsStats.fromMap(Map<String, dynamic> map) {
    return SessionsStats(
      upcoming: (map['upcoming'] as num).toInt(),
      today: (map['today'] as num).toInt(),
      thisWeek: (map['thisWeek'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'upcoming': upcoming,
      'today': today,
      'thisWeek': thisWeek,
    };
  }
}

