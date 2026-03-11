import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lefni/models/lefbi_onboarding.dart';
import 'package:lefni/services/onboarding_service.dart';

class OnboardingPage extends StatefulWidget {
  final String? selectedRoleId; // 'client' | 'lawyer' | null

  const OnboardingPage({
    super.key,
    this.selectedRoleId,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  late final List<Map<String, dynamic>> _steps;
  late final Map<String, dynamic> _commonUI;

  @override
  void initState() {
    super.initState();
    final allSteps =
        (lefniOnboarding['steps'] as List).cast<Map<String, dynamic>>();

    // If role is selected already (from landing), skip the role selection step
    // For clients specifically, we must NOT show lawyer choice.
    if (widget.selectedRoleId != null) {
      _steps = allSteps.where((s) => !s.containsKey('roles')).toList();
    } else {
      _steps = allSteps;
    }

    _commonUI = (lefniOnboarding['common_ui'] as Map).cast<String, dynamic>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  void _finishOnboarding() {
    _markCompletedAndGoHome();
  }

  Future<void> _markCompletedAndGoHome() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final onboardingId = lefniOnboarding['onboarding_id'] as String? ?? 'unknown';
    final roleId = widget.selectedRoleId ?? 'unknown';

    if (uid != null) {
      await OnboardingService.markCompleted(
        onboardingId: onboardingId,
        roleId: roleId,
        uid: uid,
      );
    }

    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top right)
            if (_currentStep < _steps.length - 1)
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(_commonUI['skip_text'] as String),
                  ),
                ),
              ),
            
            // PageView for steps
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return _buildStepContent(step, theme, colorScheme);
                },
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_commonUI['back_text'] as String),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  // Step indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentStep
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  
                  // Next/Finish button
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentStep == _steps.length - 1
                          ? (_commonUI['finish_text'] as String)
                          : (_steps[_currentStep]['button_text'] as String? ?? 'التالي'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
    Map<String, dynamic> step,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final title = step['title'] as String;
    final description = step['description'] as String;
    final imagePath = step['image_path'] as String?;
    final roles = step['roles'] as List<dynamic>?;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image (if available)
              if (imagePath != null)
                Image.asset(
                  imagePath,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon if image not found
                    return Icon(
                      Icons.info_outline,
                      size: 120,
                      color: colorScheme.primary,
                    );
                  },
                ),
              if (imagePath != null) const SizedBox(height: 32),
              
              // Title
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              // Role selection (only if no role selected from landing)
              if (widget.selectedRoleId == null &&
                  roles != null &&
                  roles.isNotEmpty) ...[
                const SizedBox(height: 32),
                ...roles.map((role) {
                  final roleData = role as Map<String, dynamic>;
                  final roleLabel = roleData['label'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          roleData['id'] == 'client'
                              ? Icons.person_outline
                              : Icons.gavel_outlined,
                          color: colorScheme.primary,
                        ),
                        title: Text(roleLabel),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
