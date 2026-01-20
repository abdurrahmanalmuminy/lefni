import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lefni/models/document_model.dart';

class FileService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required File file,
    required String fileName,
    required DocumentCategory category,
    String? caseId,
    String? clientId,
  }) async {
    try {
      String path = 'documents';
      if (category == DocumentCategory.clientDoc && clientId != null) {
        path = 'documents/clients/$clientId';
      } else if (category == DocumentCategory.contract && caseId != null) {
        path = 'documents/contracts/$caseId';
      } else if (category == DocumentCategory.report) {
        path = 'documents/reports';
      }

      final ref = _storage.ref().child('$path/$fileName');
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<String> uploadContractFile({
    required File file,
    required String contractId,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('contracts/$contractId/$fileName');
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload contract file: $e');
    }
  }

  Future<String> uploadAgencyImage({
    required File file,
    required String clientId,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('agencies/$clientId/$fileName');
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload agency image: $e');
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<String> uploadReceiptImage({
    required File file,
    required String expenseId,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('receipts/$expenseId/$fileName');
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload receipt image: $e');
    }
  }
}

