import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/session_model.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/models/client_model.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/services/firestore/session_service.dart';
import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';
import 'package:intl/intl.dart';

class CreateSessionForm extends StatefulWidget {
  final SessionModel? model;
  
  const CreateSessionForm({super.key, this.model});

  @override
  State<CreateSessionForm> createState() => _CreateSessionFormState();
}

class _CreateSessionFormState extends State<CreateSessionForm> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _sessionService = SessionService();
  final _caseService = CaseService();
  final _clientService = ClientService();
  final _userService = UserService();
  
  String? _selectedCaseId;
  String? _selectedClientId;
  String? _selectedLawyerId;
  DateTime? _selectedDateTime;
  SessionType _selectedType = SessionType.consultation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      final session = widget.model!;
      _selectedCaseId = session.caseId;
      _selectedClientId = session.clientId;
      _selectedLawyerId = session.lawyerId;
      _selectedDateTime = session.scheduledAt;
      _selectedType = session.type;
      _locationController.text = session.location;
      _meetingLinkController.text = session.meetingLink ?? '';
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDateTime != null
            ? TimeOfDay.fromDateTime(_selectedDateTime!)
            : TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _onCaseChanged(String? caseId) {
    setState(() {
      _selectedCaseId = caseId;
      // Auto-populate client from case
      if (caseId != null) {
        _caseService.getCase(caseId).then((case_) {
          if (case_ != null && mounted) {
            setState(() {
              _selectedClientId = case_.clientId;
            });
          }
        });
      }
    });
  }

  Future<void> _submit() async {
    final localizations = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCaseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectCase)),
      );
      return;
    }

    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectClient)),
      );
      return;
    }

    if (_selectedLawyerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectLawyer)),
      );
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectDateTime)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.model != null) {
        // Update existing session
        final session = widget.model!.copyWith(
          caseId: _selectedCaseId!,
          clientId: _selectedClientId!,
          lawyerId: _selectedLawyerId!,
          scheduledAt: _selectedDateTime!,
          type: _selectedType,
          location: _locationController.text.trim(),
          meetingLink: _meetingLinkController.text.trim().isEmpty
              ? null
              : _meetingLinkController.text.trim(),
        );
        await _sessionService.updateSession(session);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الجلسة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new session
      final session = SessionModel(
        id: '',
        caseId: _selectedCaseId!,
        clientId: _selectedClientId!,
        lawyerId: _selectedLawyerId!,
        scheduledAt: _selectedDateTime!,
        type: _selectedType,
        location: _locationController.text.trim(),
        meetingLink: _meetingLinkController.text.trim().isEmpty
            ? null
            : _meetingLinkController.text.trim(),
        remindersSent: RemindersSent(
          sms: false,
          internal: false,
        ),
        status: SessionStatus.scheduled,
        createdAt: DateTime.now(),
      );

      await _sessionService.createSession(session);

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.sessionCreatedSuccessfully),
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
      title: widget.model != null ? 'تعديل الجلسة' : localizations.sessionSchedule,
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
              // Case
              StreamBuilder<List<CaseModel>>(
                stream: _caseService.getCasesByStatus(CaseStatus.active),
                builder: (context, snapshot) {
                  final cases = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedCaseId,
                    decoration: FormFieldStyle.styled(
                      labelText: localizations.cases,
                      prefixIcon: Icons.folder_outlined,
                    ),
                    items: cases.map((case_) {
                      return DropdownMenuItem<String>(
                        value: case_.id,
                        child: Text(case_.caseNumber),
                      );
                    }).toList(),
                    onChanged: _onCaseChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.caseRequired;
                      }
                      return null;
                    },
                  );
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
              // Lawyer
              StreamBuilder<List<UserModel>>(
                stream: _userService.getUsersByRole(UserRole.lawyer),
                builder: (context, snapshot) {
                  final lawyers = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedLawyerId,
                    decoration: FormFieldStyle.styled(
                      labelText: localizations.lawyer,
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
                        _selectedLawyerId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.lawyerRequired;
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Date and time
              InkWell(
                onTap: _selectDateTime,
                child: InputDecorator(
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.dateAndTime,
                    prefixIcon: Icons.calendar_today,
                  ),
                  child: Text(
                    _selectedDateTime != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!)
                        : localizations.selectDateTime,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Type
              DropdownButtonFormField<SessionType>(
                value: _selectedType,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.type,
                  prefixIcon: Icons.category_outlined,
                ),
                items: SessionType.values.map((type) {
                  return DropdownMenuItem<SessionType>(
                    value: type,
                    child: Text(type.localized(localizations)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Location
              TextFormField(
                controller: _locationController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.location,
                  prefixIcon: Icons.location_on_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.locationRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Meeting Link (optional)
              TextFormField(
                controller: _meetingLinkController,
                keyboardType: TextInputType.url,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.meetingLinkOptional,
                  prefixIcon: Icons.link_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

