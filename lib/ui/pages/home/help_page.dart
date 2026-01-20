import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: SearchAppBar(
        title: localizations.help,
        searchHint: 'بحث في المساعدة...',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HelpSection(
            title: 'الدليل السريع',
            items: [
              'كيفية إضافة عميل جديد',
              'كيفية إنشاء قضية',
              'كيفية إصدار فاتورة',
              'كيفية جدولة جلسة',
            ],
          ),
          const SizedBox(height: 24),
          _HelpSection(
            title: 'الأسئلة الشائعة',
            items: [
              'كيف أضيف متعاون جديد؟',
              'كيف أطبع تقرير؟',
              'كيف أرفع مستند؟',
              'كيف أعدل عقد؟',
            ],
          ),
          const SizedBox(height: 24),
          _HelpSection(
            title: 'الدعم الفني',
            items: [
              'البريد الإلكتروني: support@lefni.com',
              'الهاتف: +966 50 123 4567',
              'ساعات العمل: 9 صباحاً - 5 مساءً',
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _HelpSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

