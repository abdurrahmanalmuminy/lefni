import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/document_model.dart';
import 'package:lefni/models/client_model.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/services/firestore/document_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/services/storage/file_service.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';

class CreateDocumentForm extends StatefulWidget {
  final DocumentModel? model;
  
  const CreateDocumentForm({super.key, this.model});

  @override
  State<CreateDocumentForm> createState() => _CreateDocumentFormState();
}

class _CreateDocumentFormState extends State<CreateDocumentForm> {
  final _formKey = GlobalKey<FormState>();
  final _documentService = DocumentService();
  final _fileService = FileService();
  final _clientService = ClientService();
  final _caseService = CaseService();
  
  File? _selectedFile;
  DocumentCategory _selectedCategory = DocumentCategory.officeDoc;
  String? _selectedClientId;
  String? _selectedCaseId;
  bool _isLoading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      final document = widget.model!;
      _selectedCategory = document.category;
      _selectedClientId = document.clientId;
      _selectedCaseId = document.caseId;
      // Note: File cannot be changed when editing, only metadata
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await file_picker.FilePicker.platform.pickFiles(
        type: file_picker.FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  FileType _getFileTypeFromExtension(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return FileType.pdf;
      case 'doc':
      case 'docx':
        return FileType.word;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return FileType.image;
      case 'xls':
      case 'xlsx':
        return FileType.excel;
      default:
        return FileType.other;
    }
  }

  Future<void> _submit() async {
    final localizations = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.model == null && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectFile)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0.0;
    });

    try {
      final userSession = Provider.of<UserSessionProvider>(context, listen: false);
      final currentUser = userSession.firebaseUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (widget.model != null) {
        // Update existing document metadata only (file cannot be changed)
        final document = DocumentModel(
          id: widget.model!.id,
          fileName: widget.model!.fileName,
          fileUrl: widget.model!.fileUrl,
          fileType: widget.model!.fileType,
          category: _selectedCategory,
          caseId: _selectedCaseId,
          clientId: _selectedClientId,
          uploaderUid: widget.model!.uploaderUid,
          uploadedAt: widget.model!.uploadedAt,
          fileSize: widget.model!.fileSize,
        );
        await _documentService.updateDocument(document);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث المستند بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new document
      final fileName = _selectedFile!.path.split('/').last;
      final fileSize = await _selectedFile!.length();
      final fileType = _getFileTypeFromExtension(fileName);

      // Upload file
      final fileUrl = await _fileService.uploadFile(
        file: _selectedFile!,
        fileName: fileName,
        category: _selectedCategory,
        caseId: _selectedCaseId,
        clientId: _selectedClientId,
      );

      // Create document
      final document = DocumentModel(
        id: '',
        fileName: fileName,
        fileUrl: fileUrl,
        fileType: fileType,
        category: _selectedCategory,
        caseId: _selectedCaseId,
        clientId: _selectedClientId,
        uploaderUid: currentUser.uid,
        uploadedAt: DateTime.now(),
        fileSize: fileSize,
      );

      await _documentService.createDocument(document);

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.documentUploadedSuccessfully),
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
          _uploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return FormDialog(
      title: widget.model != null ? 'تعديل المستند' : localizations.uploadFiles,
      isLoading: _isLoading,
      onSubmit: _submit,
      onCancel: () => Navigator.of(context).pop(),
      submitLabel: widget.model != null ? 'تحديث' : null,
      formContent: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // File picker
            InkWell(
              onTap: _pickFile,
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
                        _selectedFile != null
                            ? _selectedFile!.path.split('/').last
                            : widget.model != null
                                ? widget.model!.fileName
                            : localizations.selectFile,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading && _uploadProgress > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _uploadProgress),
            ],
            const SizedBox(height: 16),
            // Category
            DropdownButtonFormField<DocumentCategory>(
              value: _selectedCategory,
              decoration: FormFieldStyle.styled(
                labelText: localizations.category,
                prefixIcon: Icons.folder_outlined,
              ),
              items: DocumentCategory.values.map((category) {
                return DropdownMenuItem<DocumentCategory>(
                  value: category,
                  child: Text(category.localized(localizations)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Client (optional)
            StreamBuilder<List<ClientModel>>(
              stream: _clientService.getAllClients(),
              builder: (context, snapshot) {
                final clients = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  value: _selectedClientId,
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.clientOptional,
                    prefixIcon: Icons.person_outline,
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(localizations.none),
                    ),
                    ...clients.map((client) {
                      return DropdownMenuItem<String>(
                        value: client.id,
                        child: Text(client.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedClientId = value;
                    });
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
          ],
        ),
      ),
    );
  }
}

