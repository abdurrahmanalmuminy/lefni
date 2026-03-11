import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset(
                    "assets/branding/lefni.png",
                    height: 50,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : null,
                  ),
                  const SizedBox(height: 48),
                  
                  // Hero text
                  Text(
                    "عندك قضية؟ عندنا محامي",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Subtitle
                  Text(
                    "اختر نوع حسابك للبدء",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Client button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login with client role context
                      context.go('/login?role=client');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 32,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "عميل",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "أبحث عن محامي",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lawyer button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login with lawyer role context
                      context.go('/login?role=lawyer');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.gavel_outlined,
                          size: 32,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "محامي",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "أقدم استشارات",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
