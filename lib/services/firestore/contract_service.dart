import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/contract_model.dart';

class ContractService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'contracts';

  // Create a new contract
  Future<String> createContract(ContractModel contract) async {
    try {
      final now = DateTime.now();
      final docRef = await _firestore.collection(_collection).add(
            contract.copyWith(
              id: '',
              createdAt: now,
              updatedAt: now,
            ).toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create contract: $e');
    }
  }

  // Get contract by ID
  Future<ContractModel?> getContract(String contractId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(contractId).get();
      if (doc.exists) {
        return ContractModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get contract: $e');
    }
  }

  // Update contract
  Future<void> updateContract(ContractModel contract) async {
    try {
      await _firestore.collection(_collection).doc(contract.id).update(
            contract.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('Failed to update contract: $e');
    }
  }

  // Delete contract
  Future<void> deleteContract(String contractId) async {
    try {
      await _firestore.collection(_collection).doc(contractId).delete();
    } catch (e) {
      throw Exception('Failed to delete contract: $e');
    }
  }

  // Get contracts by client
  Stream<List<ContractModel>> getContractsByClient(String clientId) {
    return _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .where('metadata.isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContractModel.fromFirestore(doc))
            .toList());
  }

  // Get contracts by case
  Stream<List<ContractModel>> getContractsByCase(String caseId) {
    return _firestore
        .collection(_collection)
        .where('caseId', isEqualTo: caseId)
        .where('metadata.isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContractModel.fromFirestore(doc))
            .toList());
  }

  // Get all contracts
  Stream<List<ContractModel>> getAllContracts() {
    return _firestore
        .collection(_collection)
        .where('metadata.isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContractModel.fromFirestore(doc))
            .toList());
  }

  // Get archived contracts
  Stream<List<ContractModel>> getArchivedContracts() {
    return _firestore
        .collection(_collection)
        .where('metadata.isArchived', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContractModel.fromFirestore(doc))
            .toList());
  }

  // Add audit log entry
  Future<void> addAuditLog(
    String contractId,
    ContractAuditLog auditLog,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(contractId)
          .collection('audit_log')
          .add(auditLog.toFirestore());
    } catch (e) {
      throw Exception('Failed to add audit log: $e');
    }
  }

  // Get audit log for a contract
  Stream<List<ContractAuditLog>> getAuditLog(String contractId) {
    return _firestore
        .collection(_collection)
        .doc(contractId)
        .collection('audit_log')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContractAuditLog.fromFirestore(doc))
            .toList());
  }

  // Update signature status
  Future<void> updateSignatureStatus(
    String contractId,
    SignatureStatus signatureStatus,
  ) async {
    try {
      await _firestore.collection(_collection).doc(contractId).update({
        'signatureStatus': signatureStatus.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update signature status: $e');
    }
  }
}

