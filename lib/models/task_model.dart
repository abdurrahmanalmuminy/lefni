import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/l10n/app_localizations.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String relatedId;
  final RelatedType relatedType;
  final TaskDeadlines deadlines;
  final TaskStatus status;
  final String? completionReport;
  final DateTime? completedAt;
  final TaskPriority priority;
  final List<String> tags;
  final DateTime createdAt;
  final String createdBy;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.relatedId,
    required this.relatedType,
    required this.deadlines,
    required this.status,
    this.completionReport,
    this.completedAt,
    required this.priority,
    required this.tags,
    required this.createdAt,
    required this.createdBy,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      assignedTo: data['assignedTo'] as String,
      relatedId: data['relatedId'] as String,
      relatedType: RelatedType.fromString(data['relatedType'] as String),
      deadlines: TaskDeadlines.fromMap(
          data['deadlines'] as Map<String, dynamic>),
      status: TaskStatus.fromString(data['status'] as String),
      completionReport: data['completionReport'] as String?,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      priority: TaskPriority.fromString(data['priority'] as String),
      tags: (data['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'relatedId': relatedId,
      'relatedType': relatedType.value,
      'deadlines': deadlines.toMap(),
      'status': status.value,
      if (completionReport != null) 'completionReport': completionReport,
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      'priority': priority.value,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      assignedTo: json['assignedTo'] as String,
      relatedId: json['relatedId'] as String,
      relatedType: RelatedType.fromString(json['relatedType'] as String),
      deadlines: TaskDeadlines.fromMap(json['deadlines'] as Map<String, dynamic>),
      status: TaskStatus.fromString(json['status'] as String),
      completionReport: json['completionReport'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      priority: TaskPriority.fromString(json['priority'] as String),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'relatedId': relatedId,
      'relatedType': relatedType.value,
      'deadlines': deadlines.toMap(),
      'status': status.value,
      if (completionReport != null) 'completionReport': completionReport,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      'priority': priority.value,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? relatedId,
    RelatedType? relatedType,
    TaskDeadlines? deadlines,
    TaskStatus? status,
    String? completionReport,
    DateTime? completedAt,
    TaskPriority? priority,
    List<String>? tags,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      deadlines: deadlines ?? this.deadlines,
      status: status ?? this.status,
      completionReport: completionReport ?? this.completionReport,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

enum RelatedType {
  case_('case'),
  client('client'),
  contract('contract');

  final String value;
  const RelatedType(this.value);

  static RelatedType fromString(String value) {
    return RelatedType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RelatedType.case_,
    );
  }
}

extension RelatedTypeLocalization on RelatedType {
  String localized(AppLocalizations localizations) {
    switch (this) {
      case RelatedType.case_:
        return localizations.relatedTypeCase;
      case RelatedType.client:
        return localizations.relatedTypeClient;
      case RelatedType.contract:
        return localizations.relatedTypeContract;
    }
  }
}

enum TaskStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const TaskStatus(this.value);

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

enum TaskPriority {
  low('low'),
  medium('medium'),
  high('high');

  final String value;
  const TaskPriority(this.value);

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

extension TaskPriorityLocalization on TaskPriority {
  String localized(AppLocalizations localizations) {
    switch (this) {
      case TaskPriority.low:
        return localizations.taskPriorityLow;
      case TaskPriority.medium:
        return localizations.taskPriorityMedium;
      case TaskPriority.high:
        return localizations.taskPriorityHigh;
    }
  }
}

class TaskDeadlines {
  final DateTime start;
  final DateTime end;

  TaskDeadlines({
    required this.start,
    required this.end,
  });

  factory TaskDeadlines.fromMap(Map<String, dynamic> map) {
    return TaskDeadlines(
      start: (map['start'] as Timestamp).toDate(),
      end: (map['end'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
    };
  }
}

