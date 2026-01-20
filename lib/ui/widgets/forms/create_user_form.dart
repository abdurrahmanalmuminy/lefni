import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';

class CreateUserForm extends StatefulWidget {
  final UserRole role;

  const CreateUserForm({
    super.key,
    required this.role,
  });

  @override
  State<CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _firmNameController = TextEditingController();
  final _universityController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _userService = UserService();
  
  bool _obscurePassword = true;
  bool _isTraining = false;
  CooperationType? _cooperationType;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _specializationController.dispose();
    _licenseNumberController.dispose();
    _firmNameController.dispose();
    _universityController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  UserProfile _buildUserProfile() {
    switch (widget.role) {
      case UserRole.lawyer:
        return UserProfile(
          name: _nameController.text.trim(),
          specialization: _specializationController.text.trim().isEmpty
              ? null
              : _specializationController.text.trim(),
        );
      case UserRole.student:
        return UserProfile(
          name: _nameController.text.trim(),
          university: _universityController.text.trim().isEmpty
              ? null
              : _universityController.text.trim(),
          bankAccount: _bankAccountController.text.trim().isEmpty
              ? null
              : _bankAccountController.text.trim(),
          isTraining: _isTraining,
          cooperationType: _cooperationType,
        );
      case UserRole.engineer:
      case UserRole.accountant:
        return UserProfile(
          name: _nameController.text.trim(),
          licenseNumber: _licenseNumberController.text.trim().isEmpty
              ? null
              : _licenseNumberController.text.trim(),
          firmName: _firmNameController.text.trim().isEmpty
              ? null
              : _firmNameController.text.trim(),
        );
      default:
        return UserProfile(name: _nameController.text.trim());
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
      final profile = _buildUserProfile();
      
      await _userService.createUserViaCloudFunction(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        role: widget.role,
        profile: profile,
      );

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.userCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
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

  String _getTitle() {
    final localizations = AppLocalizations.of(context)!;
    switch (widget.role) {
      case UserRole.lawyer:
        return localizations.addLawyer;
      case UserRole.student:
        return localizations.addStudent;
      case UserRole.engineer:
        return localizations.addEngineer;
      case UserRole.accountant:
        return localizations.addAccountant;
      case UserRole.translator:
        return localizations.addTranslator;
      default:
        return localizations.addUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return FormDialog(
      title: _getTitle(),
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
              // Name
              TextFormField(
                controller: _nameController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.name,
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
              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.email,
                  prefixIcon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.emailRequired;
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return localizations.invalidEmail;
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
              ),
              const SizedBox(height: 16),
              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.password,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.passwordRequired;
                  }
                  if (value.length < 6) {
                    return localizations.passwordTooShort;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Role-specific fields
              if (widget.role == UserRole.lawyer) ...[
                TextFormField(
                  controller: _specializationController,
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.specialization,
                    prefixIcon: Icons.work_outline,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (widget.role == UserRole.student) ...[
                TextFormField(
                  controller: _universityController,
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.university,
                    prefixIcon: Icons.school_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bankAccountController,
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.bankAccount,
                    prefixIcon: Icons.account_balance_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(localizations.isTraining),
                  value: _isTraining,
                  onChanged: (value) {
                    setState(() {
                      _isTraining = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<CooperationType>(
                  value: _cooperationType,
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.cooperationType,
                    prefixIcon: Icons.category_outlined,
                  ),
                  items: CooperationType.values.map((type) {
                    return DropdownMenuItem<CooperationType>(
                      value: type,
                      child: Text(
                        type == CooperationType.training
                            ? localizations.training
                            : localizations.caseSourcing,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _cooperationType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (widget.role == UserRole.engineer || widget.role == UserRole.accountant) ...[
                TextFormField(
                  controller: _licenseNumberController,
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.licenseNumber,
                    prefixIcon: Icons.badge_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firmNameController,
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.firmName,
                    prefixIcon: Icons.business_outlined,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

