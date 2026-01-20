import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/session_model.dart';
import 'package:lefni/services/firestore/session_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/ui/widgets/entity_header.dart';
import 'package:lefni/ui/widgets/status_chip.dart';
import 'package:uicons/uicons.dart';
import 'package:intl/intl.dart';

class SessionDetailPage extends StatelessWidget {
  final String sessionId;

  const SessionDetailPage({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: FutureBuilder<SessionModel?>(
        future: SessionService().getSession(sessionId),
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

          final session = snapshot.data;
          if (session == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'الجلسة غير موجودة',
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
                  title: session.type.localized(AppLocalizations.of(context)!),
                  subtitle: DateFormat('yyyy-MM-dd HH:mm').format(session.scheduledAt),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      UIcons.regularRounded.calendar,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  actions: [
                    StatusChip(
                      status: session.status,
                      type: StatusType.sessionStatus,
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
                              'النوع',
                              session.type.localized(AppLocalizations.of(context)!),
                            ),
                            _buildInfoRow(
                              context,
                              'التاريخ والوقت',
                              DateFormat('yyyy-MM-dd HH:mm').format(session.scheduledAt),
                            ),
                            _buildInfoRow(
                              context,
                              'الموقع',
                              session.location,
                            ),
                            if (session.meetingLink != null)
                              _buildInfoRow(
                                context,
                                'رابط الاجتماع',
                                session.meetingLink!,
                              ),
                            _buildInfoRow(
                              context,
                              'تاريخ الإنشاء',
                              DateFormat('yyyy-MM-dd').format(session.createdAt),
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
                              future: ClientService().getClient(session.clientId),
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
                                return _buildInfoRow(context, 'العميل', session.clientId);
                              },
                            ),
                            FutureBuilder(
                              future: UserService().getUser(session.lawyerId),
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
                                                'المحامي',
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
                                return _buildInfoRow(context, 'المحامي', session.lawyerId);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Reminders
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التذكيرات',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              'رسالة نصية',
                              session.remindersSent.sms ? 'تم الإرسال' : 'لم يتم الإرسال',
                            ),
                            if (session.remindersSent.smsSentAt != null)
                              _buildInfoRow(
                                context,
                                'تاريخ إرسال الرسالة',
                                DateFormat('yyyy-MM-dd HH:mm').format(session.remindersSent.smsSentAt!),
                              ),
                            _buildInfoRow(
                              context,
                              'تذكير داخلي',
                              session.remindersSent.internal ? 'تم الإرسال' : 'لم يتم الإرسال',
                            ),
                            if (session.remindersSent.internalSentAt != null)
                              _buildInfoRow(
                                context,
                                'تاريخ التذكير الداخلي',
                                DateFormat('yyyy-MM-dd HH:mm').format(session.remindersSent.internalSentAt!),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (session.report != null) ...[
                      const SizedBox(height: 16),
                      // Session Report
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تقرير الجلسة',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (session.report!.content != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    session.report!.content!,
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                              if (session.report!.attachments.isNotEmpty) ...[
                                Text(
                                  'المرفقات',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...session.report!.attachments.map((url) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: InkWell(
                                        onTap: () {
                                          // TODO: Open attachment
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              UIcons.regularRounded.file,
                                              size: 20,
                                              color: colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                url,
                                                style: textTheme.bodyMedium?.copyWith(
                                                  color: colorScheme.primary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ],
                              if (session.report!.submittedAt != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: _buildInfoRow(
                                    context,
                                    'تاريخ التقديم',
                                    DateFormat('yyyy-MM-dd HH:mm').format(session.report!.submittedAt!),
                                  ),
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
          context.go('/sessions/edit/$sessionId');
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

}

