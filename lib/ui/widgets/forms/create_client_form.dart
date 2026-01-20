import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/client_model.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/storage/file_service.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';

class CreateClientForm extends StatefulWidget {
  final ClientModel? model;
  
  const CreateClientForm({super.key, this.model});

  @override
  State<CreateClientForm> createState() => _CreateClientFormState();
}

class _CreateClientFormState extends State<CreateClientForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identityNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _agencyNumberController = TextEditingController();
  final _clientService = ClientService();
  final _fileService = FileService();
  
  ClientType _selectedType = ClientType.individual;
  File? _agencyFile;
  bool _hasAgency = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      final client = widget.model!;
      _selectedType = client.type;
      _nameController.text = client.name;
      _identityNumberController.text = client.identityNumber;
      _phoneController.text = client.contact.phone;
      _emailController.text = client.contact.email;
      _addressController.text = client.contact.address;
      _hasAgency = client.agencyData != null;
      if (client.agencyData != null) {
        _agencyNumberController.text = client.agencyData!.agencyNumber;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identityNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _agencyNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickAgencyFile() async {
    try {
      final result = await file_picker.FilePicker.platform.pickFiles(
        type: file_picker.FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _agencyFile = File(result.files.single.path!);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.model != null) {
        // Update existing client
        final existingClient = widget.model!;
        final updatedClient = existingClient.copyWith(
          type: _selectedType,
          identityNumber: _identityNumberController.text.trim(),
          name: _nameController.text.trim(),
          contact: ClientContact(
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            address: _addressController.text.trim(),
          ),
        );

        // Handle agency data
        if (_hasAgency && _agencyNumberController.text.isNotEmpty) {
          String? agencyAttachmentUrl = existingClient.agencyData?.attachmentUrl;
          
          // Upload new agency file if provided
          if (_agencyFile != null) {
            final fileName = _agencyFile!.path.split('/').last;
            agencyAttachmentUrl = await _fileService.uploadAgencyImage(
              file: _agencyFile!,
              clientId: existingClient.id,
              fileName: fileName,
            );
          }
          
          final finalClient = updatedClient.copyWith(
            agencyData: AgencyData(
              agencyNumber: _agencyNumberController.text.trim(),
              attachmentUrl: agencyAttachmentUrl ?? '',
            ),
          );
          await _clientService.updateClient(finalClient);
        } else {
          await _clientService.updateClient(updatedClient.copyWith(agencyData: null));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث العميل بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new client
      final client = ClientModel(
        id: '',
        type: _selectedType,
        identityNumber: _identityNumberController.text.trim(),
        name: _nameController.text.trim(),
        contact: ClientContact(
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
        ),
        agencyData: null, // Will be set after client creation if needed
        stats: ClientStats(
          activeCases: 0,
          totalInvoiced: 0.0,
        ),
        createdAt: DateTime.now(),
      );

      final clientId = await _clientService.createClient(client);
      
      // Upload agency file if provided (after client creation to get correct clientId)
      if (_hasAgency && _agencyFile != null && _agencyNumberController.text.isNotEmpty) {
        final fileName = _agencyFile!.path.split('/').last;
        final agencyAttachmentUrl = await _fileService.uploadAgencyImage(
          file: _agencyFile!,
          clientId: clientId,
          fileName: fileName,
        );
        // Update client with agency data
        final updatedClient = client.copyWith(
          id: clientId,
          agencyData: AgencyData(
            agencyNumber: _agencyNumberController.text.trim(),
            attachmentUrl: agencyAttachmentUrl,
          ),
        );
        await _clientService.updateClient(updatedClient);
      }

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.clientCreatedSuccessfully),
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
      title: widget.model != null ? 'تعديل العميل' : localizations.addClient,
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
              // Type
              DropdownButtonFormField<ClientType>(
                value: _selectedType,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.type,
                  prefixIcon: Icons.category_outlined,
                ),
                items: ClientType.values.map((type) {
                  return DropdownMenuItem<ClientType>(
                    value: type,
                    child: Text(type.value),
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
              // Identity Number
              TextFormField(
                controller: _identityNumberController,
                decoration: FormFieldStyle.styled(
                  labelText: _selectedType == ClientType.individual
                      ? localizations.idNumber
                      : localizations.crNumber,
                  prefixIcon: Icons.badge_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.identityNumberRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Name
              TextFormField(
                controller: _nameController,
                decoration: FormFieldStyle.styled(
                  labelText: 'Name',
                  prefixIcon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.nameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.phoneNumber,
                  prefixIcon: Icons.phone_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.phoneNumberRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.email,
                  prefixIcon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Address
              TextFormField(
                controller: _addressController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.address,
                  prefixIcon: Icons.location_on_outlined,
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.addressRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Agency checkbox
              CheckboxListTile(
                title: Text(localizations.hasAgency),
                value: _hasAgency,
                onChanged: (value) {
                  setState(() {
                    _hasAgency = value ?? false;
                  });
                },
              ),
              // Agency fields (if has agency)
              if (_hasAgency) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _agencyNumberController,
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.agencyNumber,
                    prefixIcon: Icons.description_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickAgencyFile,
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
                            _agencyFile != null
                                ? _agencyFile!.path.split('/').last
                                : localizations.selectAgencyFile,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

