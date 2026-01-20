import 'package:flutter/material.dart';

/// Reusable dialog wrapper for forms
/// Follows the same UI pattern as login/signup page
class FormDialog extends StatelessWidget {
  final String title;
  final Widget formContent;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;
  final bool isLoading;
  final String? submitLabel;
  final String? cancelLabel;

  const FormDialog({
    super.key,
    required this.title,
    required this.formContent,
    this.onCancel,
    this.onSubmit,
    this.isLoading = false,
    this.submitLabel,
    this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Form content
              formContent,
              const SizedBox(height: 24),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onCancel != null)
                    TextButton(
                      onPressed: isLoading ? null : onCancel,
                      child: Text(cancelLabel ?? 'Cancel'),
                    ),
                  const SizedBox(width: 8),
                  if (onSubmit != null)
                    ElevatedButton(
                      onPressed: isLoading ? null : onSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(submitLabel ?? 'Submit'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper extension for consistent form field styling
extension FormFieldStyle on InputDecoration {
  static InputDecoration styled({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

