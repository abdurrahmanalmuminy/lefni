import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lefni/models/document_model.dart';
import 'package:lefni/exceptions/app_exceptions.dart';
import 'package:lefni/utils/logger.dart';

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

      // Check file size (10MB limit)
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        throw StorageException.fileTooLarge(10);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.info('File uploaded successfully: $fileName');
      return downloadUrl;
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to upload file: $fileName', e);
      if (e.code == 'unauthorized') {
        throw StorageException.uploadFailed(fileName, StorageException('Permission denied'));
      }
      throw StorageException.uploadFailed(fileName, e);
    } catch (e) {
      AppLogger.error('Failed to upload file: $fileName', e);
      if (e is StorageException) rethrow;
      throw StorageException.uploadFailed(fileName, e);
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

      AppLogger.info('Contract file uploaded successfully: $fileName');
      return downloadUrl;
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to upload contract file: $fileName', e);
      throw StorageException.uploadFailed(fileName, e);
    } catch (e) {
      AppLogger.error('Failed to upload contract file: $fileName', e);
      throw StorageException.uploadFailed(fileName, e);
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

      // Check file size (5MB limit for images)
      final fileSize = await file.length();
      const maxSize = 5 * 1024 * 1024; // 5MB
      if (fileSize > maxSize) {
        throw StorageException.fileTooLarge(5);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.info('Agency image uploaded successfully: $fileName');
      return downloadUrl;
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to upload agency image: $fileName', e);
      throw StorageException.uploadFailed(fileName, e);
    } catch (e) {
      AppLogger.error('Failed to upload agency image: $fileName', e);
      if (e is StorageException) rethrow;
      throw StorageException.uploadFailed(fileName, e);
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      AppLogger.info('File deleted successfully: $fileUrl');
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to delete file: $fileUrl', e);
      throw StorageException.deleteFailed(fileUrl, e);
    } catch (e) {
      AppLogger.error('Failed to delete file: $fileUrl', e);
      throw StorageException.deleteFailed(fileUrl, e);
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

      // Check file size (5MB limit for images)
      final fileSize = await file.length();
      const maxSize = 5 * 1024 * 1024; // 5MB
      if (fileSize > maxSize) {
        throw StorageException.fileTooLarge(5);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.info('Receipt image uploaded successfully: $fileName');
      return downloadUrl;
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to upload receipt image: $fileName', e);
      throw StorageException.uploadFailed(fileName, e);
    } catch (e) {
      AppLogger.error('Failed to upload receipt image: $fileName', e);
      if (e is StorageException) rethrow;
      throw StorageException.uploadFailed(fileName, e);
    }
  }
}

