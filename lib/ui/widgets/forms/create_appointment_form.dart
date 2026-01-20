import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/appointment_model.dart';
import 'package:lefni/models/client_model.dart';
import 'package:lefni/services/firestore/appointment_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';
import 'package:intl/intl.dart';

class CreateAppointmentForm extends StatefulWidget {
  final AppointmentModel? model;
  
  const CreateAppointmentForm({super.key, this.model});

  @override
  State<CreateAppointmentForm> createState() => _CreateAppointmentFormState();
}

class _CreateAppointmentFormState extends State<CreateAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _appointmentService = AppointmentService();
  final _clientService = ClientService();
  
  String? _selectedClientId;
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      final appointment = widget.model!;
      _selectedClientId = appointment.clientId;
      _selectedDateTime = appointment.dateTime;
      _purposeController.text = appointment.purpose;
    }
  }

  @override
  void dispose() {
    _purposeController.dispose();
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
      final userSession = Provider.of<UserSessionProvider>(context, listen: false);
      final currentUser = userSession.firebaseUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (widget.model != null) {
        // Update existing appointment
        final appointment = AppointmentModel(
          id: widget.model!.id,
          clientId: _selectedClientId!,
          dateTime: _selectedDateTime!,
          purpose: _purposeController.text.trim(),
          status: widget.model!.status,
          smsReminderSent: widget.model!.smsReminderSent,
          reminderSentAt: widget.model!.reminderSentAt,
          createdBy: widget.model!.createdBy,
          createdAt: widget.model!.createdAt,
        );
        await _appointmentService.updateAppointment(appointment);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الموعد بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new appointment
        final appointment = AppointmentModel(
          id: '',
          clientId: _selectedClientId!,
          dateTime: _selectedDateTime!,
          purpose: _purposeController.text.trim(),
          status: AppointmentStatus.scheduled,
          smsReminderSent: false,
          createdBy: currentUser.uid,
          createdAt: DateTime.now(),
        );

        await _appointmentService.createAppointment(appointment);

        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.appointmentCreatedSuccessfully),
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
      title: widget.model != null ? 'تعديل الموعد' : localizations.appointmentScheduling,
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
            // Client dropdown
            StreamBuilder<List<ClientModel>>(
              stream: _clientService.getAllClients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
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
              // Date and time picker
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
            // Purpose
            TextFormField(
              controller: _purposeController,
              decoration: FormFieldStyle.styled(
                labelText: localizations.purpose,
                prefixIcon: Icons.description_outlined,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.purposeRequired;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

