import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/ui/widgets/entity_header.dart';
import 'package:lefni/ui/widgets/status_chip.dart';
import 'package:uicons/uicons.dart';
import 'package:intl/intl.dart';

class CaseDetailPage extends StatelessWidget {
  final String caseId;

  const CaseDetailPage({
    super.key,
    required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: FutureBuilder<CaseModel?>(
        future: CaseService().getCase(caseId),
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

          final case_ = snapshot.data;
          if (case_ == null) {
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
                    'القضية غير موجودة',
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
                  title: case_.caseNumber,
                  subtitle: case_.category.localized(AppLocalizations.of(context)!),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.description,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  actions: [
                    StatusChip(
                      status: case_.status,
                      type: StatusType.caseStatus,
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
                              'رقم القضية',
                              case_.caseNumber,
                            ),
                            _buildInfoRow(
                              context,
                              'الفئة',
                              case_.category.localized(AppLocalizations.of(context)!),
                            ),
                            _buildInfoRow(
                              context,
                              'الحالة',
                              case_.status.localized(AppLocalizations.of(context)!),
                            ),
                            _buildInfoRow(
                              context,
                              'تاريخ الإنشاء',
                              DateFormat('yyyy-MM-dd').format(case_.createdAt),
                            ),
                            _buildInfoRow(
                              context,
                              'آخر تحديث',
                              DateFormat('yyyy-MM-dd').format(case_.updatedAt),
                            ),
                            if (case_.closedAt != null)
                              _buildInfoRow(
                                context,
                                'تاريخ الإغلاق',
                                DateFormat('yyyy-MM-dd').format(case_.closedAt!),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Court Details
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تفاصيل المحكمة',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              'اسم المحكمة',
                              case_.courtDetails.courtName,
                            ),
                            _buildInfoRow(
                              context,
                              'الدائرة',
                              case_.courtDetails.circuit,
                            ),
                            if (case_.courtDetails.judge != null)
                              _buildInfoRow(
                                context,
                                'القاضي',
                                case_.courtDetails.judge!,
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
                              future: ClientService().getClient(case_.clientId),
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
                                return _buildInfoRow(context, 'العميل', case_.clientId);
                              },
                            ),
                            FutureBuilder(
                              future: UserService().getUser(case_.leadLawyerId),
                              builder: (context, lawyerSnapshot) {
                                if (lawyerSnapshot.hasData && lawyerSnapshot.data != null) {
                                  final lawyer = lawyerSnapshot.data!;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.verified_user,
                                          size: 20,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'المحامي الرئيسي',
                                                style: textTheme.bodySmall?.copyWith(
                                                  color: colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                lawyer.profile.name ?? lawyer.email,
                                                style: textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return _buildInfoRow(context, 'المحامي الرئيسي', case_.leadLawyerId);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (case_.collaborators.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Collaborators
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المتعاونون',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...case_.collaborators.map((collab) {
                                return FutureBuilder(
                                  future: UserService().getUser(collab.userId),
                                  builder: (context, userSnapshot) {
                                    final userName = userSnapshot.hasData && userSnapshot.data != null
                                        ? (userSnapshot.data!.profile.name ?? userSnapshot.data!.email)
                                        : collab.userId;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getCollaboratorIcon(collab.role),
                                            size: 20,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userName,
                                                  style: textTheme.bodyMedium,
                                                ),
                                                Text(
                                                  _getCollaboratorRoleLabel(collab.role),
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
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
                              }),
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
          context.go('/cases/edit/$caseId');
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


  String _getCollaboratorRoleLabel(CollaboratorRole role) {
    switch (role) {
      case CollaboratorRole.engineer:
        return 'مهندس';
      case CollaboratorRole.translator:
        return 'مترجم';
      case CollaboratorRole.accountant:
        return 'محاسب';
    }
  }

  IconData _getCollaboratorIcon(CollaboratorRole role) {
    switch (role) {
      case CollaboratorRole.engineer:
        return UIcons.regularRounded.settings;
      case CollaboratorRole.translator:
        return Icons.translate;
      case CollaboratorRole.accountant:
        return UIcons.regularRounded.calculator;
    }
  }
}

