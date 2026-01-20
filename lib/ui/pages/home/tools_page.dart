import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:uicons/uicons.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SearchAppBar(
        title: localizations.tools,
        searchHint: 'بحث في الأدوات...',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              UIcons.regularRounded.wrench_simple,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'الأدوات القانونية',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'قريباً: أدوات حسابية وقوالب قانونية',
              style: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

