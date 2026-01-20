import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/contract_model.dart';
import 'package:lefni/services/firestore/contract_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/ui/widgets/entity_header.dart';
import 'package:lefni/ui/widgets/status_chip.dart';
import 'package:uicons/uicons.dart';
import 'package:intl/intl.dart';

class ContractDetailPage extends StatelessWidget {
  final String contractId;

  const ContractDetailPage({
    super.key,
    required this.contractId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: FutureBuilder<ContractModel?>(
        future: ContractService().getContract(contractId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ أثناء تحميل البيانات',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            );
          }

          final contract = snapshot.data;
          if (contract == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'العقد غير موجود',
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: EntityHeader(
                  title: contract.title,
                  subtitle: contract.partyType.localized(AppLocalizations.of(context)!),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.description,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  actions: [
                    StatusChip(
                      status: contract.signatureStatus.status,
                      type: StatusType.signatureStatus,
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Basic Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المعلومات الأساسية',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              'العنوان',
                              contract.title,
                            ),
                            _buildInfoRow(
                              context,
                              'نوع الطرف',
                              contract.partyType.localized(AppLocalizations.of(context)!),
                            ),
                            _buildInfoRow(
                              context,
                              'حالة التوقيع',
                              _getSignatureStatusLabel(contract.signatureStatus.status),
                            ),
                            if (contract.signatureStatus.isSigned && contract.signatureStatus.signedAt != null)
                              _buildInfoRow(
                                context,
                                'تاريخ التوقيع',
                                DateFormat('yyyy-MM-dd HH:mm').format(contract.signatureStatus.signedAt!),
                              ),
                            _buildInfoRow(
                              context,
                              'تاريخ الإنشاء',
                              DateFormat('yyyy-MM-dd').format(contract.createdAt),
                            ),
                            _buildInfoRow(
                              context,
                              'آخر تحديث',
                              DateFormat('yyyy-MM-dd').format(contract.updatedAt),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Related Entities
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الكيانات المرتبطة',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder(
                              future: ClientService().getClient(contract.clientId),
                              builder: (context, clientSnapshot) {
                                if (clientSnapshot.hasData && clientSnapshot.data != null) {
                                  final client = clientSnapshot.data!;
                                  return InkWell(
                                    onTap: () => context.go('/clients/${client.id}'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            UIcons.regularRounded.user,
                                            size: 20,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'العميل',
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                                Text(
                                                  client.name,
                                                  style: textTheme.bodyMedium?.copyWith(
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            UIcons.regularRounded.arrow_left,
                                            size: 16,
                                            color: colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return _buildInfoRow(context, 'العميل', contract.clientId);
                              },
                            ),
                            if (contract.caseId != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: InkWell(
                                  onTap: () => context.go('/cases/${contract.caseId}'),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.description,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'القضية',
                                              style: textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                            Text(
                                              contract.caseId!,
                                              style: textTheme.bodyMedium?.copyWith(
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        UIcons.regularRounded.arrow_left,
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (contract.files.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Files
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الملفات',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...contract.files.map((file) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: InkWell(
                                      onTap: () {
                                        // TODO: Open file
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            file.type == FileType.pdf
                                                ? Icons.picture_as_pdf
                                                : UIcons.regularRounded.file,
                                            size: 20,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              file.name,
                                              style: textTheme.bodyMedium?.copyWith(
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Content
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المحتوى',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                contract.content,
                                style: textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (contract.metadata.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Tags
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'العلامات',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: contract.metadata.tags.map((tag) => Chip(
                                      label: Text(tag),
                                      backgroundColor: colorScheme.surfaceContainerHighest,
                                    )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/contracts/edit/$contractId');
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }


  String _getSignatureStatusLabel(SignatureStatusType status) {
    switch (status) {
      case SignatureStatusType.pending:
        return 'في الانتظار';
      case SignatureStatusType.accepted:
        return 'مقبولة';
      case SignatureStatusType.rejected:
        return 'مرفوضة';
    }
  }
}

