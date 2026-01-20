import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/contract_model.dart';
import 'package:lefni/models/client_model.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/services/firestore/contract_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/services/storage/file_service.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';

class CreateContractForm extends StatefulWidget {
  final ContractModel? model;
  
  const CreateContractForm({super.key, this.model});

  @override
  State<CreateContractForm> createState() => _CreateContractFormState();
}

class _CreateContractFormState extends State<CreateContractForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _contractService = ContractService();
  final _clientService = ClientService();
  final _caseService = CaseService();
  final _fileService = FileService();
  
  String? _selectedClientId;
  String? _selectedCaseId;
  PartyType _selectedPartyType = PartyType.client;
  List<File> _selectedFiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      final contract = widget.model!;
      _selectedClientId = contract.clientId;
      _selectedCaseId = contract.caseId;
      _selectedPartyType = contract.partyType;
      _titleController.text = contract.title;
      _contentController.text = contract.content;
      // Note: Existing files are already in the model, new files can be added
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final result = await file_picker.FilePicker.platform.pickFiles(
        type: file_picker.FileType.any,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(
            result.files
                .where((file) => file.path != null)
                .map((file) => File(file.path!))
                .toList(),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  FileType _getFileTypeFromExtension(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (extension == 'pdf') {
      return FileType.pdf;
    } else if (['doc', 'docx'].contains(extension)) {
      return FileType.word;
    }
    return FileType.pdf; // Default
  }

  Future<void> _submit() async {
    final localizations = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectClient)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<ContractFile> contractFiles = [];
      
      // Upload files
      for (var file in _selectedFiles) {
        final fileName = file.path.split('/').last;
        final fileUrl = await _fileService.uploadContractFile(
          file: file,
          contractId: '', // Will be set after contract creation
          fileName: fileName,
        );
        contractFiles.add(
          ContractFile(
            name: fileName,
            url: fileUrl,
            type: _getFileTypeFromExtension(fileName),
          ),
        );
      }

      if (widget.model != null) {
        // Update existing contract
        // Upload new files if any
        List<ContractFile> existingFiles = widget.model!.files;
        for (var file in _selectedFiles) {
          final fileName = file.path.split('/').last;
          final fileUrl = await _fileService.uploadContractFile(
            file: file,
            contractId: widget.model!.id,
            fileName: fileName,
          );
          existingFiles.add(
            ContractFile(
              name: fileName,
              url: fileUrl,
              type: _getFileTypeFromExtension(fileName),
            ),
          );
        }
        
        final contract = widget.model!.copyWith(
          clientId: _selectedClientId!,
          caseId: _selectedCaseId,
          partyType: _selectedPartyType,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          files: existingFiles,
          updatedAt: DateTime.now(),
        );
        await _contractService.updateContract(contract);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث العقد بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new contract
      final now = DateTime.now();
      final contract = ContractModel(
        id: '',
        clientId: _selectedClientId!,
        caseId: _selectedCaseId,
        partyType: _selectedPartyType,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        files: contractFiles,
        signatureStatus: SignatureStatus(
          isSigned: false,
          status: SignatureStatusType.pending,
        ),
        metadata: ContractMetadata(
          isArchived: false,
          tags: [],
        ),
        createdAt: now,
        updatedAt: now,
      );

      await _contractService.createContract(contract);

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.contractCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return FormDialog(
      title: widget.model != null ? 'تعديل العقد' : localizations.createContract,
      isLoading: _isLoading,
      onSubmit: _submit,
      onCancel: () => Navigator.of(context).pop(),
      submitLabel: widget.model != null ? 'تحديث' : null,
      formContent: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Client
              StreamBuilder<List<ClientModel>>(
                stream: _clientService.getAllClients(),
                builder: (context, snapshot) {
                  final clients = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedClientId,
                    decoration: FormFieldStyle.styled(
                      labelText: localizations.clients,
                      prefixIcon: Icons.person_outline,
                    ),
                    items: clients.map((client) {
                      return DropdownMenuItem<String>(
                        value: client.id,
                        child: Text(client.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClientId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.clientRequired;
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Case (optional)
              StreamBuilder<List<CaseModel>>(
                stream: _caseService.getCasesByStatus(CaseStatus.active),
                builder: (context, snapshot) {
                  final cases = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedCaseId,
                    decoration: FormFieldStyle.styled(
                      labelText: localizations.caseOptional,
                      prefixIcon: Icons.folder_outlined,
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(localizations.none),
                      ),
                      ...cases.map((case_) {
                        return DropdownMenuItem<String>(
                          value: case_.id,
                          child: Text(case_.caseNumber),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCaseId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Party Type
              DropdownButtonFormField<PartyType>(
                value: _selectedPartyType,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.partyType,
                  prefixIcon: Icons.category_outlined,
                ),
                items: PartyType.values.map((type) {
                  return DropdownMenuItem<PartyType>(
                    value: type,
                    child: Text(type.localized(localizations)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPartyType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Title
              TextFormField(
                controller: _titleController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.title,
                  prefixIcon: Icons.title_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Content
              TextFormField(
                controller: _contentController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.content,
                  prefixIcon: Icons.description_outlined,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.contentRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Files
              InkWell(
                onTap: _pickFiles,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFiles.isEmpty
                              ? localizations.selectFilesOptional
                              : '${_selectedFiles.length} file(s) selected',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 8),
                ..._selectedFiles.asMap().entries.map((entry) {
                  return ListTile(
                    title: Text(entry.value.path.split('/').last),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeFile(entry.key),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

