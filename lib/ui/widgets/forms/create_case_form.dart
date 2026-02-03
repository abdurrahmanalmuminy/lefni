import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/models/client_model.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/services/court_classifications_service.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';

class CreateCaseForm extends StatefulWidget {
  final CaseModel? model;
  
  const CreateCaseForm({super.key, this.model});

  @override
  State<CreateCaseForm> createState() => _CreateCaseFormState();
}

class _CreateCaseFormState extends State<CreateCaseForm> {
  final _formKey = GlobalKey<FormState>();
  final _caseNumberController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _circuitController = TextEditingController();
  final _judgeController = TextEditingController();
  final _caseService = CaseService();
  final _clientService = ClientService();
  final _userService = UserService();
  
  String? _selectedClientId;
  String? _selectedLeadLawyerId;
  // Classification fields from JSON
  List<Map<String, String>> _mainCategories = [];
  List<Map<String, String>> _subCategories = [];
  List<Map<String, dynamic>> _caseTypes = [];
  String? _selectedMainCategory;
  String? _selectedSubCategory;
  Map<String, dynamic>? _selectedCaseType;
  CaseStatus _selectedStatus = CaseStatus.prospect;
  List<String> _selectedCollaborators = [];
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.model != null) {
      final case_ = widget.model!;
      _caseNumberController.text = case_.caseNumber;
      _selectedClientId = case_.clientId;
      _selectedLeadLawyerId = case_.leadLawyerId;
      _selectedMainCategory = case_.category;
      _selectedSubCategory = case_.subCategory;
      _selectedCaseType = case_.caseType;
      _selectedStatus = case_.status;
      _courtNameController.text = case_.courtDetails.courtName;
      _circuitController.text = case_.courtDetails.circuit;
      _judgeController.text = case_.courtDetails.judge ?? '';
      _selectedCollaborators = case_.collaborators.map((c) => c.userId).toList();
    }
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
      // Handle error
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
      // Handle error
    }
  }

  @override
  void dispose() {
    _caseNumberController.dispose();
    _courtNameController.dispose();
    _circuitController.dispose();
    _judgeController.dispose();
    super.dispose();
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

    if (_selectedLeadLawyerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectLeadLawyer)),
      );
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
      final now = DateTime.now();
      
      if (widget.model != null) {
        // Update existing case
        final case_ = widget.model!.copyWith(
          caseNumber: _caseNumberController.text.trim(),
          clientId: _selectedClientId!,
          leadLawyerId: _selectedLeadLawyerId!,
          category: _selectedMainCategory!,
          subCategory: _selectedSubCategory,
          caseType: _selectedCaseType,
          status: _selectedStatus,
          courtDetails: CourtDetails(
            courtName: _courtNameController.text.trim(),
            circuit: _circuitController.text.trim(),
            judge: _judgeController.text.trim().isEmpty
                ? null
                : _judgeController.text.trim(),
          ),
          collaborators: _selectedCollaborators.map((userId) {
            return CaseCollaborator(
              userId: userId,
              role: CollaboratorRole.engineer, // Default, can be enhanced
              assignedAt: now,
            );
          }).toList(),
          updatedAt: now,
        );
        await _caseService.updateCase(case_);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث القضية بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new case
      final case_ = CaseModel(
        id: '',
        caseNumber: _caseNumberController.text.trim(),
        clientId: _selectedClientId!,
        leadLawyerId: _selectedLeadLawyerId!,
        category: _selectedMainCategory!,
        subCategory: _selectedSubCategory,
        caseType: _selectedCaseType,
        status: _selectedStatus,
        courtDetails: CourtDetails(
          courtName: _courtNameController.text.trim(),
          circuit: _circuitController.text.trim(),
          judge: _judgeController.text.trim().isEmpty
              ? null
              : _judgeController.text.trim(),
        ),
        collaborators: _selectedCollaborators.map((userId) {
          return CaseCollaborator(
            userId: userId,
            role: CollaboratorRole.engineer, // Default, can be enhanced
            assignedAt: now,
          );
        }).toList(),
        createdAt: now,
        updatedAt: now,
      );
      await _caseService.createCase(case_);

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.caseCreatedSuccessfully),
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
      title: widget.model != null ? 'تعديل القضية' : localizations.addCase,
      submitLabel: widget.model != null ? 'تحديث' : null,
      isLoading: _isLoading,
      onSubmit: _submit,
      onCancel: () => Navigator.of(context).pop(),
      formContent: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Case Number
              TextFormField(
                controller: _caseNumberController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.caseNumber,
                  prefixIcon: Icons.numbers_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.caseNumberRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
              // Lead Lawyer
              StreamBuilder<List<UserModel>>(
                stream: _userService.getUsersByRole(UserRole.lawyer),
                builder: (context, snapshot) {
                  final lawyers = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedLeadLawyerId,
                    decoration: FormFieldStyle.styled(
                      labelText: localizations.leadLawyer,
                      prefixIcon: Icons.person_outline,
                    ),
                    items: lawyers.map((lawyer) {
                      return DropdownMenuItem<String>(
                        value: lawyer.uid,
                        child: Text(lawyer.profile.name ?? lawyer.email),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLeadLawyerId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.leadLawyerRequired;
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Main Category Dropdown
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
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
              if (!_isLoadingCategories) const SizedBox(height: 16),
              
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
              // Status
              DropdownButtonFormField<CaseStatus>(
                value: _selectedStatus,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.status,
                  prefixIcon: Icons.info_outline,
                ),
                items: CaseStatus.values.map((status) {
                  return DropdownMenuItem<CaseStatus>(
                    value: status,
                    child: Text(status.localized(localizations)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Court Name
              TextFormField(
                controller: _courtNameController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.court,
                  prefixIcon: Icons.account_balance_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.courtNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Circuit
              TextFormField(
                controller: _circuitController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.department,
                  prefixIcon: Icons.location_on_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.circuitRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Judge (optional)
              TextFormField(
                controller: _judgeController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.judgeOptional,
                  prefixIcon: Icons.gavel_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

