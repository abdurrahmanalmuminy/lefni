import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:provider/provider.dart';
import 'package:lefni/models/consultation_model.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/models/document_model.dart';
import 'package:lefni/services/firestore/consultation_service.dart';
import 'package:lefni/services/court_classifications_service.dart';
import 'package:lefni/services/storage/file_service.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';
import 'package:lefni/exceptions/app_exceptions.dart';
import 'package:lefni/utils/logger.dart';

class CreateConsultationForm extends StatefulWidget {
  final ConsultationModel? model;
  
  const CreateConsultationForm({super.key, this.model});

  @override
  State<CreateConsultationForm> createState() => _CreateConsultationFormState();
}

class _CreateConsultationFormState extends State<CreateConsultationForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _consultationService = ConsultationService();
  final _fileService = FileService();
  
  List<Map<String, String>> _mainCategories = [];
  List<Map<String, String>> _subCategories = [];
  List<Map<String, dynamic>> _caseTypes = [];
  
  String? _selectedMainCategory;
  String? _selectedSubCategory;
  Map<String, dynamic>? _selectedCaseType;
  List<String> _attachmentUrls = [];
  List<String> _attachmentFileNames = [];
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.model != null) {
      final consultation = widget.model!;
      _selectedMainCategory = consultation.category;
      _selectedSubCategory = consultation.subCategory;
      _selectedCaseType = consultation.caseType;
      _descriptionController.text = consultation.description;
      _attachmentUrls = List.from(consultation.attachments);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CourtClassificationsService.getMainCategories();
      setState(() {
        _mainCategories = categories;
        _isLoadingCategories = false;
      });
      
      // If editing, load sub-categories and case types
      if (widget.model != null && _selectedMainCategory != null) {
        await _loadSubCategories(_selectedMainCategory!);
        if (_selectedSubCategory != null) {
          await _loadCaseTypes(_selectedMainCategory!, _selectedSubCategory!);
        }
      }
    } catch (e) {
      AppLogger.error('Failed to load categories', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل التصنيفات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadSubCategories(String mainCategory) async {
    try {
      final subCategories = await CourtClassificationsService.getSubCategories(mainCategory);
      setState(() {
        _subCategories = subCategories;
        // Reset sub-category and case type when main category changes
        if (widget.model == null || _selectedMainCategory != widget.model!.category) {
          _selectedSubCategory = null;
          _selectedCaseType = null;
          _caseTypes = [];
        }
      });
    } catch (e) {
      AppLogger.error('Failed to load sub-categories', e);
    }
  }

  Future<void> _loadCaseTypes(String mainCategory, String subCategory) async {
    try {
      final caseTypes = await CourtClassificationsService.getCaseTypes(mainCategory, subCategory);
      setState(() {
        _caseTypes = caseTypes;
        // Reset case type when sub-category changes
        if (widget.model == null || _selectedSubCategory != widget.model!.subCategory) {
          _selectedCaseType = null;
        }
      });
    } catch (e) {
      AppLogger.error('Failed to load case types', e);
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await file_picker.FilePicker.platform.pickFiles(
        type: file_picker.FileType.any,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });

        final newUrls = <String>[];
        final newNames = <String>[];
        final userSession = Provider.of<UserSessionProvider>(context, listen: false);
        final clientId = userSession.firebaseUser?.uid;

        for (final file in result.files) {
          if (file.path != null) {
            try {
              final fileName = file.name;
              final fileToUpload = File(file.path!);
              
              // Upload file
              final url = await _fileService.uploadFile(
                file: fileToUpload,
                fileName: fileName,
                category: DocumentCategory.other,
                clientId: clientId,
              );
              newUrls.add(url);
              newNames.add(fileName);
            } catch (e) {
              AppLogger.error('Failed to upload file: ${file.name}', e);
            }
          }
        }

        setState(() {
          _attachmentUrls.addAll(newUrls);
          _attachmentFileNames.addAll(newNames);
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to pick files', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachmentUrls.removeAt(index);
      _attachmentFileNames.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMainCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التصنيف الرئيسي')),
      );
      return;
    }

    if (_selectedCaseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار نوع القضية')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userSession = Provider.of<UserSessionProvider>(context, listen: false);
      final currentUser = userSession.firebaseUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // For clients, use their own uid as clientId
      final clientId = userSession.userRole == UserRole.client 
          ? currentUser.uid 
          : (widget.model?.clientId ?? currentUser.uid);

      if (widget.model != null) {
        // Update existing consultation
        final consultation = ConsultationModel(
          id: widget.model!.id,
          clientId: clientId,
          category: _selectedMainCategory!,
          subCategory: _selectedSubCategory,
          caseType: _selectedCaseType,
          description: _descriptionController.text.trim(),
          status: widget.model!.status,
          assignedLawyerId: widget.model!.assignedLawyerId,
          assignedAt: widget.model!.assignedAt,
          response: widget.model!.response,
          responseAt: widget.model!.responseAt,
          attachments: _attachmentUrls,
          createdAt: widget.model!.createdAt,
          updatedAt: DateTime.now(),
        );
        await _consultationService.updateConsultation(consultation);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الاستشارة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new consultation
        final consultation = ConsultationModel(
          id: '',
          clientId: clientId,
          category: _selectedMainCategory!,
          subCategory: _selectedSubCategory,
          caseType: _selectedCaseType,
          description: _descriptionController.text.trim(),
          status: ConsultationStatus.pending,
          attachments: _attachmentUrls,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _consultationService.createConsultation(consultation);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الاستشارة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'حدث خطأ';
        if (e is FirestoreException) {
          errorMessage = e.message;
        } else if (e is StorageException) {
          errorMessage = e.message;
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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
    return FormDialog(
      title: widget.model != null ? 'تعديل الاستشارة' : 'طلب استشارة',
      isLoading: _isLoading,
      onSubmit: _submit,
      onCancel: () => Navigator.of(context).pop(),
      submitLabel: widget.model != null ? 'تحديث' : 'إرسال',
      cancelLabel: 'إلغاء',
      formContent: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedMainCategory,
                    decoration: FormFieldStyle.styled(
                      labelText: 'التصنيف الرئيسي',
                      prefixIcon: Icons.category_outlined,
                    ),
                    items: _mainCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['key'] ?? '',
                        child: Text(category['ar'] ?? category['key'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        _selectedMainCategory = value;
                        _selectedSubCategory = null;
                        _selectedCaseType = null;
                        _subCategories = [];
                        _caseTypes = [];
                      });
                      if (value != null) {
                        await _loadSubCategories(value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى اختيار التصنيف الرئيسي';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Sub-Category Dropdown (only if main category selected)
                  if (_selectedMainCategory != null && _subCategories.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _selectedSubCategory,
                      decoration: FormFieldStyle.styled(
                        labelText: 'التصنيف الفرعي',
                        prefixIcon: Icons.subdirectory_arrow_right,
                      ),
                      items: _subCategories.map((subCategory) {
                        return DropdownMenuItem<String>(
                          value: subCategory['key'] ?? '',
                          child: Text(subCategory['ar'] ?? subCategory['key'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() {
                          _selectedSubCategory = value;
                          _selectedCaseType = null;
                          _caseTypes = [];
                        });
                        if (value != null && _selectedMainCategory != null) {
                          await _loadCaseTypes(_selectedMainCategory!, value);
                        }
                      },
                    ),
                  if (_selectedMainCategory != null && _subCategories.isNotEmpty)
                    const SizedBox(height: 16),
                  
                  // Case Type Dropdown (only if sub-category selected)
                  if (_selectedSubCategory != null && _caseTypes.isNotEmpty)
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedCaseType,
                      decoration: FormFieldStyle.styled(
                        labelText: 'نوع القضية',
                        prefixIcon: Icons.gavel,
                      ),
                      items: _caseTypes.map((caseType) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: caseType,
                          child: Text(caseType['ar'] as String? ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCaseType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'يرجى اختيار نوع القضية';
                        }
                        return null;
                      },
                    ),
                  if (_selectedSubCategory != null && _caseTypes.isNotEmpty)
                    const SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: FormFieldStyle.styled(
                      labelText: 'وصف الاستشارة',
                      prefixIcon: Icons.description_outlined,
                      hintText: 'يرجى وصف الاستشارة بالتفصيل...',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال وصف الاستشارة';
                      }
                      if (value.trim().length < 10) {
                        return 'يجب أن يكون الوصف على الأقل 10 أحرف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // File Attachments
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _pickFiles,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('إرفاق ملفات'),
                      ),
                      if (_attachmentFileNames.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...List.generate(_attachmentFileNames.length, (index) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.insert_drive_file, size: 20),
                            title: Text(
                              _attachmentFileNames[index],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => _removeAttachment(index),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
