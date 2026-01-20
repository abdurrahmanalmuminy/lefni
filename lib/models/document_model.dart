import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/l10n/app_localizations.dart';

class DocumentModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final FileType fileType;
  final DocumentCategory category;
  final String? caseId; // Optional link to case
  final String? clientId; // Optional link to client
  final String uploaderUid;
  final DateTime uploadedAt;
  final int fileSize; // in bytes

  DocumentModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.category,
    this.caseId,
    this.clientId,
    required this.uploaderUid,
    required this.uploadedAt,
    required this.fileSize,
  });

  factory DocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentModel(
      id: doc.id,
      fileName: data['fileName'] as String,
      fileUrl: data['fileUrl'] as String,
      fileType: FileType.fromString(data['fileType'] as String),
      category: DocumentCategory.fromString(data['category'] as String),
      caseId: data['caseId'] as String?,
      clientId: data['clientId'] as String?,
      uploaderUid: data['uploaderUid'] as String,
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      fileSize: (data['fileSize'] as num).toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType.value,
      'category': category.value,
      if (caseId != null) 'caseId': caseId,
      if (clientId != null) 'clientId': clientId,
      'uploaderUid': uploaderUid,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'fileSize': fileSize,
    };
  }
}

enum FileType {
  pdf('pdf'),
  word('word'),
  image('image'),
  excel('excel'),
  other('other');

  final String value;
  const FileType(this.value);

  static FileType fromString(String value) {
    return FileType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FileType.other,
    );
  }
}

enum DocumentCategory {
  clientDoc('client_doc'),
  officeDoc('office_doc'),
  contract('contract'),
  report('report'),
  other('other');

  final String value;
  const DocumentCategory(this.value);

  static DocumentCategory fromString(String value) {
    return DocumentCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DocumentCategory.other,
    );
  }
}

extension DocumentCategoryLocalization on DocumentCategory {
  String localized(AppLocalizations localizations) {
    switch (this) {
      case DocumentCategory.clientDoc:
        return localizations.documentCategoryClientDoc;
      case DocumentCategory.officeDoc:
        return localizations.documentCategoryOfficeDoc;
      case DocumentCategory.contract:
        return localizations.documentCategoryContract;
      case DocumentCategory.report:
        return localizations.documentCategoryReport;
      case DocumentCategory.other:
        return localizations.documentCategoryOther;
    }
  }
}

