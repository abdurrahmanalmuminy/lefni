import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/models/client_model.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
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
  CaseCategory _selectedCategory = CaseCategory.civil;
  CaseStatus _selectedStatus = CaseStatus.prospect;
  List<String> _selectedCollaborators = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      final case_ = widget.model!;
      _caseNumberController.text = case_.caseNumber;
      _selectedClientId = case_.clientId;
      _selectedLeadLawyerId = case_.leadLawyerId;
      _selectedCategory = case_.category;
      _selectedStatus = case_.status;
      _courtNameController.text = case_.courtDetails.courtName;
      _circuitController.text = case_.courtDetails.circuit;
      _judgeController.text = case_.courtDetails.judge ?? '';
      _selectedCollaborators = case_.collaborators.map((c) => c.userId).toList();
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
          category: _selectedCategory,
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
        category: _selectedCategory,
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
              // Category
              DropdownButtonFormField<CaseCategory>(
                value: _selectedCategory,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.caseType,
                  prefixIcon: Icons.category_outlined,
                ),
                items: CaseCategory.values.map((category) {
                  return DropdownMenuItem<CaseCategory>(
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

