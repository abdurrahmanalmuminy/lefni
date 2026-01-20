import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/services/firestore/contract_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/models/contract_model.dart';

class LegalService {
  final CaseService _caseService = CaseService();
  final ContractService _contractService = ContractService();
  final ClientService _clientService = ClientService();

  // Link a contract to a case
  Future<void> linkContractToCase(String contractId, String caseId) async {
    try {
      final contract = await _contractService.getContract(contractId);
      if (contract != null) {
        await _contractService.updateContract(
          contract.copyWith(caseId: caseId),
        );
      }
    } catch (e) {
      throw Exception('Failed to link contract to case: $e');
    }
  }

  // Link a case to a client
  Future<void> linkCaseToClient(String caseId, String clientId) async {
    try {
      final case_ = await _caseService.getCase(caseId);
      if (case_ != null) {
        await _caseService.updateCase(
          case_.copyWith(clientId: clientId),
        );
      }
    } catch (e) {
      throw Exception('Failed to link case to client: $e');
    }
  }

  // Get all contracts for a case
  Future<List<ContractModel>> getContractsForCase(String caseId) async {
    try {
      final contracts = <ContractModel>[];
      await for (var contractList in _contractService.getContractsByCase(caseId)) {
        contracts.addAll(contractList);
      }
      return contracts;
    } catch (e) {
      throw Exception('Failed to get contracts for case: $e');
    }
  }

  // Get all cases for a client
  Future<List<CaseModel>> getCasesForClient(String clientId) async {
    try {
      final cases = <CaseModel>[];
      await for (var caseList in _caseService.getCasesByClient(clientId)) {
        cases.addAll(caseList);
      }
      return cases;
    } catch (e) {
      throw Exception('Failed to get cases for client: $e');
    }
  }

  // Create a case with optional contract link
  Future<String> createCaseWithContract({
    required CaseModel case_,
    ContractModel? contract,
  }) async {
    try {
      final caseId = await _caseService.createCase(case_);
      
      if (contract != null) {
        final contractWithCase = contract.copyWith(caseId: caseId);
        await _contractService.createContract(contractWithCase);
      }
      
      return caseId;
    } catch (e) {
      throw Exception('Failed to create case with contract: $e');
    }
  }

  // Update client stats when case is created/closed
  Future<void> updateClientStatsOnCaseChange(
    String clientId,
    bool isNewCase,
  ) async {
    try {
      final client = await _clientService.getClient(clientId);
      if (client != null) {
        final newActiveCases = isNewCase
            ? client.stats.activeCases + 1
            : client.stats.activeCases - 1;
        
        await _clientService.updateClientStats(
          clientId,
          client.stats.copyWith(activeCases: newActiveCases),
        );
      }
    } catch (e) {
      throw Exception('Failed to update client stats: $e');
    }
  }
}

