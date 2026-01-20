import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/services/firestore/document_service.dart';
import 'package:lefni/models/document_model.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:lefni/ui/widgets/action_floating_button.dart';
import 'package:lefni/ui/widgets/forms/create_document_form.dart';
import 'package:uicons/uicons.dart';
import 'package:intl/intl.dart';

class DocumentsListPage extends StatefulWidget {
  const DocumentsListPage({super.key});

  @override
  State<DocumentsListPage> createState() => _DocumentsListPageState();
}

class _DocumentsListPageState extends State<DocumentsListPage> {
  final TextEditingController _searchController = TextEditingController();
  DocumentCategory? _categoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: SearchAppBar(
        title: localizations.documents,
        searchHint: 'بحث في المستندات...',
        searchController: _searchController,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: _categoryFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _categoryFilter = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('عميل'),
                  selected: _categoryFilter == DocumentCategory.clientDoc,
                  onSelected: (selected) {
                    setState(() {
                      _categoryFilter = DocumentCategory.clientDoc;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('مكتب'),
                  selected: _categoryFilter == DocumentCategory.officeDoc,
                  onSelected: (selected) {
                    setState(() {
                      _categoryFilter = DocumentCategory.officeDoc;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('عقد'),
                  selected: _categoryFilter == DocumentCategory.contract,
                  onSelected: (selected) {
                    setState(() {
                      _categoryFilter = DocumentCategory.contract;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _categoryFilter != null
                  ? DocumentService().getDocumentsByCategory(_categoryFilter!)
                  : DocumentService().getAllDocuments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد مستندات',
                      style: textTheme.bodyLarge,
                    ),
                  );
                }

                var documents = snapshot.data!;
                if (_searchController.text.isNotEmpty) {
                  documents = documents.where((d) {
                    return d.fileName
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase());
                  }).toList();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Icon(
                                _getFileIcon(doc.fileType),
                                size: 48,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.fileName,
                                  style: textTheme.titleSmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormat.format(doc.uploadedAt),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  _formatFileSize(doc.fileSize),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ActionFloatingButton(
        labelKey: 'uploadDocument',
        icon: UIcons.regularRounded.plus,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateDocumentForm(),
          );
        },
      ),
    );
  }

  IconData _getFileIcon(FileType type) {
    switch (type) {
      case FileType.pdf:
        return UIcons.regularRounded.file;
      case FileType.word:
        return UIcons.regularRounded.file;
      case FileType.image:
        return UIcons.regularRounded.file;
      case FileType.excel:
        return UIcons.regularRounded.file;
      default:
        return UIcons.regularRounded.file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
