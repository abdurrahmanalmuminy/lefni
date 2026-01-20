import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/services/auth/auth_service.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/services/geographic_service.dart';
import 'package:intl/intl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _firmNameController = TextEditingController();
  final _universityController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _authService = AuthService();
  final _otpController = TextEditingController();
  final _licenseExpiryDateController = TextEditingController();
  final _experienceController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _collaborationNatureController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSignUpMode = false;
  bool _isPhoneAuth = false; // Toggle between email/password and phone auth
  bool _isCodeSent = false; // Whether OTP code has been sent
  bool _isPhoneVerified = false; // Whether phone OTP has been verified (for signup)
  int _signUpStep = 1; // 1 = account info, 2 = profile info
  UserRole _selectedRole = UserRole.client;
  bool _isTraining = false;
  CooperationType? _cooperationType;
  LicenseType? _selectedLicenseType;
  String? _selectedSpecialization;
  String? _errorMessage;
  String? _selectedRegion; // Selected region
  String? _selectedCity; // Selected city
  List<String> _regions = [];
  List<String> _cities = [];
  bool _isLoadingGeoData = false;

  @override
  void initState() {
    super.initState();
    _loadGeographicData();
  }

  Future<void> _loadGeographicData() async {
    setState(() {
      _isLoadingGeoData = true;
    });
    try {
      _regions = await GeographicService.getRegions();
      if (_selectedRegion != null) {
        _cities = await GeographicService.getCitiesForRegion(_selectedRegion!);
      }
    } catch (e) {
      // Handle error silently or show a message
      debugPrint('Error loading geographic data: $e');
    } finally {
      setState(() {
        _isLoadingGeoData = false;
      });
    }
  }

  Future<void> _onRegionChanged(String? region) async {
    setState(() {
      _selectedRegion = region;
      _selectedCity = null; // Reset city when region changes
      _cities = [];
    });
    if (region != null) {
      try {
        final cities = await GeographicService.getCitiesForRegion(region);
        setState(() {
          _cities = cities;
        });
      } catch (e) {
        debugPrint('Error loading cities: $e');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _specializationController.dispose();
    _licenseNumberController.dispose();
    _firmNameController.dispose();
    _universityController.dispose();
    _bankAccountController.dispose();
    _licenseExpiryDateController.dispose();
    _experienceController.dispose();
    _idNumberController.dispose();
    _collaborationNatureController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Navigation will be handled by AuthGate
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePhoneAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Phone number is required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithPhoneNumber(phoneNumber);
      setState(() {
        _isCodeSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerifyOTP() async {
    final otpCode = _otpController.text.trim();
    if (otpCode.isEmpty || otpCode.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUpMode) {
        // For signup, verify OTP but don't create user yet (we'll do that after region/city selection)
        // We verify the code to ensure it's valid, but delay user creation
        // Note: Firebase Auth will sign in the user, but we'll handle Firestore user/client creation later
        await _authService.verifyPhoneNumber(
          otpCode,
          isSignUp: false,
          prepareSignup: true, // Don't create Firestore user yet
        );
        setState(() {
          _isPhoneVerified = true;
          _isLoading = false;
        });
      } else {
        // For login, verify and sign in
        await _authService.verifyPhoneNumber(
          otpCode,
          isSignUp: false,
        );
        // Navigation will be handled by AuthGate
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCompletePhoneSignup() async {
    if (_selectedRegion == null || _selectedCity == null) {
      setState(() {
        _errorMessage = 'Please select both region and city';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Complete signup with region and city
      // The user is already authenticated from OTP verification, now create Firestore user/client
      await _authService.completePhoneSignup(
        region: _selectedRegion!,
        city: _selectedCity!,
      );
      // Navigation will be handled by AuthGate
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Get localized role label
  String _getRoleLabel(UserRole role, AppLocalizations localizations) {
    switch (role) {
      case UserRole.admin:
        return 'مدير'; // Admin
      case UserRole.lawyer:
        return localizations.partyTypeLawyer;
      case UserRole.student:
        return 'طالب'; // Student
      case UserRole.engineer:
        return localizations.partyTypeEngineer;
      case UserRole.accountant:
        return localizations.partyTypeAccountant;
      case UserRole.translator:
        return localizations.partyTypeTranslator;
      case UserRole.client:
        return localizations.partyTypeClient;
    }
  }

  // Get list of specializations
  List<String> _getSpecializations() {
    return [
      'جنائي',
      'الأحوال المدنية',
      'تنفيذ / إيقاف خدمات',
      'العمل',
      'الأحوال الشخصية',
      'التحكيم',
      'جرائم إلكترونية',
      'طبي',
      'نصب واحتيال',
      'المعاملات المدنية',
      'تعويض',
      'شركات',
      'تجاري',
      'غرفة تجارية وسجلات تجارية',
      'بحري',
      'جوي',
      'مروري',
      'مالي / زكاة / ضرائب',
      'عقارات',
      'حقوقي',
      'الأوقاف والوصايا',
      'التركات',
      'ملكية فكرية',
      'اختصاص دولي - قانون دولي خاص',
      'القانون الواجب التطبيق على المنازعات ذات العنصر الأجنبي',
      'تنفيذ الأحكام الأجنبية',
      'الجنسية',
      'المركز القانوني للأجانب',
      'أخرى',
    ];
  }

  Future<void> _handleResendCode() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Phone number is required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.resendVerificationCode(phoneNumber);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code resent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _nextStep() {
    if (_signUpStep == 1) {
      // Validate step 1
      if (!_formKey.currentState!.validate()) {
        return;
      }
      setState(() {
        _signUpStep = 2;
        _errorMessage = null;
      });
    }
  }

  void _previousStep() {
    if (_signUpStep == 2) {
      setState(() {
        _signUpStep = 1;
        _errorMessage = null;
      });
    }
  }

  UserProfile _buildUserProfile() {
    final name = _nameController.text.trim().isEmpty
        ? null
        : _nameController.text.trim();
    
    // Parse license expiry date if provided
    DateTime? licenseExpiryDate;
    if (_licenseExpiryDateController.text.trim().isNotEmpty) {
      try {
        licenseExpiryDate = DateFormat('yyyy-MM-dd').parse(_licenseExpiryDateController.text.trim());
      } catch (e) {
        // Invalid date format, will be null
      }
    }
    
    switch (_selectedRole) {
      case UserRole.lawyer:
      case UserRole.engineer:
      case UserRole.accountant:
      case UserRole.translator:
        // For non-client users, include license and registration info
        return UserProfile(
          name: name,
          specialization: _selectedSpecialization,
          licenseType: _selectedLicenseType,
          licenseNumber: _licenseNumberController.text.trim().isEmpty
              ? null
              : _licenseNumberController.text.trim(),
          licenseExpiryDate: licenseExpiryDate,
          experience: _experienceController.text.trim().isEmpty
              ? null
              : _experienceController.text.trim(),
          region: _selectedRegion,
          city: _selectedCity,
          idNumber: _idNumberController.text.trim().isEmpty
              ? null
              : _idNumberController.text.trim(),
          collaborationNature: _collaborationNatureController.text.trim().isEmpty
              ? null
              : _collaborationNatureController.text.trim(),
          // Keep existing fields for backward compatibility
          firmName: _firmNameController.text.trim().isEmpty
              ? null
              : _firmNameController.text.trim(),
        );
      case UserRole.student:
        return UserProfile(
          name: name,
          university: _universityController.text.trim().isEmpty
              ? null
              : _universityController.text.trim(),
          bankAccount: _bankAccountController.text.trim().isEmpty
              ? null
              : _bankAccountController.text.trim(),
          isTraining: _isTraining,
          cooperationType: _cooperationType,
          region: _selectedRegion,
          city: _selectedCity,
        );
      default:
        return UserProfile(
          name: name,
          region: _selectedRegion,
          city: _selectedCity,
        );
    }
  }

  Future<void> _handleSignUp() async {
    // Validate region and city are selected
    if (_selectedRegion == null || _selectedCity == null) {
      setState(() {
        _errorMessage = 'يرجى اختيار المنطقة والمدينة';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = _buildUserProfile();
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        role: _selectedRole,
        profile: profile,
      );

      // Show success message
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.accountCreated),
            backgroundColor: Colors.green,
          ),
        );
      }
      // Reset loading state - AuthGate will handle navigation automatically
      // when it detects the authenticated state change
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // Navigation will be handled by AuthGate when it detects authenticated state
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Title
                    Image.asset("assets/branding/lefni.png", height: 50, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null),
                    // const SizedBox(height: 16),
                    // Text(
                    //   localizations.appTitle,
                    //   style: theme.textTheme.headlineMedium?.copyWith(
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                    const SizedBox(height: 48),
            
                    // Auth method toggle (only in login mode or signup step 1)
                    if (!_isSignUpMode || _signUpStep == 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isPhoneAuth = false;
                                      _isCodeSent = false;
                                      _errorMessage = null;
                                      _otpController.clear();
                                    });
                                  },
                            child: Text(
                              localizations.email,
                              style: TextStyle(
                                color: !_isPhoneAuth
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: !_isPhoneAuth
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Text(' | ', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
                          TextButton(
                            onPressed: null,
                            // onPressed: _isLoading
                            //     ? null
                            //     : () {
                            //         setState(() {
                            //       _isPhoneAuth = true;
                            //       _isCodeSent = false;
                            //       _isPhoneVerified = false;
                            //       _errorMessage = null;
                            //       _otpController.clear();
                            //       _selectedRegion = null;
                            //       _selectedCity = null;
                            //     });
                            //   },
                            child: Text(
                              localizations.phoneNumber,
                              style: TextStyle(
                                color: _isPhoneAuth
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: _isPhoneAuth
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (!_isSignUpMode || _signUpStep == 1) const SizedBox(height: 16),
            
                    // Step indicator (only in sign-up mode)
                    if (_isSignUpMode)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${localizations.step} $_signUpStep ${localizations.stepOf} 2',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    if (_isSignUpMode) const SizedBox(height: 24),
            
                    // Step 1: Account Information (Email/Password or Phone)
                    if (!_isSignUpMode || _signUpStep == 1) ...[
                      // Phone Auth Fields
                      if (_isPhoneAuth) ...[
                        // Phone number field
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          textAlign: TextAlign.left,
                          enabled: !_isCodeSent,
                          decoration: InputDecoration(
                            labelText: localizations.phoneNumber,
                            prefixIcon: const Icon(Icons.phone_outlined),
                            hintText: '+9665........',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (!_isCodeSent && (value == null || value.isEmpty)) {
                              return 'Phone number is required';
                            }
                            if (!_isCodeSent && value != null && value.length < 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // OTP Code field (shown after code is sent, before verification)
                        if (_isCodeSent && !_isPhoneVerified) ...[
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            maxLength: 6,
                            decoration: InputDecoration(
                              labelText: 'Verification Code',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              hintText: '000000',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              counterText: '',
                            ),
                            validator: (value) {
                              if (_isCodeSent && (value == null || value.isEmpty)) {
                                return 'Verification code is required';
                              }
                              if (_isCodeSent && value != null && value.length != 6) {
                                return 'Please enter a valid 6-digit code';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _isLoading ? null : _handleResendCode,
                                child: const Text('Resend Code'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                      ] else ...[
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: localizations.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                      ],
            
                      // Password field (only for email auth)
                      if (!_isPhoneAuth) ...[
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: _isSignUpMode ? TextInputAction.next : TextInputAction.done,
                          onFieldSubmitted: _isSignUpMode ? null : (_) => _handleSignIn(),
                          decoration: InputDecoration(
                            labelText: localizations.password,
                            prefixIcon: const Icon(Icons.lock_outlined),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
            
                        // Confirm Password field (only in sign-up mode step 1)
                        if (_isSignUpMode)
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _nextStep(),
                            decoration: InputDecoration(
                              labelText: localizations.confirmPassword,
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (_isSignUpMode) {
                                if (value == null || value.isEmpty) {
                                  return localizations.passwordRequired;
                                }
                                if (value != _passwordController.text) {
                                  return localizations.passwordsDoNotMatch;
                                }
                              }
                              return null;
                            },
                          ),
                      ],
                    ],
            
                      // Step 2: Profile Information (only in sign-up mode with email auth)
                      if (_isSignUpMode && _signUpStep == 2 && !_isPhoneAuth) ...[
                        // Name field
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: localizations.name,
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return localizations.nameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Role selection
                        DropdownButtonFormField<UserRole>(
                          initialValue: _selectedRole,
                          decoration: InputDecoration(
                            labelText: localizations.role,
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: UserRole.values.map((role) {
                            return DropdownMenuItem<UserRole>(
                              value: role,
                              child: Text(_getRoleLabel(role, localizations)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedRole = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
            
                          // Phone Number (optional for email signup)
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: localizations.phoneNumber,
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Region dropdown (required for all users)
                          if (_isLoadingGeoData)
                            const Center(child: CircularProgressIndicator())
                          else
                            DropdownButtonFormField<String>(
                              value: _selectedRegion,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'المنطقة',
                                prefixIcon: const Icon(Icons.map_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _regions.map((region) {
                                return DropdownMenuItem<String>(
                                  value: region,
                                  child: Text(
                                    region,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: _onRegionChanged,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'المنطقة مطلوبة';
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 16),
                          
                          // City dropdown (required for all users, enabled when region is selected)
                          if (_isLoadingGeoData)
                            const SizedBox.shrink()
                          else
                            DropdownButtonFormField<String>(
                              value: _selectedCity,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'المدينة',
                                prefixIcon: const Icon(Icons.location_city_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _cities.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(
                                    city,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: _selectedRegion != null
                                  ? (value) {
                                      setState(() {
                                        _selectedCity = value;
                                      });
                                    }
                                  : null,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'المدينة مطلوبة';
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 16),
            
                      // Role-specific fields
                      // Non-client fields: License Type and Specialization
                      if (_selectedRole != UserRole.client) ...[
                        // License Type dropdown
                        DropdownButtonFormField<LicenseType>(
                          value: _selectedLicenseType,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'نوع الرخصة',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: LicenseType.values.map((type) {
                            return DropdownMenuItem<LicenseType>(
                              value: type,
                              child: Text(
                                type.arabicLabel,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLicenseType = value;
                            });
                          },
                          validator: (value) {
                            if (_selectedRole != UserRole.client && value == null) {
                              return 'يرجى اختيار نوع الرخصة';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Specialization dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedSpecialization,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'التخصص',
                            prefixIcon: const Icon(Icons.work_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _getSpecializations().map((spec) {
                            return DropdownMenuItem<String>(
                              value: spec,
                              child: Text(
                                spec,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSpecialization = value;
                            });
                          },
                          validator: (value) {
                            if (_selectedRole != UserRole.client && value == null) {
                              return 'يرجى اختيار التخصص';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Registration Information based on License Type
                        if (_selectedLicenseType != null) ...[
                          // ID Number
                          TextFormField(
                            controller: _idNumberController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'رقم الهوية',
                              prefixIcon: const Icon(Icons.credit_card_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'رقم الهوية مطلوب';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // License Number (required for all except collaborator)
                          if (_selectedLicenseType != LicenseType.collaborator) ...[
                            TextFormField(
                              controller: _licenseNumberController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'رقم رخصة المحاماة',
                                prefixIcon: const Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'رقم رخصة المحاماة مطلوب';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // License Expiry Date
                            TextFormField(
                              controller: _licenseExpiryDateController,
                              readOnly: true,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  _licenseExpiryDateController.text = DateFormat('yyyy-MM-dd').format(date);
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'تاريخ سريان الرخصة',
                                prefixIcon: const Icon(Icons.calendar_today_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'تاريخ سريان الرخصة مطلوب';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Experience
                            TextFormField(
                              controller: _experienceController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'الخبرة',
                                prefixIcon: const Icon(Icons.work_history_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الخبرة مطلوبة';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Email (already have email from step 1, but show it here for clarity)
                            // Phone Number (already have phone from step 1)
                            // City is selected in step 2 above
                          ] else ...[
                            // For collaborator: License Number (optional)
                            TextFormField(
                              controller: _licenseNumberController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'رقم رخصة المحاماة (إن وُجد)',
                                prefixIcon: const Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Phone Number (already have phone from step 1)
                            // City is selected in step 2 above
                            
                            // Collaboration Nature
                            TextFormField(
                              controller: _collaborationNatureController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'تحديد طبيعة التعاون',
                                hintText: 'استشارات – تمثيل - وغيرها من الخيارات',
                                prefixIcon: const Icon(Icons.handshake_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'طبيعة التعاون مطلوبة';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ],
            
                      // Student fields
                      if (_selectedRole == UserRole.student) ...[
                        TextFormField(
                          controller: _universityController,
                          decoration: InputDecoration(
                            labelText: localizations.university,
                            prefixIcon: const Icon(Icons.school_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bankAccountController,
                          decoration: InputDecoration(
                            labelText: localizations.bankAccount,
                            prefixIcon: const Icon(Icons.account_balance_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                          initialValue: _cooperationType,
                          decoration: InputDecoration(
                            labelText: localizations.cooperationType,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
            
                      // Engineer/Accountant fields
                      if (_selectedRole == UserRole.engineer ||
                          _selectedRole == UserRole.accountant) ...[
                        TextFormField(
                          controller: _licenseNumberController,
                          decoration: InputDecoration(
                            labelText: localizations.licenseNumber,
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _firmNameController,
                          decoration: InputDecoration(
                            labelText: localizations.firmName,
                            prefixIcon: const Icon(Icons.business_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    const SizedBox(height: 8),
            
                    // Forgot password link (only in login mode with email auth)
                    if (!_isSignUpMode && !_isPhoneAuth)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  final email = _emailController.text.trim();
                                  if (email.isEmpty ||
                                      !email.contains('@') ||
                                      !email.contains('.')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text(localizations.invalidEmail),
                                      ),
                                    );
                                    return;
                                  }
            
                                  try {
                                    await _authService
                                        .sendPasswordResetEmail(email);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            localizations.passwordResetEmailSent,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e
                                                .toString()
                                                .replaceFirst('Exception: ', ''),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: Text(localizations.forgotPassword),
                        ),
                      ),
                    if (!_isSignUpMode && !_isPhoneAuth) const SizedBox(height: 8),
                    
                    // Toggle between login and sign-up
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isSignUpMode = !_isSignUpMode;
                                  _signUpStep = 1;
                                  _errorMessage = null;
                                  _isCodeSent = false;
                                  _isPhoneVerified = false;
                                  _confirmPasswordController.clear();
                                  _otpController.clear();
                                  // Clear profile fields
                                  _nameController.clear();
                                  _phoneController.clear();
                                  _specializationController.clear();
                                  _licenseNumberController.clear();
                                  _firmNameController.clear();
                                  _universityController.clear();
                                  _bankAccountController.clear();
                                  _selectedRole = UserRole.client;
                                  _isTraining = false;
                                  _cooperationType = null;
                                  _selectedRegion = null;
                                  _selectedCity = null;
                                });
                              },
                        child: Text(
                          _isSignUpMode
                              ? localizations.alreadyHaveAccount
                              : localizations.dontHaveAccount,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
            
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_errorMessage != null) const SizedBox(height: 16),
            
                    // Sign in / Sign up button
                    if (!_isSignUpMode)
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_isPhoneAuth
                                ? (_isCodeSent && !_isPhoneVerified
                                    ? _handleVerifyOTP
                                    : _isCodeSent
                                        ? null
                                        : _handlePhoneAuth)
                                : _handleSignIn),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                _isPhoneAuth
                                    ? (_isCodeSent && !_isPhoneVerified
                                        ? localizations.verifyCode
                                        : _isCodeSent
                                            ? localizations.verified
                                            : localizations.sendCode)
                                    : localizations.signIn,
                                style: theme.textTheme.titleMedium,
                              ),
                      ),
            
                    // Sign-up buttons (step 1: Next/Send Code/Verify, step 2: Create Account + Back)
                    if (_isSignUpMode) ...[
                      if (_signUpStep == 1)
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : (_isPhoneAuth
                                  ? (_isPhoneVerified
                                      ? _handleCompletePhoneSignup
                                      : _isCodeSent
                                          ? _handleVerifyOTP
                                          : _handlePhoneAuth)
                                  : _nextStep),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  _isPhoneAuth
                                      ? (_isPhoneVerified
                                          ? localizations.completeSignUp
                                          : _isCodeSent
                                              ? localizations.verifyCode
                                              : localizations.sendCode)
                                      : localizations.next,
                                  style: theme.textTheme.titleMedium,
                                ),
                        ),
                      if (_signUpStep == 2) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : _previousStep,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(localizations.back),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            colorScheme.onPrimary,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        localizations.createAccount,
                                        style: theme.textTheme.titleMedium,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}